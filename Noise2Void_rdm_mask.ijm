/*
 * Noise2Void_rdm_mask : random mask extractor like Noise2Void
 * 
 * This script is an illustration of the Noise2Void strategy 
 * hide random pixel of an image and extract thoses pixel to a new image with black background
 *
 * Author: DAUNAS Lucien
 * MRI-EM4Bio BioCampus, CNRS
 * Last modified: 2025-02-12
 */



// User parameter: Controls how many random pixel patches will be masked and the size of each square mask
#@ Integer (label="number of mask", style="slider", min=0, max=500, stepSize=1) mask_nb
#@ Integer (label="size of the mask", style="slider", min=0, max=4, stepSize=1) mask_size


// Convert current image to 8-bit
run("8-bit");

// Get the dimensions of the current image
width = Image.width; height = Image.height

// Clear any existing ROIs
roiManager("reset")

// Create random square selections across the image
for (i = 0; i < mask_nb; i++) {
    // Generate random x,y coordinates within image bounds
    x = floor(random*width);
    y = floor(random*height);
    print("x=" + x + " y=" + y);
    
    // Create a square selection at those coordinates
    makeRectangle(x, y, mask_size, mask_size);
    
    // Add the selection to ROI Manager
    roiManager("add")
}


// Combine all ROIs into a single selection
roiManager("combine");

// Create two duplicate images
run("Duplicate...", "title=off");
run("Duplicate...", "title=on");

// Process the "off" image - highlight the selected pixels (add 250 to their value)
selectWindow("off");
run("Add...", "value=250");
run("Select None");
roiManager("reset");

// Process the "on" image - invert the selection and highlight everything else
selectWindow("on");
run("Make Inverse");
run("Add...", "value=250");
run("Select None");
roiManager("reset");
