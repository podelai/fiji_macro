/*
 * Rdm_patch_extractor - Random patch extractor
 * 
 * Macro to extract random 128x128 patches from random slices in an image stack
 * 
 * Author: DAUNAS Lucien
 * MRI-EM4Bio BioCampus, CNRS
 * Last modified: 2025-02-12
 */

#@ File (label="Select input stack", style="file") input_file
#@ File (label="Select output directory", style="directory") output_dir
#@ Integer (label="Number of patches to extract", min=1, max=1000, value=10) num_patches
// Option to handle resliced data differently - applies specific scaling if checked
#@ Boolean (label="Is the dataset resliced?", value=false) is_resliced


// Open the image stack
open(input_file);

// If the dataset is resliced, perform special processing
if (is_resliced) {
   // First downscale in y dimension to 64px height (preserving x and z dimensions)
   run("Scale...", "x=1.0 y=0.25 z=1.0 width=256 height=64 depth=256 interpolation=None process create");
   // Then upscale back to 256px height using bilinear interpolation for smoother results
   run("Scale...", "x=1.0 y=4 z=1.0 width=256 height=256 depth=256 interpolation=Bilinear process create");
}

// Store the ID of the current image for reference
stack_id = getImageID();

// Get dimensions of the current stack
getDimensions(width, height, channels, slices, frames);

// Extract random patches
for (i = 1; i <= num_patches; i++) {
   // Select a random slice from the stack
   random_slice = floor(random() * slices) + 1;
   setSlice(random_slice);
   
   // Calculate random starting coordinates, ensuring the 128x128 patch fits within image bounds
   x_start = floor(random() * (width - 128));
   y_start = floor(random() * (height - 128));
   
   // Create a selection for the patch
   makeRectangle(x_start, y_start, 128, 128);
   
   // Duplicate the selection as a new image
   run("Duplicate...", "title=patch_" + i);
   
   // Save the patch with filename including patch number and source slice
   patch_filename = output_dir + File.separator + "patch_" + i + "_slice_" + random_slice + ".tif";
   saveAs("Tiff", patch_filename);
   close();
   
   // Return to the original stack for next iteration
   selectImage(stack_id);
}

// Close all open images
close("*");

// Print summary information
print("Extracted " + num_patches + " random patches.");
print("from : " + input_file);
print("to : " + output_dir);
