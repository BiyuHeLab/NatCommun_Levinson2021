function ecogWordMixture(params)
%
% This script runs the event-related words experiment, which can have any number of word types as stimuli.
%
%       ecogWordMixture([params])
%
%   exptCode can either be the code (number) of a previously saved
%   experiment, or it can be the code for a new experimental design that
%   will be created. This code either runs the experiment (if the exptCode
%   already exists) or it will build a new experiment (if the exptCode
%   doesn't yet exist).  So, if you haven't yet made the experiment, you
%   need to run this script twice, first to build the experiment, then to
%   run it.
%
%   Set loadParfileFlag to 1 below if you are making an experiment that you
%   want to read in from a pregenerated parfile (e.g. through optseq2).
%   Otherwise, if loadParfileFlag is 0, you will need a stimOrder.txt file
%   in the stim folder which specifies the stimuli and condition numbers
%   for each trial (in 2 columns, with each row corresponding to a trial).
%
% written: amr 2010-01-06 (based on PhaseScrambleEventRelated)
%

if ~exist('params','var')
    params.ScanName = 'WordMixture';  % Enter the name of your functional block scan here (used in saving data)
    params.baseDir = ['/Users/Shared/ecogData/' params.ScanName]; % directory that contains stim folder with stimuli
    params.subjName = input('Subject name? ','s');
    params.scanNumber = input('Scan number? ');
    params.stimDir = fullfile(params.baseDir,'stim');  % where pictures of normal word stimuli are located
    params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
end

if exist(params.savedTrialsDir,'dir')
    fprintf('Saved trial directory %s\n',params.savedTrialsDir)
    fprintf('exists! Will run existing experiment. \n\n')
    makeNewExperimentFlag = 0;
else
    fprintf('Saved trial directory %s\n',params.savedTrialsDir)
    fprintf('does not exist! Will create new experiment. \n\n')
    makeNewExperimentFlag = 1;
end

%% Decide whether to make a new experiment or load in a saved one (based on exptCode)
if makeNewExperimentFlag % create a new experiment
    % create and save out all the experiment information
    loadParfileFlag = 0;  % if set to 1, you have a pre-generated parfile (e.g. from optseq2) that specifies onset times (i.e. ITIs),
    % ... conds, labels, and trial lengths
    params.savedTrialsDir = ecogWordMakeWordMixture(params,loadParfileFlag);
    %savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
    
else % run the experiment
    
    % 1st, load in the parameters and directory with trial information
    paramInfoFile = fullfile(params.savedTrialsDir,'paramInfoFile.mat');
    load(paramInfoFile);
    
    % Then, run the experiment
    [ssResponses, ssRTs, savedResponsesFile,quitProg,tenKeyFlag] = ecogRunEventRelated(params.ScanName,params,params.savedTrialsDir);
    
    if ~quitProg
        % Calculate performance and save them out
        [PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params,tenKeyFlag);  %PC and meanRT are structs
        save(savedResponsesFile,'PC','meanRT','-append');
    end
end


return