////A liquid-like coat mediates chromosome clustering during mitotic exit
//Quantification of GEMs in chromosome ensemble area
//Sara Cuylen-Haering
//Alberto Hernandez-Armendariz

//Fiji script to measure convex hull around chromatin and measure GFP signal in convex hull

//Input: Directory with z-stacks.
//Output: 1) Text file with information of convex hull in GFP channel. 2) Text file with information of convex hull in chromatin channel. 3) Overlay of convex hull in GFP channel. 4)Overlay of convex hull in chromatin channel. 5) Binary mask of convex hull.


dir = getDirectory("Choose input directory");
G_Ddir = getDirectory("Choose destination directory");
list = getFileList(dir);

for (j=0; j<list.length; j++) {
run("Bio-Formats Importer", "open=["+dir + list[j]+"] autoscale color_mode=Default view=[Hyperstack] stack_order=Default");

//set scale to pixel values
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

//get data
imageititle = getTitle();
Slices=nSlices;
Z=nSlices/2;
print(Z);

//split and rename channels
run("Split Channels");
selectWindow("C1-"+ imageititle);
rename("chromatin");

selectWindow("C2-"+ imageititle);
rename("GFP");


//Process chromatin image
//************************************************************************
selectWindow("chromatin");

//make bleach correction 
run("Bleach Correction", "correction=[Exponential Fit (Frame-wise)]");
run("Duplicate...", "title=bleach_corr duplicate range=1-&Z");

//thresholding and conversion to binary
selectWindow("bleach_corr");
setAutoThreshold("Default");
run("Gaussian Blur...", "sigma=2 stack");
run("Convert to Mask", "method=Default background=Dark");
run("Make Binary", "method=Default background=Dark");

//Remove background
setSlice(1);
selectWindow("bleach_corr");

Z=nSlices;
print(Z);
setForegroundColor(65535,65535,65535);

for (i=0; i<Z; i++) {
run("Select All");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear add slice");

nROIs=roiManager("count");

	for(k=0; k<nROIs; k++){
		roiManager("select", k);
		getStatistics(area);
		print(area);
		if (area<10000){
			run("Fill", "slice");
		}
	}

run("Next Slice [>]");
}
selectWindow("ROI Manager");
run("Close");

//enter convex hull ROIs in ROI manager
selectWindow("bleach_corr");
setSlice(1);
Z=nSlices;
print(Z);
for (i=0; i<Z; i++){
	run("Convex Hull Plus", "mode=[Convex Hull selection] white log");
	roiManager("Add");
	run("Next Slice [>]");
}

//measure and Draw Roi in original image
selectWindow("chromatin");
run("RGB Color");
setSlice(1);
for (i=0; i<Z; i++) {
print(i);
setSlice(i+1);
roiManager("Select", i);
getVoxelSize(w, h, d, unit);
getStatistics(area, mean, min , max);
print(area);
      setResult("Area ("+unit+"^2)",  i, area);
      setResult("Mean2",  i, mean);
      setResult("Slice", i, i+1); 
setForegroundColor(65535);         
roiManager("Draw");
}

updateResults();
dest_filename1 = imageititle + "_chromatin_hull";
fullpath1 = G_Ddir + dest_filename1;
saveAs("tiff", fullpath1);

//save results
selectWindow("Results");
dest_filename_2 = imageititle+ "_table_chromatin.txt";
fullpath2 = G_Ddir + dest_filename_2;
saveAs("Results", fullpath2);

//Draw convex hull in binary image
selectWindow("bleach_corr");
run("RGB Color");
setForegroundColor(65535);
setSlice(1);
for (i=0; i<Z; i++) {
setSlice(i+1);
roiManager("Select", i);
roiManager("Draw");
}

dest_filename3 = imageititle + "_binary_hull";
fullpath3 = G_Ddir + dest_filename3;
saveAs("tiff", fullpath3);

run("Clear Results");

//Process GFP image
//************************************************************************
selectWindow("GFP");
setSlice(1);
for (i=0; i<Z; i++) {
print(i);
setSlice(i+1);
roiManager("Select", i);
getVoxelSize(w, h, d, unit);
getStatistics(area, mean, min , max);
print(area);
      setResult("Area ("+unit+"^2)",  i, area);
      setResult("Mean2",  i, mean);
      setResult("Slice", i, i+1); 
setForegroundColor(65535);         
roiManager("Draw");
}
updateResults();

//Save GFP image with convex hull
dest_filename1 = imageititle + "_GFP_convex_hull";
fullpath1 = G_Ddir + dest_filename1;
saveAs("tiff", fullpath1);

//save results
selectWindow("Results");
dest_filename_2 = imageititle+ "_table_GFP.txt";
fullpath2 = G_Ddir + dest_filename_2;
saveAs("Results", fullpath2);

//clean up
run("Clear Results");
run("Close All");
selectWindow("ROI Manager");
run("Close");
}