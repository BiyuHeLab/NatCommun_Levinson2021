clear;
exp_type = init_exptype(); 
exp_type.isQuest = 1;
exp_type.isQmini = 1;
exp_type.isDebug = 0;

% load old data
initials = input('Enter subjects initials:   ', 's');
if IsWin
    dataDir = [pwd '\data\' initials, 'data\'];
else
    dataDir = [pwd '/data/' initials, 'data/'];
end
datafile = [dataDir, 'datafile.mat'];
copyfile(datafile, [dataDir, 'datafile', ...
        datestr(now, 'yyyy_mm_dd__HH_MM_SS_backup'),'.mat']);
load(datafile);

% open PT window
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end;
win = openScreen(0, winsize);

[param, trials] = TC_getParameters(win, startData.distFromScreen_inCm, exp_type);
param.dataFile = datafile;


TC_flip_screen(win, param, 'loading');

%-Instructions-------------------------------------------------------------

experimentStartTime = clock;
DrawFormattedText(win, TC_instructions('instructions'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4); Screen('Flip', win);
recordValidKeys(GetSecs, inf, param.kb_subject, param.AllResponseKeys);

%-Threshold----------------------------------------------------------------
% this is done only in order to normalize the initial images contrast:
%[param, exitNow, q] = TC_ExemplarThreshold(win, param, trials, startData); 
dataQ.orig_stimContrast = 10^(median(QuestMean(q)));
param.stimContrast = dataQ.orig_stimContrast;
[param, exitNow, qmini, dataQmini] = TC_setminiThreshold(win, param, trials, startData, dataQ);
dataQmini.orig_stimContrast = dataQ.orig_stimContrast
save([startData.dataFile], 'startData', 'param', 'dataQmini', 'qmini', '-append');
if exitNow, Screen('CloseAll'); return; end

%-End Threshold------------------------------------------------------------
DrawFormattedText(win, TC_instructions('ThresholdEnd'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4); Screen('Flip', win);
recordValidKeys(GetSecs, 1000000, param.kb_subject, param.AllResponseKeys);

DrawFormattedText(win, TC_instructions('ThresholdRelax'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
recordValidKeys(GetSecs, 1000000, param.kb_experimenter, param.exitKey);
Screen('CloseAll');

%-Verify Threshold---------------------------------------------------------
% load(param.dataFile)
figure; hold on;
title(['QUEST convergence from ' num2str(dataQmini.orig_stimContrast) ' to ' num2str(param.stimContrast)])
plot(find(dataQmini.qID == 1), dataQmini.Wg(dataQmini.qID == 1), '.--');
xlabel('trial number');ylabel('contrast');