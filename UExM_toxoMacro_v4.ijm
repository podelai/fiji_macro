/*
 * Macro: UExM_toxoMacro_v3
 * Description: Extracts a specific Z-slice from a composite image, 
 * processes three channels with specific LUTs/Contrast, 
 * and saves individual and merged outputs as both Raw and RGB TIFFs.
 * * Instructions:
 * 1. Import your image manually (drag and drop), select color mode: composite.
 * 2. Identify the desired Z-slice index.
 * 3. Run script and provide the saving directory and slice number.
 */

#@ File (label = "Save Image directory", style = "directory") main_save_folder 
#@ String (label = "Slice number", value = "10") slice_nb

#@ String (label = "C1 label name", value = "Comp") C1_label_name
#@ String (label = "C2 label name", value = "Nd6") C2_label_name
#@ String (label = "C3 label name", value = "Tub") C3_label_name

#@ String (label = "C1 LUT", choices={"Red", "Green", "Blue", "Cyan", "Magenta", "Yellow"}, style="radioButtonHorizontal") C1_LUT
#@ String (label = "C2 LUT", choices={"Red", "Green", "Blue", "Cyan", "Magenta", "Yellow"}, style="radioButtonHorizontal") C2_LUT
#@ String (label = "C3 LUT", choices={"Red", "Green", "Blue", "Cyan", "Magenta", "Yellow"}, style="radioButtonHorizontal") C3_LUT

#@ String (label = "C1 min intensity", value = "10") C1_min
#@ String (label = "C1 max intensity", value = "2000") C1_max

#@ String (label = "C2 min intensity", value = "10") C2_min
#@ String (label = "C2 max intensity", value = "2000") C2_max

#@ String (label = "C3 min intensity", value = "10") C3_min
#@ String (label = "C3 max intensity", value = "2000") C3_max


#@ boolean (label = "Close images at the end") close_images

// Speed up execution by hiding image windows
//setBatchMode(true);

// Get the name of the freshly imported image
current_title = getTitle(); 

// Robust extension removal (works for .czi, .tif, .lif, etc.)
dot_index = lastIndexOf(current_title, ".");
if (dot_index != -1) {
    title_wo_ext = substring(current_title, 0, dot_index);
} else {
    title_wo_ext = current_title;
}

// Create output directory if it doesn't exist
save_path = main_save_folder + File.separator + title_wo_ext;
if (!File.exists(save_path)) {
    File.makeDirectory(save_path);
}

// Extract the chosen slice using Average Intensity projection
run("Z Project...", "start=" + slice_nb + " stop=" + slice_nb + " projection=[Average Intensity]");
avg_title = getTitle();
run("Split Channels");

// Define channel processing to avoid code repetition
processChannel("C1-" + avg_title, C1_LUT, C1_label_name, C1_min, C1_max);
processChannel("C2-" + avg_title, C2_LUT, C2_label_name, C2_min, C2_max);
processChannel("C3-" + avg_title, C3_LUT, C3_label_name, C3_min, C3_max);

/////////////////////////////////////// Merge Section ///////////////////////////////////////

// Merging three channels using the saved filenames
merg_arg = "c1=[" + title_wo_ext + "_" + C1_label_name + "_s" + slice_nb + ".tiff] " +
           "c2=[" + title_wo_ext + "_" + C2_label_name + "_s" + slice_nb + ".tiff] " +
           "c3=[" + title_wo_ext + "_" + C3_label_name + "_s" + slice_nb + ".tiff] create";

run("Merge Channels...", merg_arg);

// Save the raw merged composite
save_merged = save_path + File.separator + title_wo_ext + "_Merged_s" + slice_nb + ".tiff";
saveAs("Tiff", save_merged);

// Generate and save RGB version with Scale Bar
run("RGB Color");
run("Scale Bar...", "width=2 height=2 thickness=2 bold hide overlay"); // Add 2um scale bar
save_merged_rgb = save_path + File.separator + title_wo_ext + "_Merged_s" + slice_nb + "_RGB.tiff";
saveAs("Tiff", save_merged_rgb);

// Clean up
if (close_images) {
    run("Close All");
}

//setBatchMode(false);
updateDisplay();

/**
 * Function to handle LUT, Contrast, and Saving for individual channels
 */
function processChannel(imgName, lutColor, suffix, min, max) {
    selectImage(imgName);
    run(lutColor);
    setMinAndMax(min, max);
    
    // Save Raw Tiff
    raw_path = save_path + File.separator + title_wo_ext + "_" + suffix + "_s" + slice_nb + ".tiff";
    saveAs("Tiff", raw_path);
    
    // Save RGB Tiff
    run("Duplicate...", "duplicate");
    run("RGB Color");
    rgb_path = save_path + File.separator + title_wo_ext + "_" + suffix + "_s" + slice_nb + "_RGB.tiff";
    saveAs("Tiff", rgb_path);
    close(); // Close the RGB duplicate to keep workspace clean
}