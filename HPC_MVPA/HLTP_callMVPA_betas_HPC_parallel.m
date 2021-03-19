function HLTP_callMVPA_betas_HPC_parallel(subj)
% calls MVPA using The Decoding Toolbox, on GLM outputs from HLTP fMRI task
% make edits to below parameters for a particular decoding analysis
% finally calls HLTP_runDecoding.m, which in turn calls TDT functions


%% REQUIRED PARAMETERS
data_dir = ; % PATH TO MAIN DATA DIRECTORY
subdir = [data_dir, '/sub', subj]; % PATH TO SUBJECT'S DATA DIRECTORY
timepoint = 'betas'; % 'betas' if using GLM parameter estimates
custom = 'roi_betas_reccategories_responsecat_realscrGLM_libsvm_norm'; % details about this particular analysis,
    % to use in naming results directory
classes = [1:4:15]; % PE numbers to use
    % [1:2:15] = condition betas; [17:2:31] = condition_realscr scrambled betas
    % every other PE is a temporal derivative, which is why we skip them
    % in order the PEs are rec animal, unrec animal, rec face, unrec face,
    % rec house, unrec house, rec object, unrec object.
inputname = 'conditions_realscrGLM.feat'; % .feat directory to pull PEs from
scripts_dir = ; % PATH TO SCRIPTS DIRECTORY
response_cat = 0; % if we are using betas from response category (1) or from stim category (0)
    
%% INITIALIZE
cd(scripts_dir)
HLTP_paths

clear cfg
cfg = decoding_defaults;
analdir = [subdir, '/proc_data/func/mvpa'];
mkdir(analdir);
cfg.analdir = analdir;
cfg.subdir = subdir;
cfg.inputname = inputname;
cfg.tp = timepoint;
cfg.custom = custom;
cfg.classes = classes;
cfg.files.response_cat = response_cat;

%% OPTIONAL PARAMETERS

% if decoding on beta images, set the following parameters
cfg.beta_suffix = '_2highres.nii'; % suffix of beta images to use
cfg.conditions = 'cat'; % decoding category or recognition status? 'cat' or 'rec'

%cfg.good_blocks = [1:15]; % if different from in sub_params file
cfg.design.unbalanced_data = 'ok'; % use if classes are unbalanced
cfg.results.output = {'balanced_accuracy', 'decision_values', 'predicted_labels', 'confusion_matrix'}; % default is accuracy_minus_chance
    % options: see decoding_transform_results.m and [toolbox]/

%searchlight parameters
cfg.analysis = 'ROI'; % wholebrain, ROI, or searchlight

% searchlight parameters, use only if performing searchlight analysis
%cfg.searchlight.unit = 'voxels'; % voxels or mm
%cfg.searchlight.radius = 3; % 3 voxel radius = 6mm
%cfg.files.mask = [subdir, '/proc_data/anat/divt1pd_brain_2mm_mask.nii'];

% roi parameters, use only if performing ROI analysis
% roifiles variable needs to contain paths to each ROI mask
roifiles = {};
clusters = {'zstat1/Ventral_LOC_VTC_Early_Visual_LR' 'zstat1/Posterior_Cingulate_LR' 'zstat1/OFC_R' 'zstat1/IPS_R' 'zstat1/IPS_LOC_Precuneus_L' 'zstat1/IFJ_R' 'zstat1/Frontal_Gyri_R' 'zstat1/Frontal_Gyri_L' 'zstat1/Caudate_Putamen_Thalamus_LR' 'zstat1/Brainstem_LR' 'zstat1/Anterior_Insula_R' 'zstat1/Anterior_Insula_L' 'zstat1/Anterior_Cingulate_LR' 'zstat8/Temporal_Gyri_R' 'zstat8/Temporal_Gyri_L' 'zstat8/Superior_Parietal_Lobule_L' 'zstat8/Superior_Frontal_Gyrus_R' 'zstat8/Superior_Frontal_Gyrus_L' 'zstat8/Subcallosal_Cortex_LR' 'zstat8/Precuneus_LR' 'zstat8/Posterior_LOC_R' 'zstat8/Postcentral_Gyrus_R' 'zstat8/Mid_Posterior_Cingulate_LR' 'zstat8/Medial_PFC_LR' 'zstat8/Hippocampus_R' 'zstat8/Hippocampus_L' 'zstat8/Anterior_LOC_R' 'zstat8/Angular_Gyrus_R' 'zstat8/Angular_Gyrus_L'};
%clusters = {'zstat8/Superior_Frontal_Gyrus_R'};
%clusters = {'zstat1/Thalamus_LR', 'zstat1/Basal_Ganglia_LR'};
for i = 1:numel(clusters)
    roifiles = [roifiles, [subdir, '/proc_data/anat/rois/25subs_rec-unrec_clusters/' clusters{i} '.nii']];
end
%roifiles = [subdir, '/proc_data/anat/rois/loc/loc_roisum_2mm_maskedVTC_noEVC_Z2.3_500_voxels_highres.nii'];
%roifiles = [subdir, '/proc_data/anat/rois/retinotopy/ret_roisum.nii'];

%load rois from sub_params for retinotopy
%sub_params_file = [subdir '/sub_params'];
%fid = fopen(sub_params_file);
%sub_params = textscan(fid, '%s', 'delimiter', '\n');
%idx = contains(sub_params{1}, 'visual_rois');
%eval(cell2mat(sub_params{1}(idx)));
% combine v2v/d and v3v/d
%for h = 'lr'
%    for r = '23'
%        if numel(strfind(visual_rois, [h, 'hV', r])) > 0;
%            str2replace = [h, 'hV', r, 'v ', h, 'hV', r, 'd'];
%            new_string = [h, 'hV', r];
%            visual_rois = strrep(visual_rois, str2replace, new_string);
%        end
%    end
%end
%clusters = strsplit(visual_rois);
%fclose(fid);
%for i = 1:numel(clusters)
%    roifiles = [roifiles, [subdir, '/proc_data/anat/rois/retinotopy/' clusters{i} '.nii']];
%end

% load localizer ROIs, individually defined
%sub_params_file = [subdir '/sub_params'];
%fid = fopen(sub_params_file);
%sub_params = textscan(fid, '%s', 'delimiter', '\n');
%idx = contains(sub_params{1}, 'loc_rois');
%eval(cell2mat(sub_params{1}(idx)));
%clusters = strsplit(loc_rois);
%fclose(fid);
%for i = 1:numel(clusters)
%    roifiles = [roifiles, [subdir, '/proc_data/anat/rois/loc/' clusters{i} '_2mm_maskedVTC_noEVC_Z2.3_500_voxels_highres.nii']];
%end
% load localizer ROIs, group defined
%clusters = [1 2 3 4];
%for i = clusters
%    roifiles = [roifiles, [subdir, '/proc_data/anat/rois/loc/group_thresh_zstat', num2str(i), '_maskedVTC_noEVC.nii']];
%end

cfg.files.mask = roifiles;
cfg.results.write = 2; % only write .mat, not .nii

% software, default is software: libsvm, method: classification_kernel
%cfg.decoding.software = '';
%cfg.decoding.method = '';

% scaling, default is none
cfg.scale.method = 'min0max1'; % scales data such that minimum = 0, maximum = 1
cfg.scale.estimation = 'separate'; % 
%cfg.testmode = 1; % if set to 1, just do decoding in 1 searchlight sphere for testing

% selecting number of voxels based on voxel value in visual response GLM from localizer
%numvoxels = str2num(fileread([subdir, '/proc_data/anat/rois/minimum_total_voxels_for_loc_or_ret']));
%cfg.feature_selection.method = 'filter';
%cfg.feature_selection.filter = 'external';
%cfg.feature_selection.external_fname = [subdir, '/proc_data/func/loc/loc_visualGLM.feat/stats/zstat1_highres_2mm.nii'];
%cfg.feature_selection.n_vox = numvoxels;

HLTP_runDecoding_parallel(cfg);
