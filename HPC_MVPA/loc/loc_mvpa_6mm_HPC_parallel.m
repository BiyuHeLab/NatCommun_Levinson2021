function loc_mvpa_HPC(subj)

scripts_dir = ; % PATH TO SCRIPTS DIRECTORY
cd(scripts_dir)
HLTP_paths

datadir = ; % PATH TO MAIN DATA DIRECTORY
analdir = [datadir, '/sub', subj, '/proc_data/func'];

clear cfg
cfg = decoding_defaults;

cfg.results.dir = [analdir, '/mvpa/loc_category_roi/results'];


betadir = [analdir, '/loc/mvpa/loc_mvpa_GLM.feat/stats'];
betas = dir([betadir, '/pe*.nii']);
betas = {betas.name}';
betas = strcat(betadir, '/', betas);
cfg.files.name = betas;
% random-looking order below is because filenames are not read in the correct order
cfg.files.chunk = [1 5 1 2 3 4 5 1 2 3 4 2 5 3 4 5 1 2 3 4]';
cfg.files.label = [1 2 3 3 3 3 3 4 4 4 4 1 4 1 1 1 2 2 2 2]';


%% 4-class

cfg.design = make_design_cv(cfg);
cfg.design.unbalanced_data = 0;

cfg.results.output = {'balanced_accuracy', 'accuracy', 'decision_values', 'predicted_labels', 'confusion_matrix'}

%searchlight parameters
cfg.analysis = 'searchlight'; % wholebrain, ROI, searchlight
cfg.searchlight.unit = 'mm'; % voxels or mm
cfg.searchlight.radius = 6;
cfg.files.mask = [analdir, '/loc/mvpa/loc_mvpa_GLM.feat/mask.nii'];



%scaling, default is none
cfg.scale.method = 'min0max1';
cfg.scale.estimation = 'separate';

[results, cfg, passed_data] = decoding(cfg);
save([cfg.results.dir, '/passed_data.mat'], 'passed_data');


%% permutation test
combine = 0;
run_permutation_HLTP(analdir, {cfg.results.output{1}, cfg.results.output{5}}, combine);
