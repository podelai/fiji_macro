/*
 * Slice_averaging_v3 - Slice averaging for image stack Macro
 * 
 * This macro creates a new stack where each slice is an average intensity projection of a subset of slices from the original stack.
 * 
 * Author: DAUNAS Lucien
 * MRI-EM4Bio BioCampus, CNRS
 * Last modified: 2025-02-12
 */

#@ Integer (label="Number of slices", style="slider", min=1, max=10, stepSize=1) slices_nb 
// User parameter: Defines how many slices to average together for each projection

// Get and store the title of the active image
current_title = getTitle(); 
print(current_title);

// Loop through each slice in the original stack
for (i = 0; i < nSlices; i++) {
    
    print("current slice : " + i);
    selectWindow(current_title);
    
    // For slices near the beginning of the stack
    if (i < slices_nb / 2 + 0.5) { 
        // Average the first 'slices_nb' slices
        param = "start=" + 1 + " stop=" + slices_nb + " projection=[Average Intensity]";
        
    // For slices near the end of the stack
    } else if (i > nSlices - slices_nb / 2 - 1.5){
        // Average the last 'slices_nb' slices
        param = "start=" + (nSlices - slices_nb + 1) + " stop=" + nSlices + " projection=[Average Intensity]";
    
    // For slices in the middle of the stack
    } else {
        // Calculate range centered around current slice
        slice_1 = i - (slices_nb/2) + 1.5;
        slice_2 = i + (slices_nb/2) + 0.5;
        param = "start=" + slice_1 + " stop=" + slice_2 + " projection=[Average Intensity]";
    }
    
    // Run Z-projection with calculated parameters
    run("Z Project...", param);
    // Reselect the original stack for next iteration
    selectWindow(current_title);
}

// Clean up: close the original stack
selectWindow(current_title);
close();

// Combine all generated projections into a new stack
run("Images to Stack", "use");
print("Done");
