/*
* DoG - Difference of Gaussian
* 
* This macro creates a Difference of Gaussian filtered image by:
* 1. Applying Gaussian blur with two different sigma values
* 2. Subtracting the more blurred image from the less blurred one
* This filter is useful for edge detection and feature enhancement
* 
* Author: DAUNAS Lucien
* MRI-EM4Bio BioCampus, CNRS
* Last modified: 2025-02-12
*/

// User parameters: Control the standard deviation (sigma) values for the two Gaussian blurs
// sigma_a: Smaller sigma value creates less blurring
// sigma_b: Larger sigma value creates more blurring
#@ Integer (label="Sigma A", min=1, max=100, value=4) sigma_a
#@ Integer (label="Sigma B", min=1, max=100, value=16) sigma_b

// Create a duplicate of the active image to work with
run("Duplicate...", " ");
rename("a");

// Apply first Gaussian blur with sigma_a (smaller sigma value)
run("Gaussian Blur...", "sigma=" + sigma_a);

// Create another duplicate of the first blurred image
run("Duplicate...", " ");
rename("b");

// Apply second Gaussian blur with sigma_b (larger sigma value)
run("Gaussian Blur...", "sigma=" + sigma_b);

// Subtract the more blurred image (b) from the less blurred image (a)
// This enhances edges at scales between sigma_a and sigma_b
imageCalculator("Difference create", "a","b");

// Clean up by closing the intermediate images
selectWindow("a"); close();
selectWindow("b"); close();
