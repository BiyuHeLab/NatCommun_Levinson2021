% HLTP_groupMVPA_stats
% assumes actual group average images are already created, for searchlight analyses
% computes stats comparing recognized to unrecognized

scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
cd(scripts_dir); HLTP_paths
data_dir = ''; % PATH TO MAIN DATA DIRECTORY
timepoint = 'betas';
custom1 = ['', '/results/']; % results for recognized trials
custom2 = ['', '/results/']; % results for unrecognized trials
perm_filename = 'balanced_accuracy_standard.nii.gz';
alph = 0.05;
maskfile = '/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz'; % change if local fsl directory is different
mask = load_nifti(maskfile);
good_voxels = find(mask.vol);
nvoxels = numel(mask.vol);

subjects = {'01' '04' '05' '07' '08' '09' '11' '13' '15' '16' '18' '19' '20' '22' '25' '26' '29' '30' '31' '32' '33' '34' '35' '37' '38'};
n_sub_perms = 100;
n_perms = 1000;

for i_perm = 1:n_perms
    all_data = {};
    for i = 1:numel(subjects)
        subj = subjects{i};
        mvpa_dir = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom1 'perm/'];
        curr_sub_perm = randi(n_sub_perms);
        res_file = [mvpa_dir 'perm' sprintf('%04d', curr_sub_perm) '_' perm_filename];
        res_data = load_nifti(res_file);
        all_data1{i} = res_data.vol;
        all_data1{i}(all_data1{i} == 0) = NaN;
        
        mvpa_dir = [data_dir 'sub' subj '/proc_data/func/mvpa/' timepoint '/' custom2 'perm/'];
        curr_sub_perm = randi(n_sub_perms);
        res_file = [mvpa_dir 'perm' sprintf('%04d', curr_sub_perm) '_' perm_filename];
        res_data = load_nifti(res_file);
        all_data2{i} = res_data.vol;
        all_data2{i}(all_data2{i} == 0) = NaN;        
    end
    
    avg = zeros(nvoxels, 1);
    h = zeros(nvoxels, 1); pval = zeros(nvoxels, 1); tstat = zeros(nvoxels, 1);
    for v = good_voxels'
        group_data1 = [];
        group_data2 = [];
        for i = 1:numel(subjects)
            if isfinite(all_data1{i}(v)) && isfinite(all_data2{i}(v)) % if not missing data
                group_data1 = [group_data1; all_data1{i}(v)];
                group_data2 = [group_data2; all_data2{i}(v)];
            end
        end
        if numel(group_data1) > numel(subjects)/2 & numel(group_data1) == numel(group_data2)
            [h(v), pval(v), ~, stats] = ttest(group_data1, group_data2, 'Alpha', alph);
            tstat(v) = stats.tstat;
            avg(v) = mean(group_data1) - mean(group_data2);
        end
    end
    
    mri = mask;
    mri.datatype = 16;
    tstat3d = reshape(tstat, mri.dim(2:4)');
    
    mri.vol = tstat3d;
    output = [data_dir, 'group_results/t_' sprintf('%04d', i_perm) '.nii.gz'];
    err = save_nifti(mri, output);
    cd([data_dir 'group_results']);
    system(['fslmaths t_' sprintf('%04d', i_perm) ' -tfce 2 0.5 6 tfce_t_' sprintf('%04d', i_perm)]);
    system(['fslmaths t_' sprintf('%04d', i_perm) ' -mul -1 t_neg_' sprintf('%04d', i_perm)]);
    system(['fslmaths t_neg_' sprintf('%04d', i_perm) ' -tfce 2 0.5 6 tfce_t_neg_' sprintf('%04d', i_perm)]);
    system(['fslmaths tfce_t_' sprintf('%04d', i_perm) ' -add tfce_t_neg_' sprintf('%04d', i_perm) ' tfce_t_' sprintf('%04d', i_perm)]);
    system(['fslstats tfce_t_' sprintf('%04d', i_perm) ' -R | awk ''{print $2}'' >> max_tfce_t_reccatunreccat.txt']);
    system(['rm *_' sprintf('%04d', i_perm) '.nii*']);
end

null_tfce_t = csvread('max_tfce_t_reccatunreccat.txt');
critical_stat_tfce_t = prctile(null_tfce_t, 95);
system('rm max_tfce_t_reccatunreccat.txt');
system(['touch tfce_t_reccat-unreccat_95=' num2str(critical_stat_tfce_t) ]);

