#!/bin/sh
# runs AFNI RetinoProc command to create visual field maps from wedge + ring retinotopy data
# requires freesurfer surface reconstruction


$AFNIDIR/@RetinoProc -sid sub -TR 2 -period_ecc 48 -period_pol 48 -pre_ecc 0 -pre_pol 0 -nrings 1 -nwedges 1 -fwhm_pol 5 -fwhm_ecc 5 -no_tshift \
-ccw ${anal_dir}/func/wedge_ccw/wedge_ccw_ts_warped+orig \
-clw ${anal_dir}/func/wedge_cw/wedge_cw_ts_warped+orig \
-exp ${anal_dir}/func/ring_exp/ring_exp_ts_warped+orig \
-con ${anal_dir}/func/ring_con/ring_con_ts_warped+orig \
-anat_vol ${anal_dir}/anat/divt1pd.nii.gz \
-surf_vol ${anal_dir}/anat/freesurfer/sub/surf/SUMA/sub_SurfVol+orig.HEAD \
-spec_right ${anal_dir}/anat/freesurfer/sub/surf/SUMA/sub_rh.spec -spec_left ${anal_dir}/anat/freesurfer/sub/surf/SUMA/sub_lh.spec \
-out_dir ${anal_dir}/func/wedgering_warped
