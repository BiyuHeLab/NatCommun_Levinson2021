function [param, exitNow, qmini, dataQmini] = TC_setminiThreshold(win, param, miniTrials, startData, dataQ)

% set quest parameters
param.miniquestParam.tGuess          = [log10(param.stimContrast)+std(log10(dataQ.Wg(60:120)))];
param.miniquestParam.tGuessSD        = 3;
param.miniquestParam.beta            = 3.5;
param.miniquestParam.delta           = 0.01;
param.miniquestParam.gamma           = 0;
param.miniquestParam.pThreshold      = 0.5;
param.miniquestParam.grain           = 0.01;
param.miniquestParam.range           = 5;
param.stimNumber = 20;
questParam = param.miniquestParam;

miniTrials.nQuestTracks = 1;
trialsPerQuestTrack = 40;

clear qmini;
for i=1:miniTrials.nQuestTracks
    qmini(i) = QuestCreate(questParam.tGuess(i), questParam.tGuessSD, ...
        questParam.pThreshold, questParam.beta, questParam.delta, ...
        questParam.gamma, questParam.grain, questParam.range);
end

% set up trial structure and run the block
miniTrials.autoCreate          = 1;
miniTrials.nTrials             = miniTrials.nQuestTracks * trialsPerQuestTrack;

parameters_forQ = param;
parameters_forQ.nTrialsBetweenBreaks = miniTrials.nTrials + 1;
parameters_forQ.isQuest = 1;
parameters_forQ.isQmini = 1;
[dataQmini, exitNow, qmini] = TC_runBlock(win, parameters_forQ, miniTrials, qmini);

% take median from the quest tracks
param.stimContrast = 10^(median(QuestMean(qmini)));
%save([startData.dataFile], 'startData', 'param', 'parameters_forQ', 'dataQmini', 'qmini', '-append');

