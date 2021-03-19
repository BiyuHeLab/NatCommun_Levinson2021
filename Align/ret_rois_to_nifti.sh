#!/bin/sh
## CONVERT RETINOTOPY ROIS TO NIFTI FORMAT ##
## FIRST NIFTI OUTPUT IS ALIGNED TO 2MM ANATOMICAL SPACE ##


# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories # point to location of 'directories' file
. $scripts_dir/analysis_parameters

subj=$1 #subject number is input with syntax: sh ret_rois_to_nifti.sh XX
subj_dir=$data_dir/sub$subj
proc_dir=$subj_dir/proc_data
roi_dir=$proc_dir/anat/rois/retinotopy
mkdir $roi_dir
suma_dir=$proc_dir/anat/freesurfer/sub/surf/SUMA

# Session-specific details
. $subj_dir/sub_params

tcsh -c setenv AFNI_NIML_TEXT_DATA YES

for roi in $visual_rois; do
    if [[ $roi = *"rh"* ]]; then
        hemi=rh
    else
        hemi=lh
    fi
    3dSurf2Vol -spec $suma_dir/sub_${hemi}.spec -surf_A $suma_dir/${hemi}.smoothwm.asc -surf_B $suma_dir/${hemi}.pial.asc -grid_parent $proc_dir/anat/divt1pd_brain_2mm.nii -sv $suma_dir/sub_SurfVol_acor_ns_centre_AInd_Exp+orig. -sdata_1D $suma_dir/${roi}.1D.dset -map_func mode -f_steps 10 -prefix $suma_dir/${roi}
    3dAFNItoNIFTI -prefix $roi_dir/${roi}.nii.gz $suma_dir/${roi}+orig.
    fslreorient2std $roi_dir/${roi}.nii.gz $roi_dir/${roi}.nii.gz
    flirt -in $roi_dir/${roi}.nii.gz -ref $proc_dir/func/block1/block1_preproc.feat/reg/standard -init $proc_dir/func/block1/block1_preproc.feat/reg/highres2standard.mat -out $roi_dir/${roi}_standard -applyxfm
    fslmaths $roi_dir/${roi}_standard -thr 0.7 -bin $roi_dir/${roi}_standard
done

merge_rois="2 3"
hemis="rh lh"
for r in $merge_rois; do
    for h in $hemis; do
        fslmaths $roi_dir/${h}V${r}v -add $roi_dir/${h}V${r}d -bin $roi_dir/${h}V${r}
        fslmaths $roi_dir/${h}V${r}v_standard -add $roi_dir/${h}V${r}d_standard -bin $roi_dir/${h}V${r}_standard
    done
done
