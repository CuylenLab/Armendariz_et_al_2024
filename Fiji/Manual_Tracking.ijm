////A liquid-like coat mediates chromosome clustering during mitotic exit
//Script to manually track and measure ROI
//Sara Cuylen-Haering
//Alberto Hernandez-Armendariz

// Input: Folder with single-slice, single-channel timelapse.
// Output: 1) Tif file with overlayed ROI. 2) Csv file with measurements per timepoint. 3) Folder with Image sequence. 4) Zip file.

////////NOTE: 
//-Define cell ID in script
//-Script displays a ROI (35x35) for the first frame and waits for user input
//-ROI needs to be positioned as desired and ROIs are added to the ROI manager and saved

ID = 1; //cell ID

//Define directories
dir = getDirectory("Choose the destination directory");

//Make new directory for cell ID
new_dir1 = dir + "/cell_" + ID + "_crop/"; //cell ID
File.makeDirectory(new_dir1); 

//get title and remove .tif ending
imagetitle = getTitle();
strT = split(imagetitle, ".");
imagetitle = strT[0];
rename(imagetitle);
print(imagetitle);

//get dimensions of image
getDimensions(width, height, channels, slices, frames);

//Associates ROIs with slices
roiManager("Associate", "true");

//Generate ROI
run("Specify...", "width=35 height=35 x=40 y=40 slice=1 oval");

for (i=1; i<frames+1; i++) {
	setSlice(i);
	waitForUser("Select rectangle around cell of interest");
	run("Add to Manager");	
	}

//select all ROIs and save them
roiManager("Select", newArray(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259));
roiManager("Save", new_dir1 + imagetitle + "_ROIset.zip");
rois = roiManager("count");
print("Number of ROIs: " + rois);

//loop over ROIs to generate crop views
for (i=0 ; i<rois; i++) {
	selectWindow(imagetitle);
	j=i+1; //convert ROIs to frames (ROIs start with 0, frames with 1)
	roiManager("Select", i);
	run("Measure");
	run("Flatten", "slice");
	
	//Save image in new directory "Image sequence"
	new_dir2 = new_dir1 + "/Image_sequence/"; 
	File.makeDirectory(new_dir2); 
	dest_filename1 = imagetitle + "ROI_flattened_" + ID + "_frame"+j+".tif";
	fullpath1 = new_dir2 + dest_filename1;
	saveAs("tiff", fullpath1);
	run("Close");
	}	

//open saved images as image sequence and convert to hyperstack
run("Image Sequence...", "open=&new_dir2");

//save as Stack
saveAs("Tiff", new_dir1 + imagetitle + "_ROI_flattened_stack.tif");

//save Results Table
dest_filename3 = imagetitle + "Results.csv";
fullpath3 = new_dir1 + dest_filename3;
saveAs("Results", fullpath3);

//clean up for next cell
selectWindow("ROI Manager");
run("Close");