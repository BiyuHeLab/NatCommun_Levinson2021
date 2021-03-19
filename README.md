# Analysis code for Levinson & Podvalny et al., 2021, Nature Communications

## Initializing paths
1. Edit directories file to identify your local data, scripts, and software paths.
2. Edit HLTP_paths.m similarly.


## Subject-specific analysis pipeline
### Preprocessing
1. In MATLAB run Behavior/HLTP_process_behavior. This will generate various summaries of the behavioral data, but most importantly a series of event (EV) files for use in later analyses.
2. In a terminal run Preprocessing/HLTP_preprocess.sh XX, where XX is a two-digit subject code, to generate preprocessed functional data, freesurfer surface reconstruction, and retinotopy.
3. Manually inspect components in FSL's MELODIC ICA output, and record the indices of bad components for each task block in a copy of 'bad_components.xls'. To remove these components from the preprocessed data, edit and run Preprocessing/HLTP_ICA.m in MATLAB.
### General Linear Model
1. In a terminal run GLM/HLTP_runGLM.sh XX to generate all GLM analyses.
2. Once all subjects are completed, run the VTC section of Align/align_roi_to_anatomical, as well as Align/create_roi_loc to define category-selective ROIs. Run Align/align2highres to register data to anatomical space, in preparation for MVPA.
### Retinotopy
1. To manually inspect and define retinotopic ROIs, edit and run Retinotopy/open_retinotopy_suma_command.
2. In a terminal run Align/ret_rois_to_nifti.sh XX to convert retinotopic ROIs to nifti format in functional, anatomical, and standard spaces.
### Multivariate pattern analysis
1. Edit parameters in HPC_MVPA/HLTP_call_MVPA_betas_HPC_parallel.m and HPC_MVPA/matlab_betas_parallel.bash, then submit matlab_betas_parallel.bash XX as a job on a high-performance computing cluster. For the main ROI analysis (Figure 4), group-level GLM analyses must have already been completed.
2. Repeat for HPC_MVPA/loc/loc_mvpa_6mm_HPC_parallel.m and HPC_MVPA/loc/matlab_loc_mvpa_6mm_parallel.bash.


## Group-level analysis pipeline
### General Linear Model
1. Open GLM/HLTP_runGLM_group_fixed.sh and follow the included instructions, then run it several times in a terminal as sh HLTP_runGLM_group_fixed.sh GLMTYPE, where GLMTYPE = anova_real, anova_realscr, anova_scr, or trialtypes.
2. Register the resulting clusters into each subject's anatomical space, to prepare for MVPA. Run Align/align_roi_to_anatomical then GLM/split_thalamus_bg.
### Multivariate pattern analysis
1. Align searchlight-based decoding results to standard space using Align/align_mvpa_2standard.sh.
2. In MATLAB, edit and run MVPA_stats/HLTP_groupMVPA_stats.m, MVPA_stats/HLTP_groupMVPA_stats_perm.m, and MVPA_stats/HLTP_groupMVPA_stats_perm_rec_unrec.m to perform statistics on searchlight analyses. To generate final statistical brain maps, threshold the group-averaged brain map by the output TFCE_T statistic. e.g.
```
fslmaths group_avg.nii -thr TFCE_critical_stat group_avg_thresholded.nii
```
3. In MATLAB, edit and run MVPA_stats/HLTP_groupMVPA_stats_ROI.m to perform statistics on ROI-based analyses.
