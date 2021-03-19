clear;
Priority(1);
exp_type = init_exptype();
exp_type.isDebug = 0;
exp_type.isQmini = 1; % take timing parameters etc. from mini quest
revertContrasts = 0; % change to 1 if mini QUEST was already run, but you want to revert to original QUEST contrasts

startData = startExperiment('HLTP');
load(startData.dataFile);
if revertContrasts == 1
    contrasts2use = dataQ.orig_stimContrast;
else
    contrasts2use = param.stimContrast;
end
clear data

% open PT window
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end;
win = openScreen(0, winsize);
%Screen('Preference', 'ConserveVRAM', 4096);

[param, trials] = TC_getParameters(win, startData.distFromScreen_inCm, exp_type);
param.stimContrast = contrasts2use;
param.dataFile = [startData.dataFile '_day2practice'];

save(param.dataFile, 'startData', 'param', 'trials');
TC_flip_screen(win, param, 'loading');

trials.nTrials = 80;
trials.nBlocks = 1;
param.nTrialsBetweenBreaks = trials.nTrials + 1;
param.stimNumber = 20;
n_repeats = trials.nTrials / param.stimNumber;
I = randperm(trials.nTrials);
trials.stimID = repmat([1:param.stimNumber], 1, n_repeats);
trials.stimID = trials.stimID(I);

% instructions
experimentStartTime = clock;
DrawFormattedText(win, TC_instructions('instructions'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4); Screen('Flip', win);
[responseKey, RT, time] = recordValidKeys(GetSecs, inf, param.kb_subject, param.AllResponseKeys);
if strcmp(param.exitKey, responseKey), Screen('CloseAll'); return; end

[data, exitNow] = TC_runBlock(win, param, trials, q);
save([param.dataFile], 'startData', 'param', 'data', 'trials', '-append');


DrawFormattedText(win, TC_instructions('ThresholdEnd'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4); Screen('Flip', win);
recordValidKeys(GetSecs, 1000000, param.kb_subject, param.AllResponseKeys);

DrawFormattedText(win, TC_instructions('ThresholdRelax'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
recordValidKeys(GetSecs, 1000000, param.kb_experimenter, param.exitKey);
Screen('CloseAll');

Priority(0);