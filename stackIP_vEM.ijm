/*
 * stackIP_vEM - Stack Image Processing for volume Electron microscopy
 * 
 * This macro performs various image processing operations on stack image :
 * - slice clearing
 * - 8-bit conversion for size reduction
 * - directionnal alteration correction using custom convolution kernels
 * - Median filtering for noise reduction
 * - 2x2 binning for size reduction
 * 
 * Author: DAUNAS Lucien
 * MRI-EM4Bio BioCampus, CNRS
 * Last modified: 2025-02-12
 */

// UI Dialog Parameters
#@ File (label="Input directory", style="directory", description="Location of the image sequence") input_dir
#@ File (label="Output directory", style="directory", description="Target directory to save processed stack") output_dir
#@ String (label="Save name", description="Output filename") save_name
#@ boolean (label="Delete broken slices") stack_clear
#@ boolean (label="Correct horizontal alteration") stack_horalt
#@ boolean (label="Correct vertical alteration") stack_veralt
#@ boolean (label="Apply median filter") stack_median
#@ boolean (label="Process stack binning 2x2") stack_bin
#@ boolean (label="Process stack alignment") stack_align

// Function to validate directories
function validateDirectories() {
    if (!File.exists(input_dir)) {
        exit("Error: Input directory does not exist: " + input_dir);
    }
    if (!File.exists(output_dir)) {
        File.makeDirectory(output_dir);
        print("Created output directory: " + output_dir);
    }
}

// Function to create reference line arrays
function createReferenceLine(value, length) {
    line = newArray(length);
    for (i = 0; i < length; i++) {
        line[i] = value;
    }
    return line;
}

// Function to clean stack based on mean intensity
function cleanStack() {
    run("Set Measurements...", "mean stack redirect=None decimal=0");
    
    // Create ROI for measurement
    arg = "width=" + (getWidth()-10) + 
          " height=" + (getHeight()-10) + 
          " x=" + (getWidth()/2) + 
          " y=" + (getHeight()/2) + 
          " slice=1 centered";
    run("Specify...", arg);
    roiManager("Add");
    roiManager("multi-measure measure_all");
    
    nSlice=nSlices;
    
    // Calculate stack mean
    run("Summarize");
    stack_mean = getResult("Mean", nSlice);
    
    // Get slice numbers for x-axis
    slices = Table.getColumn("Slice", "Results");
    means = Table.getColumn("Mean", "Results");
    
    // Create reference lines for different thresholds
    ref_98 = createReferenceLine(stack_mean * 0.98, slices.length - 4);
    ref_95 = createReferenceLine(stack_mean * 0.95, slices.length - 4);
    ref_90 = createReferenceLine(stack_mean * 0.90, slices.length - 4);
    
    // Create and customize plot
    Plot.create("Slice Intensity Plot", "Slice", "Mean Intensity");
    Plot.setLineWidth(2);
    
    // Add intensity bars
    Plot.add("Separated Bars", slices, means);
    Plot.setStyle(0, "blue,#a0a0ff,1.0,Separated Bars");
    
    // Add threshold lines
    Plot.setColor("red");
    Plot.add("line", slices, ref_98);
    Plot.addText("98% threshold", slices.length-20, stack_mean * 0.98);
    
    Plot.setColor("orange");
    Plot.add("line", slices, ref_95);
    Plot.addText("95% threshold", slices.length-20, stack_mean * 0.95);
    
    Plot.setColor("yellow");
    Plot.add("line", slices, ref_90);
    Plot.addText("90% threshold", slices.length-20, stack_mean * 0.90);
    
    // Show plot
    Plot.show();
    
    // Wait for user to examine plot
    waitForUser("Examine Plot", 
        "Please examine the intensity plot.\n" +
        "Stack mean: " + stack_mean + "\n" +
        "98% threshold: " + (stack_mean * 0.98) + "\n" +
        "95% threshold: " + (stack_mean * 0.95) + "\n" +
        "90% threshold: " + (stack_mean * 0.90) + "\n" +
        "Click OK when ready to set threshold.");
    
    // Get threshold from user
    Dialog.create("Set Threshold");
    Dialog.addNumber("Mean intensity threshold (0.1-0.99):", 0.98, 2, 4, "");
    Dialog.addHelp("Choose a threshold based on the plot.\nValues below (stack_mean * threshold) will be removed.");
    Dialog.show();
    mean_limit = Dialog.getNumber();
    
    // Remove slices below threshold
    slice_removed = 0;
    for (slice = 1; slice <= nSlice; slice++) {
        image_mean = getResult("Mean", slice - 1);
        print(image_mean);
        if (image_mean < (stack_mean * mean_limit)) {
        	print(slice - slice_removed);
            setSlice(slice - slice_removed);
            run("Delete Slice");
            slice_removed++;
        }
    }
    
    // Cleanup
    if (isOpen("Slice Intensity Plot")) {
        selectWindow("Slice Intensity Plot");
        close();
    }
    selectWindow("Results"); 
    run("Close");
    roiManager("reset");
    return slice_removed;
}

// Main execution
timer1 = getTime();
run("Close All");

// Validate directories
validateDirectories();

// Open image sequence
File.openSequence(input_dir);
if (nImages < 1) {
    exit("Error: No images found in input directory");
}

// Process stack
if (stack_clear) {
    slices_removed = cleanStack();
    print(slices_removed + " slices removed");
}

if (stack_horalt) {
    run("Convolve...", "text1=[0.0135 0.061 0.101 0.061 0.0135\n" +
                              "-0.027 -0.122 0.798 -0.122 -0.027\n" +
                              "0.0135 0.061 0.101 0.061 0.0135\n] stack");
    print("Horizontal alteration filter applied");
}

if (stack_veralt) {
    run("Convolve...", "text1=[0.0135 -0.027 0.0135\n" +
                              "0.061 -0.122 0.061\n" +
                              "0.101 0.798 0.101\n" +
                              "0.061 -0.122 0.061\n" +
                              "0.0135 -0.027 0.0135\n] stack");
    print("Vertical alteration filter applied");
}

if (stack_median) {
    run("Median...", "radius=1 stack");
    print("Median filter applied");
}

if (stack_bin) {
    run("Bin...", "x=2 y=2 z=1 bin=Average");
    print("2x2 binning applied");
}

if (stack_align) {
    run("Linear Stack Alignment with SIFT", 
        "initial_gaussian_blur=1.60 " +
        "steps_per_scale_octave=3 " +
        "minimum_image_size=64 " +
        "maximum_image_size=1024 " +
        "feature_descriptor_size=4 " +
        "feature_descriptor_orientation_bins=8 " +
        "closest/next_closest_ratio=0.92 " +
        "maximal_alignment_error=25 " +
        "inlier_ratio=0.05 " +
        "expected_transformation=Translation " +
        "interpolate");
    print("Linear stack alignment applied");
}

// Save results
saveAs("Tiff", output_dir + File.separator + save_name);

// Cleanup and summary
run("Close All");
timer2 = getTime();
timetaken = Math.round((timer2-timer1)/1000);
print("\nExecution Summary:");
print("----------------");
print("Time taken: " + timetaken + " seconds");
print("Source folder: " + input_dir);
print("Saved to: " + output_dir + " as " + save_name);
