function run_permutation_HLTP(analdir, decoding_measure, combine, varargin)

results_dir = [analdir, '/results'];
if size(varargin, 1) > 0 % if bootstrapping and boot # is input
    n_perms = 1; % one perm per bootstrap
    boot = varargin{1};
    cfg_file = [results_dir, '/boot' num2str(boot) '/boot' sprintf('%04d', boot) '_cfg.mat'];
else
    n_perms = 100;
    cfg_file = [results_dir, '/res_cfg.mat'];
end
load(cfg_file, 'cfg');

org_cfg = cfg; % keeping the unpermuted cfg to copy parameters below
org_cfg.results.dir = results_dir; % in case processing on new server

cfg = rmfield(cfg,'design'); % this is needed if you previously used cfg.
if isfield(org_cfg.design, 'function')
    cfg.design.function = org_cfg.design.function;
end


cfg.results = rmfield(cfg.results, 'resultsname'); % the name should be generated later
if size(varargin, 1) > 0 % if bootstrapping and boot # is input
    cfg.results.filestart = ['perm_boot' sprintf('%04d', boot)];
    cfg.results.dir = fullfile(results_dir, ['boot' num2str(boot)], 'perm');
else
    cfg.results.dir = fullfile(results_dir, 'perm'); % change directory
end
cfg.results.overwrite = 1; % should not overwrite results (change if you whish to do so)
cfg.results.output = decoding_measure;
cfg.plot_design = 0;
cfg.plot_selected_voxels = 0;


if ~exist('combine', 'var') % should be set in input. 1 = run all permutations in one design, 0 = run individually in a loop
    combine = 0;
end

if ~isfield(org_cfg.design, 'function') % if using a custom design
    if numel(unique(org_cfg.design.set)) > 1 % if using multiple sets and a custom design
        tmp_cfg = [];
        designs = [];
        for i = 1:org_cfg.design.n_sets
            tmp_cfg{i} = cfg;
            tmp_cfg{i}.files.chunk = org_cfg.files.cats == i;
            tmp_cfg{i}.design.function.name = 'make_design_separate';
            designs{i} = make_design_permutation(tmp_cfg{i}, n_perms, combine);
        end
    else
        cfg.design.function.name = 'make_design_separate';
        designs = make_design_permutation(cfg, n_perms, combine);
    end
else
    if logical(combine)
        cfg.design = make_design_permutation(cfg, n_perms, combine);
        cfg.design.function = rmfield(cfg.design.function, 'permutation');
    else
        designs = make_design_permutation(cfg, n_perms, combine);
    end
end

if isfield(org_cfg.design, 'unbalanced_data')
    cfg.design.unbalanced_data = org_cfg.design.unbalanced_data;
else
    cfg.design.unbalanced_data = 0;
    org_cfg.design.unbalanced_data = 0;
end

if logical(combine)
    [results, final_cfg] = decoding(cfg); %run all permutations in one go
else
    % Run all permutations in a loop
    % With small tricks to make it run faster (reusing design figure, loading 
    % data once using passed_data), renaming the design figure, and to display
    % the current permutation number in the title of the design figure)

    load([org_cfg.results.dir, '/passed_data.mat'], 'passed_data'); % avoid loading the same data multiple times by looping it
    passed_data = passed_data;

    pc = parcluster('local');
    pc.JobStorageLocation = strcat(getenv('SCRATCH'), '/', getenv('SLURM_JOB_ID'));
    parpool(pc, str2num(getenv('SLURM_NTASKS'))-1);
    base_cfg = cfg; clear cfg;
    parfor i_perm = 1:n_perms
        dispv(1, 'Permutation %i/%i', i_perm, n_perms)
        cfg = base_cfg;
        if ~isfield(org_cfg.design, 'function') & numel(unique(org_cfg.design.set)) > 1 % if using multiple sets and a custom design
            all_cfg = {};
            for i_set = 1:org_cfg.design.n_sets
                all_cfg{i_set} = cfg;
                all_cfg{i_set}.design = designs{i_set}{i_perm};
                all_cfg{i_set}.design.unbalanced_data = org_cfg.design.unbalanced_data;
            end
            cfg = combine_designs(all_cfg);
            cfg.results.setwise = 1;
        else
            cfg.design = designs{i_perm};
            cfg.design.unbalanced_data = org_cfg.design.unbalanced_data;
        end
        cfg.results.filestart = ['perm' sprintf('%04d', i_perm)];
   
 
        if ~strcmp(cfg.analysis, 'searchlight') && i_perm > 1
            cfg.plot_selected_voxels = 0; % switch off after the first time, drawing takes some time
        end
    
        % do the decoding for this permutation
        [results, final_cfg] = decoding(cfg, passed_data); % run permutation
    
    end
end