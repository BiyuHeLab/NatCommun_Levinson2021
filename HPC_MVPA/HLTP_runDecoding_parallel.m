function HLTP_runDecoding(cfg)
% Initializes and runs a decoding analysis using The Decoding Toolbox
% Input:
% cfg = TDT config struct; must contain at least:
%   cfg.files.mask
%   cfg.subdir = subject's root directory
%   cfg.analdir = subject's mvpa directory
%   cfg.tp = which timepoint within each trial to analyze (or 'betas' to
%       use GLM parameter estimates)
%   cfg.custom = description of particular analysis (e.g., rec v. unrec), to name
%       results directory
%   cfg.classes = cell containing classes to decode

req_fields = {'subdir' 'analdir' 'tp' 'custom' 'classes'};
if ~exist('cfg', 'var')
    error('must input cfg variable');
elseif ~isfield(cfg.files, 'mask')
    error('must input mask file as cfg.files.mask');
else
    for i = 1:numel(req_fields)
        if ~isfield(cfg, req_fields{i})
            error(['must input cfg.' req_fields{i}]);
        end
    end
end

if isfield(cfg, 'design') && isfield(cfg.design, 'unbalanced_data') && strcmp(cfg.design.unbalanced_data, 'ok')
    unbalanced = 1;
else
    unbalanced = 0;
end

mkdir([cfg.analdir, '/', cfg.tp, '/', cfg.custom]);
cfg.results.dir = [cfg.analdir, '/', cfg.tp, '/', cfg.custom, '/results'];

cfg = HLTP_createDesignMVPA(cfg);
%cfg = HLTP_createDesignMVPA_scr(cfg); % use this if combining rec+unrec in scrambled image decoding
if unbalanced == 1
    cfg.design.unbalanced_data = 'ok';
end

[results, cfg, passed_data] = decoding(cfg);
save([cfg.results.dir, '/passed_data.mat'], 'passed_data');

%% permutation test
combine=0;
if iscell(cfg.results.output)
    output = {cfg.results.output{1}, cfg.results.output{4}};
else
    output = cfg.results.output;
end
run_permutation_HLTP([cfg.analdir, '/', cfg.tp, '/', cfg.custom], output, combine);
end
