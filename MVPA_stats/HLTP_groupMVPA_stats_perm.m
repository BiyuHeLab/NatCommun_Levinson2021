% HLTP_groupMVPA_stats
% assumes actual group average image is already created, for searchlight analysis
% this script just generates the permutation statistics, independent of the
% real data

scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
cd(scripts_dir); HLTP_paths
data_dir = ''; % PATH TO MAIN DATA DIRECTORY
timepoint = 'betas';
custom = ''; % MVPA ANALYSIS FOLDER OF INTEREST
custom = [custom, '/results/'];
chance = 25; % for four-way category decoding, chance is 25%
alph = 0.05;
maskfile = '/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz'; % change if local fsl directory is different
mask = load_nifti(maskfile);
good_voxels = find(mask.vol);
nvoxels = numel(mask.vol);
subjects = {'01' '04' '05' '07' '08' '09' '11' '13' '15' '16' '18' '19' '20' '22' '25' '26' '29' '30' '31' '32' '33' '34' '35' '37' '38'};
n_sub_perms = 100;
n_perms = 1000;

perm_filename = ['balanced_accuracy_standard.nii.gz'];


for i_perm = 1:n_perms
    all_data = {};
    for i = 1:numel(subjects)
        subj = subjects{i};
        mvpa_dir = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom 'perm/'];
        curr_sub_perm = randi(n_sub_perms);
        res_file = [mvpa_dir 'perm' sprintf('%04d', curr_sub_perm) '_' perm_filename];
        res_data = load_nifti(res_file);
        all_data{i} = res_data.vol;
        all_data{i}(all_data{i} == 0) = NaN;
    end
    
    avg = zeros(nvoxels, 1);
    h = zeros(nvoxels, 1); pval = zeros(nvoxels, 1); t = zeros(nvoxels, 1);
    for v = good_voxels'
        group_data = [];
        for i = 1:numel(subjects)
            if isfinite(all_data{i}(v)) % if not missing data
                group_data = [group_data; all_data{i}(v)];
            end
        end
        if numel(group_data) > numel(subjects) / 2 % if at least half of the subjects are included
            [h(v), pval(v), ~, stats] = ttest(group_data, chance, 'Tail', 'right', 'Alpha', alph);
            t(v) = stats.tstat;
            avg(v) = mean(group_data);
        end
    end

    mri = mask;
    mri.datatype = 16;
    t3d = reshape(t, mri.dim(2:4)');
    mri.vol = t3d;
    output = [data_dir, 'group_results/t_' sprintf('%04d', i_perm) '.nii.gz'];
    err = save_nifti(mri, output);
    cd([data_dir 'group_results']);
    system(['fslmaths t_' sprintf('%04d', i_perm) ' -tfce 2 0.5 6 tfce_t_' sprintf('%04d', i_perm) '']);
    system(['fslstats tfce_t_' sprintf('%04d', i_perm) ' -R | awk ''{print $2}'' >> max_tfce_t.txt']);
    system(['rm *_' sprintf('%04d', i_perm) '.nii*']); 
end

null_tfce_t = csvread('max_tfce_t.txt');
critical_stat_t = prctile(null_tfce_t, 95);
system('rm max_tfce_t.txt');
system(['touch tfce_t_95=' num2str(critical_stat_t) ]);