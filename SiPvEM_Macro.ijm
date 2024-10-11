#@ File (label="Input directory", style="directory", description="location of the image sequence") input_dir
#@ File (label="Output directory", style="directory", description= "target directory to save processed stack") output_dir
#@ String (label="save name", description="Name field") save_name

#@ Double (value=0.98, min=0.1, max=0.99, stepSize=0.01, persist=false, style="scroll bar", description="Your name") limit
#@ boolean (label="process stack binning 2x2" ) stack_bin
#@ boolean (label="process stack alignement" ) stack_align

/////////////////////////////////////////////////
timer1 = getTime(); //timer intialisation 
run("Close All"); // close all images open
setBatchMode("hide"); //Batch mode
/////////////////////////////////////////////////

File.openSequence(input_dir);


run("Set Measurements...", "modal stack redirect=None decimal=0");

run("Specify...", "width=4096 height=4096 x=2048 y=2048 slice=1 centered");
roiManager("Add");
roiManager("multi-measure measure_all");

plot="False"

if (plot=="True") {
	Plot.create("Plot of Results", "Slice", "Mode");
	Plot.add("Separated Bars", Table.getColumn("Slice", "Results"), Table.getColumn("Mode", "Results"));
	Plot.setStyle(0, "blue,#a0a0ff,1.0,Separated Bars");
}

run("Summarize");

mean = getResult("Mode", nSlices); //print("mean : " + mean);

slice_removed = 0;

for (slice = 1; slice <= nSlices; slice+=1) {

	mode = getResult("Mode", slice - 1);
	
	if(mode < (mean*limit)){
		setSlice(slice - slice_removed); run("Delete Slice");

		slice_removed = slice_removed + 1;
		}
}
selectWindow("Results"); run("Close"); close("ROI Manager");
print(slice_removed + " slices removed");

run("Convolve...", "text1=[0.0135 0.061 0.101 0.061 0.0135\n-0.027 -0.122 0.798 -0.122 -0.027\n0.0135 0.061 0.101 0.061 0.0135\n] stack"); print("Horalt filter applied");

run("Median...", "radius=1 stack"); print("Median filter applied");

if (stack_bin==1) { run("Bin...", "x=2 y=2 z=1 bin=Average"); print("binning 2x2 applied");}

if (stack_align==1) {
	run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Translation interpolate");
	print("Linear stack alignement applied");
}



saveAs("Tiff", output_dir + File.separator + save_name);

run("Close All"); // close all images open
//execution summary
print("Finished");
timer2 = getTime();
timetaken = Math.round((timer2-timer1)/1000) ;
print("Time taken :" + timetaken + "sec");
print("Source folder : " + input_dir);
print("Saved to: " + output_dir + " as " + save_name);

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////v/////////////////////////////////////////////// Lucien DAUNAS 30.03.2023 //
///////////////////////////////////////////////////////////////////////////////////////////////////