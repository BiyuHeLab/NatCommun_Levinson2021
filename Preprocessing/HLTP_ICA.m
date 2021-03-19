% HLTP_ICA
function HLTP_ICA(subj)
% call with subj number as string (e.g. '05' )

% parameters
clear good_blocks
data_dir = ''; % PATH OF MAIN DATA DIRECTORY
%subj = '11';
numruns_line = 42; % which line of sub_params contains list of usable blocks (usual: 42)
%good_blocks = []; % change if different from list in sub_params

comp_col = 'A'; % which column contains list of components to remove
filename = 'bad_components.xls';

sub_dir = [data_dir, 'sub', num2str(subj)];
func_dir = [sub_dir, '/proc_data/func/'];

% find which task blocks to use
if ~exist('good_blocks', 'var')
    sub_params_file = [sub_dir, '/sub_params'];
    fid = fopen(sub_params_file);
    sub_params = textscan(fid, '%s', 'delimiter', '\n');
    idx = contains(sub_params{1}, 'good_blocks');
    eval(cell2mat(sub_params{1}(idx)));
    good_blocks = str2mat(good_blocks);
    good_blocks = str2num(good_blocks);
    fclose(fid);
end


% run cleaning
components_loc = readtable([sub_dir, '/', filename], 'Sheet', 'loc', 'Range', [comp_col, ':', comp_col]); % 16th sheet contains loc components
components_loc = regexprep(num2str(components_loc{:,:}'),'\s+',','); % converts to comma-separated string

loc_ica_command = ['fsl_regfilt -i ' func_dir 'loc/loc_preproc.feat/filtered_func_data -o ', ...
    func_dir 'loc/loc_preproc.feat/denoised_data -d ' func_dir, ...
    'loc/loc_preproc.feat/filtered_func_data.ica/melodic_mix -f "' components_loc '"'];
system(loc_ica_command);

for block = good_blocks
    components_block = readtable([sub_dir, '/' filename], 'Sheet', block, 'Range', [comp_col, ':', comp_col]);
    components_block = regexprep(num2str(components_block{:,:}'),'\s+',','); % converts to comma-separated string

    blockname = ['block' num2str(block)];
    preproc_dir = [func_dir, blockname, '/' blockname, '_preproc.feat/'];
    block_ica_command = ['fsl_regfilt -i ' preproc_dir 'filtered_func_data -o ', ...
        preproc_dir 'denoised_data -d ' preproc_dir 'filtered_func_data.ica/melodic_mix -f "', ...
        components_block '"'];
    system(block_ica_command);
end