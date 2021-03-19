% param - all the info about stim properties, timing, etc
% text       - text presented to the subject during the block
% trials     - trial structure for this block (nTrials, trialType, qID)
% quest      - array of quest structs
% data       - timing and response info gathered in this block
function [data, exitNow, q] = TC_runBlock(win, param, trials, q)

%------Init----------------------------------------------------------------
%data.blockStartTime = clock;
exitNow = 0;
% store behavioral data here
dataFields = {'trialNum' 'Wg' 'stimID' 'qID' ...
    'detectR' 'detectRT' 'detectTime' 'catR' 'catRT' 'catTime', ...
    'selected_cat' 'catKey' 'detectKey'};

% store paradigm timing data here
dataTimingFields = {'chVBL' 'chOnset' 'stimVBL' 'stimOnset'  ...
    'postVBL' 'r1VBL' 'r1Onset' 'r2VBL' 'r2Onset' 'ITIVBL' ...
    'trialCompleteTime' 'trialDuration'};

% initialize fields to 0
z = zeros(1, trials.nTrials);
for i = 1:length(dataFields), data.(dataFields{i}) = z; end
for i = 1:length(dataTimingFields), data.timing.(dataTimingFields{i}) = z; end
data.exemplar = {};
data.blockStartTime = {};

%----- Create trials structure --------------------------------------------

if param.isQuest
    trials.qID          = [];
    block = [];
    nTrialsPerTrack = trials.nTrials / trials.nQuestTracks;
    trackTrialsPerBlock = nTrialsPerTrack / trials.nBlocks;
    for i = 1:trials.nQuestTracks
        block = [block, i * ones(1, trackTrialsPerBlock)];
    end
    for i = 1:trials.nBlocks
        trials.qID = [trials.qID, Shuffle(block)];
    end
    if param.exemplar_threshold
        trials.stimID = trials.qID;
    elseif param.isQmini
        n_repeats = nTrialsPerTrack / param.stimNumber;
        trials.qID = [];
        for i = 1:trials.nQuestTracks
            trials.qID = [trials.qID, i * ones(1, trackTrialsPerBlock)];
        end
        I = randperm(trials.nTrials);
        trials.qID = trials.qID(I);
        trials.stimID = repmat([1:param.stimNumber], 1, n_repeats * trials.nQuestTracks);
        trials.stimID = trials.stimID(I);
    else
        trials.stimID = randi(param.stimNumber, 1, trials.nTrials);
    end
else
    % computed now in adjust parameters
end

%-----run trials-----------------------------------------------------------

trialNum = 0;


while trialNum < trials.nTrials
    
    %plot data from previous block, if not first block
    if trialNum > 1 && ~param.isPractice
        Screen('TextSize', win, param.TextSize);
        DrawFormattedText(win, ['Feel free to take a break. Next block: ' num2str(trialNum/param.nTrialsBetweenBreaks+1) '/' num2str(trials.nBlocks) '\n\n\n\n'], 'center', 'center', ...
        param.fontColor, [], [], [], 1.4);
        Screen('Flip', win);
        TC_plotBlockData(data, param);
    
        % subject start when they are ready
        Screen('TextSize', win, param.TextSize); % make text smaller for instructions
        DrawFormattedText(win, TC_instructions('nextBlock', num2str(trialNum/param.nTrialsBetweenBreaks+1), num2str(trials.nBlocks)), 'center', 'center', ...
            param.fontColor, [], [], [], 1.4);
        Screen('Flip', win);
    else %if first block
        Screen('TextSize', win, param.TextSize);
        DrawFormattedText(win, 'Get ready for the next block.\n\n\n\nPress any key to continue.', 'center', 'center', ...
            param.fontColor, [], [], [], 1.4);
        Screen('Flip', win);
    end
    
    responseKey = recordValidKeys(GetSecs, 100000, param.kb_subject, param.AllResponseKeys);
     if strcmp(param.exitKey, responseKey)
        exitNow = 1;
     end
     if exitNow, break, end
    
     %COMMENTING THIS SECTION REMOVES FMRI TRIGGER
    DrawFormattedText(win, 'Loading...', 'center', 'center', ...
        param.fontColor, [], [], [], 1.4);
    Screen('Flip', win);
   
    
    % fixation cross after MRI trigger / enter press
    if param.isQuest
        recordValidKeys(GetSecs, inf, param.kb_experimenter, {'Return', param.exitKey});
        if strcmp(param.exitKey, responseKey)
            exitNow = 1;
        end
    else
        recordValidKeys(GetSecs, inf, param.kb_experimenter, {param.fMRIkey, param.exitKey});
        if strcmp(param.exitKey, responseKey)
            exitNow = 1;
        end
    end
    if exitNow, break, end
    % COMMENTING ABOVE SECTION REMOVES FMRI TRIGGER
    
    %Screen('FillRect', win, param.chColor, param.chRect);
    %Screen('Flip', win);
    Screen('TextSize', win, param.TextSize_q); % make text larger for questions
    
    % run 10 dummy trials to orient subject to task in scanner
     if param.isQuest && trialNum < param.nTrialsBetweenBreaks
         param_dummy = param;
         data_dummy = data;
         TC_dummyTrials(win, param_dummy, data_dummy)
     end
    
    % run an uninterrupted series of trials
    data.blockStartTime{trialNum/param.nTrialsBetweenBreaks+1} = clock;
    for t = 1 : param.nTrialsBetweenBreaks
        
        trialNum = trialNum + 1;
        
        % run the current trial        
        if param.exemplar_threshold
            curr_cat = ceil(trials.qID(trialNum)/param.stimExemplars);
            curr_exemplar = trials.qID(trialNum) - ((curr_cat - 1) * param.stimExemplars);
        else
            curr_cat = ceil(trials.stimID(trialNum)/param.stimExemplars);
            curr_exemplar = trials.stimID(trialNum) - ((curr_cat - 1) * param.stimExemplars);
        end
        data.exemplar{trialNum} = [param.categories{curr_cat}, ...
            num2str(curr_exemplar)];
        
        [data, exitNow, q] = TC_runTrial(win, param, trials, ...
            trialNum, data, t, q);
        
        if exitNow, break, end
        if trialNum == trials.nTrials, break, end
    end


    if exitNow, break, end
    if ~param.isPractice && ~param.isQmini
        save(param.dataFile, 'param', 'data', 'q', 'trials', '-append');
    end
     if param.isQmini
         TC_plotBlockData(data, param);
     end
end

data.blockEndTime = clock;
end
