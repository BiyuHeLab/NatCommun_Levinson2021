% HLTP_groupMVPA_stats_ROI

scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
cd(scripts_dir); HLTP_paths

data_dir = ''; % PATH TO MAIN DATA DIRECTORY
timepoint = 'betas';

% trial conditions with rec > unrec ROIs
% note "subcortical" roi has not been split into thalamus and basal ganglia here
custom{1} = ['roi_' timepoint '_reccategories_responsecat_realscrGLM_libsvm_norm/results/'];
custom{2} = ['roi_' timepoint '_unreccategories_responsecat_realscrGLM_libsvm_norm/results/'];
custom{3} = ['roi_' timepoint '_scrcategories_responsecat_libsvm_norm/results/'];
roi_names = {'vis', 'PCC', 'OFC-R', 'IPS-R', 'IPS-L', 'IFJ-R', 'FRONTAL-R', 'FRONTAL-L', 'SUBCORTICAL', 'BRAINSTEM', 'AINS-R', 'AINS-L', 'ACC', 'TEMPORAL-R', 'TEMPORAL-L', 'SPL-L', 'SFG-R', 'SFG-L', 'SUBCALLOSAL', 'PRECUNEUS', 'POST-LOC-R', 'POSTCENTRAL-R', 'MID-PCC', 'mPFC', 'HPC-R', 'HPC-L', 'ANT-LOC-R', 'ANG-R', 'ANG-L'};
%with hierarchical reorder:
roi_names = {'brainstem', 'subcortical', 'vis', 'L IPS', 'R IPS', 'PCC', 'ACC', 'L AIns', 'R AIns', 'R IFJ', 'L Frontal Gyri', 'R Frontal Gyri', 'R OFC', ...
   'L HPC', 'R HPC', 'R Post-LOC', 'R Ant-LOC', 'L AG', 'R AG', 'Precuneus', 'L SPL', 'L Temporal Gyri', 'R Temporal Gyri', 'R Postcentral', 'mid-PCC', 'Subcallosal', 'L SFG', 'R SFG', 'mPFC'};
final_roi_names = {'brainstem', 'subcortical', 'visual', 'L IPS', 'R IPS', 'aPCC', 'ACC', 'L aIns', 'R aIns', 'R IFJ', 'L MFG', 'R MFG', 'R OFC', ...
   'L HC', 'R HC', 'L AG', 'R AG', 'PCC', 'L Temporal', 'R Temporal', 'L SFG', 'R SFG', 'mPFC'}; % hierarchical and selected ROIs (final_rois)

% trial conditions within retinotopy ROIs
% custom{1} = ['roi_' timepoint '_reccategories_realscrGLM_retinotopy_ROIs_libsvm_norm/results/'];
% custom{2} = ['roi_' timepoint '_scrcategories_retinotopy_ROIs_libsvm_norm/results/'];
% custom{3} = ['roi_' timepoint '_unreccategories_realscrGLM_retinotopy_ROIs_libsvm_norm/results/'];
% roi_names = {'rhV1' 'rhV2' 'rhV3' 'rhV4' 'lhV1' 'lhV2' 'lhV3' 'lhV4'};

% trial conditions within localizer ROIs
%custom{1} = ['roi_' timepoint '_reccategories_realscrGLM_loc_individual_ROIs_libsvm_norm/results/'];
%custom{2} = ['roi_' timepoint '_scrcategories_loc_individual_ROIs_libsvm_norm/results/'];
%custom{3} = ['roi_' timepoint '_unreccategories_realscrGLM_loc_individual_ROIs_libsvm_norm/results/'];
%roi_names = {'zstat1', 'zstat2', 'zstat3', 'zstat4'};%{'animal>others', 'face>others', 'house>others', 'object>others'};

% trial conditions within thalamus + basal ganglia, split from rec>unrec ROI
% custom{1} = ['roi_' timepoint '_reccategories_realscrGLM_THALAMUS_BASALGANGLIA_libsvm_norm/results/'];
% custom{2} = ['roi_' timepoint '_unreccategories_realscrGLM_THALAMUS_BASALGANGLIA_libsvm_norm/results/'];
% custom{3} = ['roi_' timepoint '_scrcategories_THALAMUS_BASALGANGLIA_libsvm_norm/results/'];
% roi_names = {'thalamus', 'basalganglia'};

% trial conditions within V1-V4 together, controlled for eq voxel count with VTC
% custom{1} = ['roi_' timepoint '_reccategories_realscrGLM_ret_roisum_controlnumvoxels_libsvm_norm/results/'];
% custom{2} = ['roi_' timepoint '_unreccategories_realscrGLM_ret_roisum_controlnumvoxels_libsvm_norm/results/'];
% custom{3} = ['roi_' timepoint '_scrcategories_ret_roisum_controlnumvoxels_libsvm_norm/results/'];
% roi_names = {'ret_roisum'};

% trial conditions within four category-selective areas, controlled for eq voxel count with EVC
% custom{1} = ['roi_' timepoint '_reccategories_realscrGLM_loc_roisum_controlnumvoxels_libsvm_norm/results/'];
% custom{2} = ['roi_' timepoint '_unreccategories_realscrGLM_loc_roisum_controlnumvoxels_libsvm_norm/results/'];
% custom{3} = ['roi_' timepoint '_scrcategories_loc_roisum_controlnumvoxels_libsvm_norm/results/'];
% roi_names = {'loc_roisum'};

results_output = 'balanced_accuracy';
filename = ['res_' results_output '.mat'];
subjects = {'01' '04' '05' '07' '08' '09' '11' '13' '15' '16' '18' '19' '20' '22' '25' '26' '29' '30' '31' '32' '33' '34' '35' '37' '38'}; % all
%subjects = {'04' '05' '07' '08' '09' '11' '13' '15' '16' '18' '20' '22' '25' '26' '29' '30' '31' '32' '33' '34' '35' '37' '38'}; % subjects with retinotopy
n_rois = numel(roi_names);
n_perms = 1000;
n_sub_perms = 100;
alph = 0.05;

%% main task
all_data = nan(numel(subjects), n_rois, numel(custom));
rois2use = logical(ones(numel(subjects), n_rois));
for s = 1:numel(subjects)
    clear results
    subj = subjects{s};
    if numel(strfind(custom{1}, 'retinotopy')) > 0 | numel(strfind(custom{1}, 'loc_individual')) > 0 % if analyzing retinotopy or individual category localizer ROIs, which have different numbers of ROIs per subject
        sub_params_file = [data_dir 'sub' subj '/sub_params'];
        fid = fopen(sub_params_file);
        sub_params = textscan(fid, '%s', 'delimiter', '\n');
        if numel(strfind(custom{1}, 'retinotopy')) > 0 % retinotopy
            idx = contains(sub_params{1}, 'visual_rois');
            eval(cell2mat(sub_params{1}(idx)));
            % combine v2v/d and v3v/d
            for h = 'lr'
                for r = '23'
                    if numel(strfind(visual_rois, [h, 'hV', r])) > 0;
                        str2replace = [h, 'hV', r, 'v ', h, 'hV', r, 'd'];
                        new_string = [h, 'hV', r];
                        visual_rois = strrep(visual_rois, str2replace, new_string);
                    end
                end
            end
            final_rois = cellstr(split(visual_rois, ' '))';
        else % category localizer
            idx = contains(sub_params{1}, 'loc_rois');
            eval(cell2mat(sub_params{1}(idx)));
            final_rois = cellstr(split(loc_rois, ' '));
        end
        fclose(fid);
        rois2use(s, :) = contains(roi_names, final_rois);
    end
    for c = 1:numel(custom)
        roi_idx = 0;
        mvpa_dir = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom{c}];
            res_file = [mvpa_dir filename];
            try load(res_file);
                for r = 1:n_rois
                    if rois2use(s, r)
                        roi_idx = roi_idx + 1;
                        all_data(s, r, c) = results.(results_output).output(roi_idx);
                    end
                end
            end
    end
end

mean_data = squeeze(nanmean(all_data)); % columns: conditions, rows: rois
sd_data = squeeze(nanstd(all_data));
stderr_data = sd_data ./ sqrt(numel(subjects));
% if only one ROI
% z = size(nanmean(all_data));
% mean_data = reshape(nanmean(all_data), [z(2:end) 1]);
% sd_data = reshape(nanstd(all_data), [z(2:end) 1]);
% stderr_data = sd_data ./ sqrt(numel(subjects));

% permutations
null_dists = zeros(n_perms, n_rois, numel(custom));
perm_crits = zeros(n_rois, numel(custom));
for perm = 1:n_perms
    curr_data = nan(numel(subjects), n_rois, numel(custom));
    for s = 1:numel(subjects)
        subj = subjects{s};
        curr_sub_perm = randi(n_sub_perms);
        for c = 1:numel(custom)
            roi_idx = 0;
            mvpa_dir = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom{c} 'perm/'];
            res_file = [mvpa_dir 'perm' num2str(curr_sub_perm, '%04d') '_' results_output '.mat'];
            try load(res_file);
                for r = 1:n_rois
                    if rois2use(s, r)
                        roi_idx = roi_idx + 1;
                        curr_data(s, r, c) = results.(results_output).output(roi_idx);
                    end
                end
            end
        end
        null_dists(perm, :, :) = nanmean(curr_data);
    end
end

% only use certain ROIs
orig_all_data = all_data;
orig_mean_data = mean_data;
orig_stderr_data = stderr_data;
orig_null_dists = null_dists;
orig_n_rois = n_rois;
final_rois = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 20 24 25 26 28 29];
all_data = all_data(:, final_rois, :);
mean_data = mean_data(final_rois, :);
stderr_data = stderr_data(final_rois, :);
null_dists = null_dists(:, final_rois, :);
n_rois = numel(final_rois);

p = zeros(numel(custom), n_rois); n_signif = zeros(1, numel(custom)); index_signif = cell(1, numel(custom)); p_sig_fdr = false(numel(custom), n_rois);

for c = 1:numel(custom)
    for r = 1:n_rois
        p(c, r) = sum(null_dists(:, r, c) > mean_data(r, c)) / n_perms;
        if p(c, r) == 0; p(c, r) = 1/n_perms; end % smallest possible p
    end
    [n_signif(c), index_signif{c}] = fdr(p(c, :), alph);
    if n_signif(c)
        p_sig_fdr(c, index_signif{c}) = true; % fdr corrected across ROIs, but not across trial conditions
    end
end
p_sig = p < alph; % not fdr corrected
perm_crits = squeeze(prctile(null_dists, (1-alph) * 100));


% permutations, rec > unrec
null_dist = zeros(n_perms, n_rois);
perm_crits = zeros(n_rois, 1);
for perm = 1:n_perms
    curr_data = nan(numel(subjects), n_rois);
    for s = 1:numel(subjects)
        subj = subjects{s};
        curr_sub_perm = randi(n_sub_perms);
        roi_idx = 0;
        mvpa_dir1 = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom{1} 'perm/'];
        res_file1 = [mvpa_dir 'perm' num2str(curr_sub_perm, '%04d') '_' results_output '.mat'];
        mvpa_dir2 = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom{3} 'perm/'];
        res_file2 = [mvpa_dir 'perm' num2str(curr_sub_perm, '%04d') '_' results_output '.mat'];
        try res1 = load(res_file1);
            res2 = load(res_file2);
            for r = 1:n_rois
                if rois2use(s, r)
                    roi_idx = roi_idx + 1;
                    curr_data(s, r) = res1.results.(results_output).output(roi_idx) - res2.results.(results_output).output(roi_idx);
                end
            end
        end
    end
    null_dist(perm, :) = nanmean(curr_data);
end

% if just using original null_dists with all data
mean_diff_data = mean_data(:, 1) - mean_data(:, 2);
null_dist_diff = squeeze(null_dists(:, :, 1) - null_dists(:, :, 2));

p = zeros(1, n_rois); n_signif = []; index_signif = []; p_sig_fdr = false(1, n_rois);

for r = 1:n_rois
    p(r) = sum(null_dist_diff(:, r) > mean_diff_data(r)) / n_perms;
    if p(r) == 0; p(r) = 1/n_perms; end % smallest possible p
end
[n_signif, index_signif] = fdr(p, alph);
if n_signif
    p_sig_fdr(index_signif) = true; % fdr corrected across ROIs
end
    
p_sig = p < alph; % not fdr corrected
perm_crits = squeeze(prctile(null_dist_diff, (1-alph) * 100));