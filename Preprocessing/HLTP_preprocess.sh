#!/bin/sh
###### HLTP DAY 1 PREPROCESSING ######

# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories
. $scripts_dir/analysis_parameters
source $FREESURFER_HOME/SetUpFreeSurfer.sh

subj=$1 #subject number is input with syntax: sh HLTP_preprocess_day1.sh XX
subj_dir="$data_dir/sub$subj"
anal_dir="$subj_dir/proc_data"

# Session-specific details
. $subj_dir/sub_params
 

#######################################################
#### PREPARE RETINOTOPY FOLDER ####
#######################################################

if $prfscan; then
    cp -R "$scripts_dir/Retinotopy/Scripts/" "$anal_dir/func/prf/"
    sed -i "s/^set subj.*/set subj = $subj/" $anal_dir/func/prf/Scripts/omniVariables #prepares omniVariables with subject's initials
fi


#######################################################
############ PREPARE FOR FSL PREPROCESSING ############
#######################################################

### Anatomical Processing
if $t1scan; then
#Step 1: skull-strip t1 and pd and co-register (align), then smooth pd
    $FSLDIR/bin/bet $anal_dir/anat/t1/t1.nii* $anal_dir/anat/t1/t1_brain.nii -f $f -g $g -m # HLTP defaults f=0.5, g=0.18
    $FSLDIR/bin/bet $anal_dir/anat/pd/pd.nii* $anal_dir/anat/pd/pd_brain.nii -f $f -g $g
    $FSLDIR/bin/flirt -in $anal_dir/anat/pd/pd_brain.nii* -ref $anal_dir/anat/t1/t1_brain.nii -out $anal_dir/anat/pd/pd_brain_aligned.nii
    $FSLDIR/bin/fslmaths $anal_dir/anat/pd/pd_brain_aligned.nii* -s $s -thr $min_pd $anal_dir/anat/pd/pd_brain_smooth.nii # also remove any voxels with intensity < min_pd (default 1), to avoid hugely intense voxels in t1/pd image below

#Step 2: Divide t1 by pd and multiply result by mean(pd) to return voxel intensity to normal levels. Mask divt1pd output with all pd brain voxels > 100 to remove noisy voxels
    pdmean=$($FSLDIR/bin/fslstats $anal_dir/anat/pd/pd_brain_smooth.nii* -M)
    $FSLDIR/bin/fslmaths $anal_dir/anat/t1/t1_brain.nii* -div $anal_dir/anat/pd/pd_brain_smooth.nii* -mul $pdmean $anal_dir/anat/divt1pd_brain.nii
    fslmaths $anal_dir/anat/pd/pd_brain_aligned.nii* -thr $pd_mask_threshold -bin $anal_dir/anat/pd/pd_brain_mask.nii
    fslmaths $anal_dir/anat/divt1pd_brain.nii* -mas $anal_dir/anat/pd/pd_brain_mask.nii* $anal_dir/anat/divt1pd_brain.nii

#Step 3: remove brain from t1, then add t1/pd brain
    $FSLDIR/bin/fslmaths $anal_dir/anat/t1/t1_brain_mask.nii* -add 1 -uthr 1 $anal_dir/anat/t1/t1_skull_mask.nii # creates mask of non-brain
    $FSLDIR/bin/fslmaths $anal_dir/anat/t1/t1.nii* -mas $anal_dir/anat/t1/t1_skull_mask.nii* $anal_dir/anat/t1/t1_skull.nii # removes brain from t1
    $FSLDIR/bin/fslmaths $anal_dir/anat/t1/t1_skull.nii* -add $anal_dir/anat/divt1pd_brain.nii* $anal_dir/anat/divt1pd.nii # adds t1/pd brain to t1

#Step 4: Make 2mm brain mask for use in MVPA analyses
    $FSLDIR/bin/flirt -in $anal_dir/anat/divt1pd_brain.nii* -ref $anal_dir/anat/divt1pd_brain.nii* -out $anal_dir/anat/divt1pd_brain_2mm.nii -applyisoxfm 2
    $FSLDIR/bin/fslmaths $anal_dir/anat/divt1pd_brain_2mm.nii* -bin $anal_dir/anat/divt1pd_brain_2mm_mask.nii
    $FSLDIR/bin/fslchfiletype NIFTI $anal_dir/anat/divt1pd_brain_2mm_mask

#Step 5: create synthetic T2-weighted image for helping surface reconstruction
#TR 20 ms, flip angle 30 deg, TE 5 ms (these are defaults)
    $FREESURFER_HOME/bin/mri_convert $anal_dir/anat/t1/t1.nii* $anal_dir/anat/t1/t1.mgz
    $FSLDIR/bin/flirt -in $anal_dir/anat/pd/pd.nii* -ref $anal_dir/anat/t1/t1.nii* -out $anal_dir/anat/pd/pd_aligned.nii
    $FREESURFER_HOME/bin/mri_convert $anal_dir/anat/pd/pd_aligned.nii* $anal_dir/anat/pd/pd_aligned.mgz
    $FREESURFER_HOME/bin/mri_synthesize -w 20 30 5 $anal_dir/anat/t1/t1.mgz $anal_dir/anat/pd/pd_aligned.mgz $anal_dir/anat/flash.mgz
fi

#Step 6: run surface reconstruction using freesurfer
SUBJECTS_DIR=$anal_dir/anat/freesurfer
mkdir $SUBJECTS_DIR
$FREESURFER_HOME/bin/recon-all -subject sub -i $anal_dir/anat/divt1pd.nii* -all -cw256 -T2 $anal_dir/anat/flash.mgz -T2pial


### Functional Processing
if $locscan; then
    # set up and run localizer preprocessing in FSL
    cp $scripts_dir/feat_designs/loc_preproc_design.fsf $anal_dir/func/loc/loc_preproc_design.fsf
    sed -i -e "s#ANALDIR#${anal_dir}#g" $anal_dir/func/loc/loc_preproc_design.fsf
    sed -i -e "s#FSLDIR#${FSLDIR}#g" $anal_dir/func/loc/loc_preproc_design.fsf
    cd $anal_dir/func/loc
    $FSLDIR/bin/feat loc_preproc_design.fsf #runs preprocessing
fi

#run retinotopy processing
if $prfscan; then
    cd $anal_dir/func/prf/Scripts
    tcsh HLTP_ret_analysis
fi
if $wedge_cwscan; then
    cd $scripts_dir/Retinotopy
    . $scripts_dir/Retinotopy/HLTP_retinoproc.sh
fi

#run main task processing
for i in $(seq 1 $block_iter); do
    block_dir=$anal_dir/func/block$i

    cp $scripts_dir/feat_designs/HLTP_preproc_design.fsf $block_dir/HLTP_preproc_design.fsf
    sed -i -e "s#BLOCKDIR#${block_dir}#g" $block_dir/HLTP_preproc_design.fsf
    sed -i -e "s#ANALDIR#${anal_dir}#g" $block_dir/HLTP_preproc_design.fsf
    sed -i -e "s/BNUM/${i}/g" $block_dir/HLTP_preproc_design.fsf
    sed -i -e "s#FSLDIR#${FSLDIR}#g" $block_dir/HLTP_preproc_design.fsf
    cd $block_dir
    feat "HLTP_preproc_design.fsf"
    rm HLTP_preproc_design.fsf
done

