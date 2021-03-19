% HLTP_groupMVPA_stats
% generates a t-value for each voxel in a searchlight MVPA analysis, from group-level results.

scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
cd(scripts_dir); HLTP_paths
data_dir = ''; % PATH TO MAIN DATA DIRECTORY
timepoint = 'betas';
custom = ''; % MVPA ANALYSIS FOLDER OF INTEREST
custom = [custom, '/results/'];
output_custom = ''; % what you want the final output file to be called
chance = 25; % for four-way category decoding, chance is 25%
filename = 'res_balanced_accuracy_standard.nii.gz';
subjects = {'01' '04' '05' '07' '08' '09' '11' '13' '15' '16' '18' '19' '20' '22' '25' '26' '29' '30' '31' '32' '33' '34' '35' '37' '38'}; % all subjects
maskfile = '/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz'; % change if local fsl directory is different
mask = load_nifti(maskfile);
good_voxels = find(mask.vol);
nvoxels = numel(mask.vol);
all_data = {};
for i = 1:numel(subjects)
    subj = subjects{i};
    mvpa_dir = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom];
    res_file = [mvpa_dir filename];
    res_data = load_nifti(res_file);
    all_data{i} = res_data.vol;
    all_data{i}(all_data{i} == 0) = NaN;
end

h = zeros(nvoxels, 1); pval = zeros(nvoxels, 1); t = zeros(nvoxels, 1); avg = zeros(nvoxels, 1);
alph = 0.05;
for v = good_voxels'
    group_data = [];
    for i = 1:numel(subjects)
        if isfinite(all_data{i}(v)) % if not missing data
            group_data = [group_data; all_data{i}(v)];
        end
    end
    if numel(group_data) > numel(subjects) / 2 % if at least half of the subjects are included
        [h(v), pval(v), ~, stats] = ttest(group_data, chance, 'Tail', 'right', 'Alpha', alph); % one sided test above chance
        t(v) = stats.tstat;
        avg(v) = mean(group_data);
    end
end

% save stats image
mri = mask;
mri.datatype = 16;
tstat3d = reshape(t, mri.dim(2:4)');
avg3d = reshape(avg, mri.dim(2:4)');

mri.vol = avg3d;
err = save_nifti(mri, [data_dir, 'group_results/' output_custom '_avg.nii']);

mri.vol = tstat3d;
err = save_nifti(mri, [data_dir, 'group_results/t_' output_custom '.nii']);