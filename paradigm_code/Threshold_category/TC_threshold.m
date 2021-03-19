clear;
Priority(1);
exp_type = init_exptype(); 
exp_type.isQuest = 1;
exp_type.isDebug = 0;

startData = startExperiment('HLTP');
qversion = input('mini, exemplar, or regular?   ', 's');
if strcmp(qversion, 'mini')
    exp_type.isQmini = 1;
    load(startData.dataFile);
    dataQ.orig_stimContrast = param.stimContrast;
elseif strcmp(qversion, 'exemplar')
    exp_type.exemplar_threshold = 1;
end

% open PT window
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end;
win = openScreen(0, winsize);
%Screen('Preference', 'ConserveVRAM', 4096);

[param, trials] = TC_getParameters(win, startData.distFromScreen_inCm, exp_type);

param.dataFile = startData.dataFile;
if exist(param.dataFile, 'file')
    copyfile(param.dataFile, [startData.dataDir, 'datafile', ...
        datestr(now, 'yyyy_mm_dd__HH_MM_SS_backup'),'.mat']);
end
save(startData.dataFile, 'startData', 'param', 'trials');
TC_flip_screen(win, param, 'loading');

%-Instructions-------------------------------------------------------------

experimentStartTime = clock;
DrawFormattedText(win, TC_instructions('instructions'), 'center', 'center', ...
        param.fontColor, [], [], [], 1.4); Screen('Flip', win);
[responseKey, RT, time] = recordValidKeys(GetSecs, inf, param.kb_subject, param.AllResponseKeys);
if strcmp(param.exitKey, responseKey), Screen('CloseAll'); return; end

% 10 dummy trials to get accustomed to task in MRI scanner are in runBlock


%-Threshold----------------------------------------------------------------
% this is done only in order to normalize the initial images contrast:
%[param, exitNow, q] = TC_ExemplarThreshold(win, param, trials, startData); 
if param.isQmini
    %dataQ.orig_stimContrast = 10^(median(QuestMean(q)));
    param.stimContrast = dataQ.orig_stimContrast;
    [param, exitNow, qmini, dataQmini] = TC_setThreshold(win, param, trials, dataQ);
    dataQ.mini = dataQmini; dataQ.qmini = qmini;
else
    [param, exitNow, q, dataQ] = TC_setThreshold(win, param, trials);
end
save([startData.dataFile], 'startData', 'param', 'dataQ', 'q', '-append');
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
if param.isQmini
    title(['QUEST convergence from 1 to ' num2str(param.stimContrast(1) ./ dataQ.orig_stimContrast(1))])
    for i = 1:2
        plot(find(dataQ.mini.qID == i), dataQ.mini.Wg(dataQ.mini.qID == i), '.--');
    end
else
    if param.exemplar_threshold
        for i = 1:20
            plot(find(dataQ.qID == i), dataQ.Wg(dataQ.qID == i), '.--');
        end
    else
    title(['QUEST convergence to ' num2str(param.stimContrast)])
    for i = 1:3
        plot(find(dataQ.qID == i), dataQ.Wg(dataQ.qID == i), '.--');
    end
    end
end
xlabel('trial number');ylabel('contrast');

Priority(0);