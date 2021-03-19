#!/bin/sh
## TAKE AVERAGE OF MEAN_FUNC.NII.GZ FOR EACH TASK BLOCK, TO GENERATE AVERAGE OF TIMECOURSE ACROSS RUNS FOR EACH VOXEL ##

# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories
. $scripts_dir/analysis_parameters
subjects="01 04 05 07 08 09 11 13 15 16 18 19 20 22 25 26 29 30 31 32 33 34 35 37 38"
runfilepath="conditionsGLM.feat/mean_func.nii.gz"
finalfilepath="fixed_conditions_glms/mean_func_across_runs"

for subj in $subjects; do
    subj_dir="$data_dir/sub$subj"
    func_dir="$subj_dir/proc_data/func"
    . $subj_dir/sub_params
    fslmaths $func_dir/block1/conditionsGLM.feat/reg/standard -mul 0 $func_dir/$finalfilepath # initialize final file
    count=0
    for block in $good_blocks; do
        flirt -in $func_dir/block${block}/$runfilepath -ref $func_dir/block${block}/conditionsGLM.feat/reg/standard -init $func_dir/block${block}/conditionsGLM.feat/reg/example_func2standard.mat -out $func_dir/block${block}/tmp.nii.gz -applyxfm # align mean_func to standard
        fslmaths $func_dir/$finalfilepath -add $func_dir/block${block}/tmp $func_dir/$finalfilepath # add each run's mean_func
	rm $func_dir/block${block}/tmp.nii.gz
    ((count++))
    done
    fslmaths $func_dir/$finalfilepath -div $count $func_dir/$finalfilepath # divide by total number of runs
    fslmaths $func_dir/$finalfilepath $func_dir/fixed_conditions_glms_realscr/mean_func_across_runs # copy to realscr glm folder
done
