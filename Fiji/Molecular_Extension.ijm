////A liquid-like coat mediates chromosome clustering during mitotic exit
//Ki-67 molecular extension at surface of mitotic chromosomes
//Sara Cuylen-Haering
//Alberto Hernandez-Armendariz

//- Fiji script to measure extension of Ki-67 tagged with two different fluorophores at each terminus. Draw line perpendicular to single-chromatid.

//Input: Directory with single slices (2 channels) perpendicular to mitotic chromatids.
//Output: 1) Text file with coordinates of line profile and measurements in both channels. 2) Image with overlayed line profile.


dir = getDirectory("Choose input directory");
dirout=getDirectory("Choose output directory"); // get output directory where results will be saved
list = getFileList(dir);

for (j=0; j<list.length; j++) {
print(list.length);
print(j);
run("Bio-Formats Importer", "open=["+dir + list[j]+"] color_mode=Default view=[Hyperstack] stack_order=Default");

name= getTitle();
split_name = split(name, ".");// titel of the current image
name2 = split_name[0];

print(name);
selectWindow(name);
getPixelSize(unit, pw, ph, pd);
print(pw);
run("Set... ", "zoom=800");

waitForUser("Check how many line profiles you want to draw");

//Create dialog for user input
Dialog.create("Interactive input");
Dialog.addNumber("How many line profiles do you want to draw?", 1);
Dialog.show();

n = Dialog.getNumber();

//if no line should be drawn close window and do nothing
if (n == 0) {
	selectWindow(name2+".lsm");
	run("Close");
	}
else
	{
	for (i=0; i<n; i++) {
	id = i+1;
	setTool("point");
	run("ROI Manager...");
	setSlice(1);
	run("Line Width...", "line=2");
	setTool("line");
	waitForUser("Draw a line");
	        profile= getProfile();
	        getPixelSize(unit, pw, ph, pd);
		print(pw);
	        for (c=0; c<profile.length; c++)
	        {d= c*pw;
	        setResult("coord", c, d);
	        updateResults();}
	        dest_filename1 = name2 + "_line_"+id;
		fullpath1 = dirout + dest_filename1;
		saveAs("tiff", fullpath1);
	        
	setSlice(1);
	        profile1 = getProfile();
	        for (k=0; k<profile1.length; k++)
	        {setResult("C1", k, profile1[k]);
		updateResults();}
	setSlice(2);
	        profile2 = getProfile();
	        for (a=0; a<profile2.length; a++)
	        {setResult("C2", a, profile2[a]);
	         setOption("ShowRowNumbers", false);
	        updateResults();}
	
	selectWindow("Results");       
	saveAs("Text", dirout+name2+"_line_profile_"+id+".txt");
	run("Clear Results"); 
	}
	selectWindow(name2+"_line_"+id+".tif");
	run("Close");
	}
}

