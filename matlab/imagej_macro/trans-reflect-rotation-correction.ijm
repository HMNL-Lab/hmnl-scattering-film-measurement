// open reflection image
path1 = File.openDialog("Select Reflection Image");
open(path1);
rID = getImageID();
selectImage(rID);

// wait for user to draw line along substrate-spray interface
waitForUser("Draw a line along substrate-spray interface");
getLine(x1r, y1r, x2r, y2r, width);
if (x1r==-1) {
	exit("This macro requires a straight line selection");
}

// find the angle of the selected line in degrees
angle = 90 + (180.0/PI)*atan2(y1r-y2r, x2r-x1r); // in degrees
run("Rotate... ", "angle="+angle+" grid=1 interpolation=None");

// correct reflection position for angle
angle_rad = angle * PI / 180;

x1r = x1r * cos(angle_rad) - y1r * sin(angle_rad);
y1r = x1r * sin(angle_rad) + y1r * cos(angle_rad);

x2r = x2r * cos(angle_rad) - y2r * sin(angle_rad);
y2r = x2r * sin(angle_rad) + y2r * cos(angle_rad);


// WARNING: overwrites files
save(path1);

// open transmission image
path2 = File.openDialog("Select Transmission Image");
open(path2);
tID = getImageID();
selectImage(tID);

run("Rotate... ", "angle="+angle+" grid=1 interpolation=None");
waitForUser("Draw a straight line (holding shift) approx. where the transmission boundary is.");
getLine(x1t, y1t, x2t, y2t, width);
save(path2);

factor = 1;
toScaled(factor);
factor = 1/factor;


setResult("Angle", 0, angle);
setResult("x1_r", 0, x1r);
setResult("y1_r", 0, y1r);
setResult("x2_r", 0, x2r);
setResult("y2_r", 0, y2r);

setResult("x1_t", 0, x1t);
setResult("y1_t", 0, y1t);
setResult("x2_t", 0, x2t);
setResult("y2_t", 0, y2t);

setResult("Conversion", 0, factor);
setResult("Reflection", 0, path1);
setResult("Transmission", 0, path2);

//setOption("ShowRowNumbers", false)
dir = File.getDirectory(path1);
//updateResults;

sample_name = File.getNameWithoutExtension(path1);
saveAs("Results", dir+sample_name+".csv");
close("*");
//run("Close");