/*
* MoHi - Motion Highlighting
* 
* This macro creates a time-delayed version of an image stack and calculates
* the average between the original and delayed stacks to reveal movement patterns.
* 
* The resulting output shows areas of consistency and change between frames
* separated by the specified delay, useful for motion analysis.
* 
* Author: DAUNAS Lucien
* MRI-EM4Bio BioCampus, CNRS
* Last modified: 2025-02-12
*/

#@ Integer (label="delay", min=1, max=100, value=100) delay
// User parameter: Controls the time offset between frames (in number of slices)

// Create two copies of the original stack
run("Duplicate...", "title=clock duplicate");
run("Duplicate...", "title=delayed duplicate");

// Store the number of slices in the original stack
n = nSlices;

// Modify the "delayed" stack to create the time offset:

// Go to the end of the stack
setSlice(n);

// Add empty slices at the end (padding)
for (i = 0; i < delay; i++) {
   run("Add Slice");
}

// Go to the beginning of the stack
setSlice(1);

// Delete the first 'delay' slices to create the time offset
for (i = 0; i < delay; i++) {
   run("Delete Slice");
}

// Invert the pixel values in the delayed stack
run("Invert", "stack");

// Calculate the average between the original and delayed (inverted) stacks
// This creates a new stack that reveals differences between time-delayed frames
imageCalculator("Average create stack", "clock","delayed");

// Clean up: remove the extra padding slices that were added
setSlice(n);
for (i = 0; i < delay; i++) {
   run("Delete Slice");
}

// Commented-out alternative operations that could be used instead of Average:
//imageCalculator("Add create 32-bit stack", "clock","delayed");
//imageCalculator("Subtract create stack", "delayed","clock");
//imageCalculator("Difference create stack", "clock","delayed");
//imageCalculator("Subtract create stack", "1","delayed-2");
