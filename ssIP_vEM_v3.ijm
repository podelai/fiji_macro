/*
 * ssIP_vEM_v3 - Simple single Image Processing for volume electron microscopy image stack Macro
 * 
 * This macro performs various image processing operations on single images before stacking them :
 * - 8-bit conversion for size reduction
 * - directionnal alteration correction using custom convolution kernels
 * - Median filtering for noise reduction
 * - 2x2 binning for size reduction
 * 
 * Author: DAUNAS Lucien
 * MRI-EM4Bio BioCampus, CNRS
 * Last modified: 2025-02-12
 */

// User interface parameters
#@ File (label="Input directory", style="directory", description="Location of the image sequence") input_dir
#@ File (label="Output directory", style="directory", description="Target directory to save processed stack") output_dir
#@ String (label="Save name", description="Output filename") save_name

#@ boolean (label="8-bit conversion", description="Convert image to 8-bit grayscale") convert_8bit
#@ boolean (label="Correct directional alteration", description="Apply directional alteration correction filters") directional_filter
#@ boolean (label="Apply median filter", description="Reduce noise using 3x3 median filter") median_filter
#@ boolean (label="2x2 binning", description="Reduce size using 2x2 binning") x2_binning


//Batch mode true
setBatchMode(true); 


// Convolution kernels for directional alteration correction
var HORIZONTAL_KERNEL = "0.0135 0.061 0.101 0.061 0.0135\n" +
                       "-0.027 -0.122 0.798 -0.122 -0.027\n" +
                       "0.0135 0.061 0.101 0.061 0.0135\n";

var VERTICAL_KERNEL = "0.0135 -0.027 0.0135\n" +
                     "0.061 -0.122 0.061\n" +
                     "0.101 0.798 0.101\n" +
                     "0.061 -0.122 0.061\n" +
                     "0.0135 -0.027 0.0135\n";
                     
function applyDirectionalCorrections() {
	run("Convolve...", "text1=[" + HORIZONTAL_KERNEL + "]");
	run("Convolve...", "text1=[" + VERTICAL_KERNEL + "]");
}


function imageProcess(){
	
	//convert image to 8bit
	if (convert_8bit) {run("8-bit");}
	
	//apply directional filters 
	if (directional_filter) {applyDirectionalCorrections();}
	
	//apply median filter
	if (median_filter) {run("Median...", "radius=1");}
	
	//image binning 2x2 (average)
	if (x2_binning) {run("Bin...", "x=2 y=2 z=1 bin=Average");}
	
}

// Main execution

// Start timing
timer1 = getTime();

//Scan the source folder
image_list = getFileList(input_dir);
image_list = Array.sort(image_list);
    
for (i = 0; i < image_list.length; i++) {
	fileName = image_list[i];
	filePath = input_dir + File.separator + fileName;
	
	print("(" + (i+1) + "/" + image_list.length + ") Processing : " + fileName);
	open(filePath);
	
	imageProcess();
}

run("Images to Stack", "use");

// Save results
saveAs("Tiff", output_dir + File.separator + save_name);


// Cleanup and summary
run("Close All");
timer2 = getTime();
timetaken = Math.round((timer2-timer1)/1000);
print("\nExecution Summary:");
print("----------------");
print("Time taken: " + timetaken/60 + " minutes");
print("Source folder: " + input_dir);
print("Saved to: " + output_dir + " as " + save_name);
