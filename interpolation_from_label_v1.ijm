/*
 * interpolation_accuracy - Compare accuracy of interpolation on binary image stack Macro
 * 
 * This ImageJ macro processes a binary image stack to compare accuracy of interpolation.
 *
 * Description:
 * 1.  Initialization:
 * -   Gets the width, height, and number of slices of the input image.
 * -   Renames the input image to "raw".
 *
 * 2.  ROI Detection and Management:
 * -   Iterates through the slices with a step of 10.
 * -   For each slice:
 * -   Sets the active slice.
 * -   Creates a selection based on the image content (e.g., thresholding).
 * -   Checks if a selection was successfully created.
 * -   If a selection exists (selectionType() != -1), it's added to the ROI Manager.
 * -   If no selection exists, prints a message to the log.
 * -   Deselects any existing selection.
 * -   Selects all ROIs in the ROI Manager.
 * -   Interpolates the ROIs across the slices to create a smooth transition.
 *
 * 3.  Image Interpolation and Processing:
 * -   Creates a new black image stack named "interpolated" with the same dimensions and number of slices as the original.
 * -   Gets the number of ROIs in the ROI Manager.
 * -   Iterates through the ROIs:
 * -   Sets the active slice.
 * -   Selects the corresponding ROI in the ROI Manager.
 * -   Fills the selected ROI with the foreground color in the "interpolated" image. This effectively draws the interpolated ROI onto the black image.
 * -   Converts the "interpolated" image to binary (black background).
 * -   Calculates the difference between the "raw" image and the "interpolated" image, creating a new stack named "difference".
 * -   Subtracts 254 from each pixel in the "difference" image stack.  This likely assumes that the original foreground color was 255 (white), and this step highlights the differences.
 *
 * 4.  Final Image Adjustments and Output:
 * -   Selects the "raw" image.
 * -   Subtracts 254 from each pixel in the "raw" image stack (same as for "difference").
 * -   Adds 1 to each pixel in the "raw" image stack.
 * -   Multiplies each pixel in the "raw" image stack by 2.  These steps likely normalize or enhance the original image for better comparison with the difference image.
 * -   Calculates the difference between the modified "raw" image and the "difference" image, creating a new stack.  This is the final result.
 * -   Applies the "glasbey on dark" color table to the result image for better visualization.
 * -   Renames the result image to "result".
 * -   Closes the "difference" and "interpolated" images to clean up.
 *
 * Notes:
 * -   This macro assumes that the input image is already open.
 * -   The `getWidth()`, `getHeight()`, `nSlices()`, `setSlice()`, `run()`, `selectionType()`, `roiManager()`, `newImage()`, and `imageCalculator()` functions are ImageJ macro functions.
 * -   The specific thresholding or selection method used by `run("Create Selection")` is not defined in this macro.  It will depend on the image content and the ImageJ setup.
 * -   The value 254 is subtracted, suggesting the original foreground color is 255.
 * -   The macro uses a slice increment of 10, meaning it analyzes every 10th slice.  This can be adjusted.
 * -  The macro uses "8-bit black" for the interpolated image.  The bit depth and initial color can be changed if needed.
 * 
 * Author: DAUNAS Lucien
 * MRI-EM4Bio BioCampus, CNRS
 * Last modified: 2025-05-12
 */

 

#@ Integer (label="resolution ratio", style="slider", min=1, max=20, stepSize=1) resolution_ratio 

// Get image dimensions and number of slices.
width = getWidth();
height = getHeight();
slices = nSlices();

// Rename the original image to "raw".
rename("raw");

// Iterate through slices, create selections, and add them to the ROI Manager.
for (i = 1; i < slices; i += resolution_ratio) {
    setSlice(i); // Set the current slice.
    run("Create Selection"); // Create a selection on the current slice.  The method used here depends on the image.

    if (selectionType() != -1) { // Check if a selection was created (returns -1 if no selection).
        roiManager("Add"); // Add the selection to the ROI Manager.
    } else {
        print(" - No object found on slice " + i); // Print a message if no selection was created.
    }
}

run("Select None"); // Deselect all selections.
run("Select All"); // Select all ROIs in the ROI Manager.
roiManager("Interpolate ROIs"); // Interpolate the ROIs between slices.

// Create a new black image stack for the interpolated ROIs.
newImage("interpolated", "8-bit black", width, height, slices);

// Fill the interpolated ROIs on each slice of the "interpolated" image.
max = roiManager("size"); // Get the number of ROIs.
for (i = 1; i <= max; i++) { // Loop through the ROIs.  Note the change to <= to include the last ROI.
    setSlice(i);
    roiManager("Select", i - 1); // Select the i-th ROI (ROIs are 0-indexed).
    roiManager("Fill"); // Fill the selected ROI with the current foreground color.
}
run("Make Binary", "background=Dark black"); // Convert the "interpolated" image to binary.

// Calculate the difference between the original and interpolated images.
imageCalculator("Difference create stack", "raw", "interpolated");
rename("difference");
run("Subtract...", "value=254 stack"); // Subtract 254 from the difference image.

// Modify the original image.
selectImage("raw");
run("Subtract...", "value=254 stack");
run("Add...", "value=1 stack");
run("Multiply...", "value=2 stack");

// Calculate the difference between the modified original image and the difference image.
imageCalculator("Subtract create stack", "raw", "difference");

// Apply a color table and rename the result.
run("glasbey on dark");
rename("result");

// Close intermediate images.
selectImage("difference");
close();
selectImage("interpolated");
close();
