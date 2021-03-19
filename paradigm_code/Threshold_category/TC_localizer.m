% visual localizer fMRI - task button press on repetition
% adapted from TC_localizer for MEG, HLTP task
% - 3/15/17, MWF

clear; close all;
exp_type = init_exptype();
exp_type.isDebug = 0;
exp_type.isfMRI = 1;
exitNow = 0;
initials = input('Enter subjects initials:   ', 's');

% sets debugging window size
if exp_type.isDebug, winsize = [0 0 900 600]; 
else winsize = [];end;

% opens window, applies parameters and stimulus contrast
win = openScreen(0, winsize);
param = TC_getParameters(win, 60, exp_type);
param.stimContrast = 1.3;
param.dataFile = ['data/', initials, 'data/locdata.mat'];

% if data file already exists, creates new one instead of overwriting
n = 2;
while exist(param.dataFile, 'file')
    param.dataFile = ['data/', initials, 'data/locdata', num2str(n), '.mat'];
    n = n + 1;
end
% creates data directory using subject's initials
data = [];
mkdir(['data/', initials, 'data']);
save(param.dataFile, 'param', 'data');

% localizer presets
n_trials = 14;%10; 
n_blocks = 20;%12;
n_exemplars = 5;

stimDuration_inSec = 0.5;%0.2;
inter_block_time = 7;%8, changed to 7 because it then waits for next TR to start next block
stimDuration_inFrames = round(stimDuration_inSec/ param.flipInterval );

%----- RUN TRIALS ---------------------------------------------------------

% show instructions
loc_instruct = ['One-back memory task.\n\n\n'...
            'Many images will appear on the screen, one at a time.\n\n'...
            'Please press any button when you see\n two identical images one after another.\n\n\n'...
            'The experiment is about to begin.'];  
Screen('FillRect', win, param.BGcolor);
DrawFormattedText(win, loc_instruct, 'center', 'center', ...
    param.fontColor, [], [], [], 1.8);
Screen('Flip', win);

data.timing.trial_offset = zeros(n_blocks, n_trials);
data.timing.stim_onset = zeros(n_blocks, n_trials);
data.timing.trial_onset = zeros(n_blocks, n_trials);

n_categories = numel(param.categories);
n_block_rep = 5;
block_type = [1 * ones(1, n_block_rep), 2 * ones(1, n_block_rep), ...
    3 * ones(1, n_block_rep), 4 * ones(1, n_block_rep)];
block_type = block_type(randperm(numel(block_type)));

% one TR of fixation cross
triggerKey = recordValidKeys(GetSecs, inf, param.kb_experimenter, {param.fMRIkey, param.exitKey});
if strcmp(param.exitKey, triggerKey)
    Screen('CloseAll'); return
end

Screen('FillRect', win, param.chColor, param.chRect);
Screen('Flip', win);
param.stimContrast = 1.7;
for blockNum = 1:n_blocks
    %choose exemplars per block
    
    
    block_exemplar = repmat(1:n_exemplars, 1, (n_trials + 1) / n_exemplars);
    block_exemplar = block_exemplar(randperm(numel(block_exemplar)));
    block_exemplar(end) = [];
    recordValidKeys(GetSecs, inf, param.kb_experimenter, param.fMRIkey); % block start trigger
    for trialNum = 1:n_trials

        % keyboard check
        [keyIsDown, secs, keyCode] = KbCheck(param.kb_experimenter);
        if keyIsDown && sum(strcmp(KbName(keyCode), param.exitKey))
            exitNow = 1; break;
        end
        % present fixation cross
        Screen('FillRect', win, param.chColor, param.chRect);
        data.timing.trial_onset(blockNum, trialNum) = Screen('Flip', win);
        if trialNum > 1
            data.timing.trial_offset(blockNum, trialNum - 1) = data.timing.trial_onset(blockNum, trialNum);
        end
        % load exemplar
        curr_cat = block_type(blockNum);
        curr_exemplar = block_exemplar(trialNum);

        data.exemplar{blockNum, trialNum} = [param.categories{curr_cat}, ...
            num2str(curr_exemplar)];
        param.pic_dir = [param.proc_stim, data.exemplar{blockNum, trialNum}];
        % create stimulus using exemplar loaded, saving it as well to data
        stimTex = TC_makeTrialStim(win, param);
        %save(param.dataFile, 'param', 'data', '-append');
    
        data.flip_int = zeros(1, param.stimDuration_inFrames); % record timing for each frame of stimulus
        for f = 1 : stimDuration_inFrames
            % draw stim and crosshair on top:
            Screen('FillRect', win, param.BGcolor);
            
            Screen('DrawTexture', win,  stimTex(ceil(numel(stimTex)/2)), [], param.stimRect);
            
            Screen('FillRect', win, param.chColor, param.chRect);

            if f == 1
                data.timing.stim_onset(blockNum, trialNum) = Screen('Flip', win, ...
                    data.timing.trial_onset(blockNum, trialNum) + 0.5...
                    - param.flipInterval/2);
                data.flip_int(f) = data.timing.stim_onset(blockNum, trialNum);
            else
                data.flip_int(f) = Screen('Flip', win);
            end
        end
          
    end
    Screen('FillRect', win, param.chColor, param.chRect);
    data.timing.trial_offset(blockNum, trialNum) = Screen('Flip', win);
    pause(inter_block_time);
    if exitNow, break; end
end
pause(1); % to finish the last TR
% saves data file
save(param.dataFile, 'param', 'data', '-append');

% display end of localizer screen
DrawFormattedText(win, TC_instructions('ThresholdEnd'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
recordValidKeys(GetSecs, inf, param.kb_experimenter);
Screen('CloseAll');

stim_duration = data.timing.trial_offset(1, :) - data.timing.stim_onset(1, :);
trial_blank = data.timing.stim_onset(1, 2:end) - data.timing.trial_offset(1, 1:(n_trials-1));
trial_duration = diff(data.timing.stim_onset(1, :));
block_duration = data.timing.trial_onset(2, 1) - data.timing.trial_onset(1, 1);
inter_block_blank = data.timing.trial_onset(2, 1) - (data.timing.trial_offset(1, n_trials));

