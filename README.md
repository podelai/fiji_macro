# Macro_ijm
imageJ script library for biology image analysis

Incredible_Split_Merge_Macro_v2.3.ijm

    Function that Ask the user a source folder that contain images, the extension files to import, and the output folder were the final image will be saved.
    1.import only images with correct extension
    2. Split and merge channels
    3. Save the merged image as tiff


MoHi - Motion Highlighting

    This macro creates a time-delayed version of an image stack and calculates
    the average between the original and delayed stacks to reveal movement patterns.
    The resulting output shows areas of consistency and change between frames separated by the specified delay, useful for motion analysis.


Noise2Void_rdm_mask - random mask extractor like Noise2Void

    This script is an illustration of the Noise2Void strategy 
    hide random pixel of an image and extract thoses pixel to a new image with black background


Rdm_patch_extractor - Random patch extractor

    Macro to extract random 128x128 patches from random slices in an image stack


Slice_averaging_v3 - Slice averaging for image stack Macro

    This macro creates a new stack where each slice is an average intensity projection of a subset of slices from the original stack.


ssIP_vEM_v3 - Simple single Image Processing for volume electron microscopy image stack Macro

    This macro performs various image processing operations on single images before stacking them :
    - 8-bit conversion for size reduction
    - directionnal alteration correction using custom convolution kernels
    - Median filtering for noise reduction
    - 2x2 binning for size reduction


stackIP_vEM_v8 - Stack Image Processing for volume Electron microscopy

    This macro performs various image processing operations on stack image :
    - slice clearing
    - 8-bit conversion for size reduction
    - directionnal alteration correction using custom convolution kernels
    - Median filtering for noise reduction
    - 2x2 binning for size reduction
