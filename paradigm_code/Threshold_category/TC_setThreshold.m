function [param, exitNow, q, dataQ] = TC_setThreshold(win, param, trials, dataQ)

% set quest parameters
%if param.isQmini
%    param.questParam.tGuess      = [log10(param.stimContrast)+std(log10(dataQ.Wg(60:120)))];
%    param.questParam.tGuessSD    = std(log10(dataQ.Wg(60:120)));
if param.isQmini
    startContrast = 1.03;
    param.questParam.tGuess      = [log10(startContrast) log10(startContrast)];
    param.questParam.tGuessSD    = 0.2;
elseif param.exemplar_threshold
    startContrast=0.6;
    param.questParam.tGuess      = [log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) ...
    log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) ...
    log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast) ...
    log10(startContrast) log10(startContrast) log10(startContrast) log10(startContrast)];
    param.questParam.tGuessSD    = log10(8);
else
    param.questParam.tGuess      = [log10(param.stimContrast) log10(param.stimContrast) log10(param.stimContrast)];
    param.questParam.tGuessSD    = log10(8);
end
param.questParam.beta            = 3.5;
param.questParam.delta           = 0.01;
param.questParam.gamma           = 0;
param.questParam.pThreshold      = 0.55;%0.50
param.questParam.grain           = 0.01;
param.questParam.range           = 5;
param.stimNumber = 20;
questParam = param.questParam;

if param.isQmini
    trials.nQuestTracks = 2;
    param.questParam.pThreshold = 0.55;
elseif param.exemplar_threshold
    trials.nQuestTracks = param.stimNumber;
else
    trials.nQuestTracks = 3;
end
trialsPerQuestTrack = 40;

for i=1:trials.nQuestTracks
    q(i) = QuestCreate(questParam.tGuess(i), questParam.tGuessSD, ...
        questParam.pThreshold, questParam.beta, questParam.delta, ...
        questParam.gamma, questParam.grain, questParam.range);
end

% set up trial structure and run the block
trials.autoCreate          = 1;
trials.nTrials             = trials.nQuestTracks * trialsPerQuestTrack;
if param.exemplar_threshold
    trials.nBlocks = 4;
else
    trials.nBlocks = 1;
end

parameters_forQ = param;
if param.exemplar_threshold
    parameters_forQ.nTrialsBetweenBreaks = trials.nTrials / trials.nBlocks;
else
    parameters_forQ.nTrialsBetweenBreaks = trials.nTrials + 1;
end
parameters_forQ.isQuest = 1;

if param.isQmini
    orig_stimContrast = dataQ.orig_stimContrast;
end
[dataQ, exitNow, q] = TC_runBlock(win, parameters_forQ, trials, q);
if param.isQmini
    dataQ.orig_stimContrast = orig_stimContrast;
end

% take median from the quest tracks
param.stimContrast = [];
if param.exemplar_threshold
    for i = 1:trials.nQuestTracks
        param.stimContrast = [param.stimContrast, 10^(QuestMean(q(i)))];
    end
    dataQ.orig_stimContrast = param.stimContrast;
elseif param.isQmini
    param.stimContrast = dataQ.orig_stimContrast .* 10^(mean(QuestMean(q)));
else
    param.stimContrast = 10^(median(QuestMean(q)));
end
%save([startData.dataFile], 'startData', 'param', 'parameters_forQ', 'dataQ', 'q', '-append');

