% High Level Threshold Perception (HLTP) Experiment
%--------------------------------------------------------------------------
%-Init---------------------------------------------------------------------
close all; clear;

exp_type = init_exptype(); 
exp_type.isfMRI = 1;
exp_type.isDebug = 0;

initials = input('Enter subjects initials:   ', 's');
if IsWin
    dataDir = [pwd '\data\' initials, 'data\'];
else
    dataDir = [pwd '/data/' initials, 'data/'];
end
dataFile = [dataDir, 'datafile.mat'];

isRestarting = input('Is restarting? Type yes or no:  ', 's');
isRestarting = strcmp(isRestarting, 'yes');
if isRestarting
    copyfile(dataFile, [dataDir, 'datafile', ...
        datestr(now, 'yyyy_mm_dd__HH_MM_SS'),'_restarted','.mat']);
elseif exist(dataFile, 'file')
    copyfile(dataFile, [dataDir, 'datafile', ...
        datestr(now, 'yyyy_mm_dd__HH_MM_SS_backup'),'.mat']);
end
% This file was created after the thresholding:
load(dataFile);
contrast2use = param.stimContrast;

if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end;
win = openScreen(0, winsize);

[param, trials] = TC_getParameters(win, 60, exp_type);
[param, trials] = TC_adjustParams(win, param, trials, 'fMRI');

% set these when testing/debugging - will quickly skip through trials
% param.true_pre_stim_all_inSecs = zeros(1, 360) + 0.01;
% param.true_post_stim_all_inSecs = zeros(1, 360) + 0.01;
% param.true_responseDuration_inSecs = 0.01;

param.stimContrast = contrast2use;
if ~isRestarting & numel(contrast2use) > 1
    param.stimContrast = [contrast2use(1:5), contrast2use(2), contrast2use(6:10), ...
        contrast2use(7), contrast2use(11:15), contrast2use(12), contrast2use(16:20), ...
        contrast2use(19)]; % give each scrambled exemplar the contrast for its associated real image
end
clear contrast2use;

param.dataFile = dataFile;

%-Instructions-------------------------------------------------------------
% 7/14/17 MGL
Screen('FillRect', win, param.BGcolor);
DrawFormattedText(win, TC_instructions('instructions'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4); Screen('Flip', win);
responseKey = recordValidKeys(GetSecs, inf, param.kb_subject, param.AllResponseKeys);
if strcmp(param.exitKey, responseKey)
    sca; return;
end
%TC_flip_screen(win, param, 'loading');

%-Run experiment-----------------------------------------------------------
[data, exitNow] = TC_runBlock(win, param, trials, q);

%-Save&Finish--------------------------------------------------------------                 
if exitNow
    sca; return;
end
DrawFormattedText(win, 'All done!','center','center');
Screen('Flip', win); pause(2); 

Screen('CloseAll');



