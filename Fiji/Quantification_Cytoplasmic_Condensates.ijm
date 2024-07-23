////A liquid-like coat mediates chromosome clustering during mitotic exit
//Quantification of Cytoplasmic Condensates
//Sara Cuylen-Haering
//Alberto Hernandez-Armendariz

//- Fiji script to remove any particle in the chromosome region while quantifying particles in the cytoplasm

//Input: Directory with z-stacks.
//Output: 1) Text file with information of cytoplasmic condensates per time point. 2) Overlay of cytoplasmic condensates in GFP channel. 3) Binary mask of cytoplasmic condensates.  4) Chromatin binary mask. 5) Zip file. 

//set folders
dir = getDirectory("Choose input directory");
G_Ddir = getDirectory("Choose destination directory");

//get file list
list = getFileList(dir);

//loop over files
for (j=0; j<list.length; j++) {
	run("Bio-Formats Importer", "open=["+dir + list[j]+"] autoscale color_mode=Default view=[Hyperstack] stack_order=Default");

	//Z-projection
	run("Z Project...", "start=1 stop=4 projection=[Max Intensity] all");
	
	imageititle = getTitle();
	
	//duplicate image to be able to generate overlay image with ROIs
	Z=nSlices;

	//split and rename channels
	run("Split Channels");
	selectWindow("C1-"+ imageititle);
	rename("GFP");

	selectWindow("C2-"+ imageititle);
	rename("chromatin");
	
	//Process chromosomes image
	//************************************************************************
	selectWindow("chromatin");
	run("Gaussian Blur...", "sigma=2 stack");
	setAutoThreshold("Default");	
	run("Convert to Mask", "method=Default background=Dark");

	// Dilation of chromatin signal to avoid condensates on its surface
	run("Make Binary", "method=Default background=Dark");
	run("Options...", "iterations=20 count=1");
	run("Dilate","stack");
	run("Options...", "iterations=1 count=1");
	run("Invert", "stack");	

		//save image
	dest_filename_6 = imageititle+ "_chromatin_binary.tif";
	fullpath6 = G_Ddir + dest_filename_6;
	saveAs("tiff", fullpath6);

	rename("chromatin");
	
	//************************************************************************
	//GFP channel
	selectWindow("GFP");
	run("Duplicate...", "title=dupl duplicate range=1-&Z");
	
	//convert image to binary image
	run("Gaussian Blur...", "sigma=2 stack");
	run("Subtract Background...", "rolling=25 stack");

	//adjust threshold for full-length mutants
	setThreshold(0,2500);
	run("Convert to Mask", "method=Default background=Dark");
	run("Make Binary", "method=Default background=Dark");

	
	//remove all spots in chromosomes region
	imageCalculator("Multiply create stack", "chromatin","dupl");

	//save image
	dest_filename_3 = imageititle+ "_background_sub.tif";
	fullpath3 = G_Ddir + dest_filename_3;
	saveAs("tiff", fullpath3);
	
	//analyze particle over entire stack
	run("Analyze Particles...", "display add stack");

	//save ROIs if ROIs have been detected
	if (roiManager("count") != 0) {
	print("ROIs detected");
	
	dest_filename_2 = imageititle+ "_ROIs_condensates_stack.zip";
	fullpath2 = G_Ddir + dest_filename_2;
	roiManager("Save", fullpath2);

	//measure GFP intensity in ROI**********************

	selectWindow(imageititle+"_background_sub.tif");
	close();
	
	selectWindow("dupl");
	close();
	
	selectWindow("C3-"+imageititle);
	close();
	
	selectWindow("chromatin");
	close();

	run("Clear Results");
	nROIs=roiManager("count");
	print("Number of ROIs"+nROIs);
	
	//loop over ROIs
	selectWindow("GFP");
	for(k=0; k<nROIs; k++){
		roiManager("select", k);
		roiManager("Measure");
		}
	
 	//save results table
	selectWindow("Results");
	dest_filename_5 = imageititle+ "_table_condensates_stack_GFP.txt";
	fullpath5 = G_Ddir + dest_filename_5;
	saveAs("Results", fullpath5);
	}
	else {
		print("No ROIs found for movie: "+ imageititle);

		//save results table
		selectWindow("Results");
		dest_filename_5 = imageititle+ "_table_no_condensates_stack_GFP.txt";
		fullpath5 = G_Ddir + dest_filename_5;
		saveAs("Results", fullpath5);
	}

	//Draw ROIs in original image output
	array1 = newArray("0"); 
	for (i=1;i<roiManager("count");i++){ 
	        array1 = Array.concat(array1,i); 
	} 
	
	roiManager("select", array1); 
	selectWindow("GFP");
	run("RGB Color");
	setForegroundColor(255, 255, 0);   
	roiManager("Draw");
	
	//save image
	dest_filename_4 = imageititle+ "_background_ROIs.tif";
	fullpath4 = G_Ddir + dest_filename_4;
	saveAs("tiff", fullpath4);

	
	//clean up
	run("Clear Results");
	roiManager("reset");
	close("*");
	}