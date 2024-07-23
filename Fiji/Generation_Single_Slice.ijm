////A liquid-like coat mediates chromosome clustering during mitotic exit
//Extract center slice from a z-stack
//Sara Cuylen-Haering
//Alberto Hernandez-Armendariz

//- Fiji script to identify the slice with the highest mean intensity from a z-stack and copy it

//Input: Folder with z-stack with 3 channels
//Output: Single slices with highest mean intensity


dir = getDirectory("Choose the folder with images to process");
G_Ddir = getDirectory("Choose Destination Directory");
list = getFileList(dir);
for (j=0; j<list.length; j++) {

run("Bio-Formats Importer", "open=["+dir + list[j]+"] autoscale color_mode=Default view=[Hyperstack] stack_order=Default");

//get title without .tif ending
imagetitle = getTitle();
strT = split(imagetitle, ".");
imagetitle = strT[0];
rename(imagetitle);

//Split channels
run("Split Channels");

selectWindow("C1-"+ imagetitle);
rename("GFP");

selectWindow("C2-"+ imagetitle);
rename("H2B");

selectWindow("C3-"+ imagetitle);
run("Close");

Stack.getDimensions(width, height, channels, slices, frames);
print(imagetitle);

//loop over frames
for (i=1; i<=frames; i++) {

	//Get most centered slice
	//Select slice with most H2B signal (highest mean intensity)
	print("frame: " + i);
	selectWindow("H2B");
	Stack.setFrame(i);	
	maxMean = 0;

	//loop over slices
	for (n = 1; n <= slices; n ++) {
		Stack.setSlice(n);
		getStatistics(area, mean);
		print(mean);
			if (mean > maxMean) {
				maxMean = mean;	//if it is larger than maxMean, then mark this slice as the new maxMean
				frameToDup = n;	
			}
	}
	
	print("Center frame: " + frameToDup);

	//get H2B single slice
	selectWindow("H2B");
	run("Duplicate...", "title=dupH2B duplicate slices=&frameToDup frames=&i");
	wait(100);

	//get GFP single slice
	selectWindow("GFP");
	run("Duplicate...", "title=dupGFP duplicate slices=&frameToDup frames=&i");
	wait(100);

}

selectWindow("GFP");
run("Close");
selectWindow("H2B");
run("Close");
run("Images to Stack");
run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=1 frames=53 display=Grayscale");

dest_filename = imagetitle+"_stack_centerZ.tif";
	fullpath = G_Ddir + dest_filename;
	print(fullpath);
	saveAs("tiff", fullpath);

wait(1000);

//save log window
selectWindow("Log");
saveAs("Text", G_Ddir + imagetitle + "_log.txt");
	
run("Close");

run("Split Channels");

selectWindow("C2-" + imagetitle+ "_stack_centerZ.tif");
dest_filename = imagetitle+"_stack_centerZ_GFP.tif";
	fullpath = G_Ddir + dest_filename;
	print(fullpath);
	saveAs("tiff", fullpath);
run("Close");

selectWindow("C1-" + imagetitle+ "_stack_centerZ.tif");
dest_filename = imagetitle+"_stack_centerZ_H2B.tif";
	fullpath = G_Ddir + dest_filename;
	print(fullpath);
	saveAs("tiff", fullpath);
run("Close");

run("Close All");
}

