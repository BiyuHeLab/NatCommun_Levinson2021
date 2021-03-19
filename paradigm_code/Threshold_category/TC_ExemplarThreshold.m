% This function sets threshold for each individual exemplar
function [param, exitNow, q] = TC_ExemplarThreshold(win, param, trials, startData)

trials.nQuestTracks = numel(param.categories) * param.stimExemplars;
trialsPerQuestTrack = 30;
trials.autoCreate          = 1;
trials.nTrials             = trials.nQuestTracks * trialsPerQuestTrack;

% set quest parameters
param.exemplar_threshold = 1;
param.nTrialsBetweenBreaks = 100;
param.breakDuration_inSecs = 60;  % if Inf, break is ended by subject

param.questParam.tGuess          = log10(param.stimContrast)*ones(1, trials.nQuestTracks);
param.questParam.tGuessSD        = 3;
param.questParam.beta            = 3.5;
param.questParam.delta           = 0.01;
param.questParam.gamma           = 0.5;
param.questParam.pThreshold      = 0.75;
param.questParam.grain           = 0.01;
param.questParam.range           = 5;

questParam = param.questParam;

clear q;
for i=1:trials.nQuestTracks
    q(i) = QuestCreate(questParam.tGuess(i), questParam.tGuessSD, ...
        questParam.pThreshold, questParam.beta, questParam.delta, ...
        questParam.gamma, questParam.grain, questParam.range);
end

parameters_forQ = param;
parameters_forQ.nTrialsBetweenBreaks = 100;

[dataQ, exitNow, q] = TC_runBlock(win, parameters_forQ, trials, q);

param.stimContrast = 10^(median(QuestMean(q)));
save([startData.dataFile], 'startData', 'param', 'trials', 'parameters_forQ', 'dataQ', 'q', '-append');
