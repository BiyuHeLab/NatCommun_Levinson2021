clear;
exp_type = init_exptype(); 
exp_type.isPractice = 1;
exp_type.isDebug = 0;

% open PT window
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end
win = openScreen(0, winsize);

[param, trials] = TC_getParameters(win, 50, exp_type);
%SEE TC_getParameters to change crosshair size

% the following two lines should be uncommented if mac laptop
% TextSize = 30;
% Screen('TextSize', win, TextSize)
%uncomment if run on stim PC:
TextSize = 39;
Screen('TextSize', win, TextSize)

keys = union(param.AllResponseKeys, param.exitKey);
kb = param.kb_experimenter;


%----------- Welcome instructions ----------------------------------------

Screen('FillRect', win, param.BGcolor); Screen('Flip', win); pause(1);
DrawFormattedText(win, TC_instructions('instructions_overview'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4); Screen('Flip', win);
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

Screen('FillRect', win, param.BGcolor); Screen('Flip', win); pause(1);
DrawFormattedText(win, TC_instructions('overview'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4); Screen('Flip', win);
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end   

%--- Fixation example -----------------------------------------------------

DrawFormattedText(win, TC_instructions('fixation'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('FillRect', win, param.chColor, param.chRect); Screen('Flip', win); 
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

%--- Explain Resting state -----------------------------------------------
Screen('FillRect', win, param.BGcolor); Screen('Flip', win); pause(1);
DrawFormattedText(win, TC_instructions('rest'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4); Screen('Flip', win);
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

Screen('FillRect', win, param.chColor, param.chRect); Screen('Flip', win);
pause(4);

%--- Explain retinotopy ---------------------------------------------------
DrawFormattedText(win, TC_instructions('retinotopy'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end  

% loads and displays two screenshots from retinotopy
load retImage1.mat
load retImage2.mat

image1 = Screen('MakeTexture', win, imageArray);
image2 = Screen('MakeTexture', win, imageArray2);

Screen('DrawTexture', win, image1); Screen('Flip', win); pause(3);
Screen('DrawTexture', win, image2); Screen('Flip', win); pause(2);

Screen('DrawTexture', win, image2);
DrawFormattedText(win, ['Press any key to continue.'], 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end 

%--- images examples ------------------------------------------------------
DrawFormattedText(win, TC_instructions('ImageExamples'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

for trID = randperm(20)    
        c = ceil(trID/5);
        ex = trID - ((c - 1) * 5);

        data.exemplar = [param.categories{c}, num2str(ex)];
        param.pic_dir = [param.proc_stim, data.exemplar];
        param.stimContrast = 0.7
        stimTex = TC_makeTrialStim(win, param);
        
        % draw stim and crosshair on top:
        Screen('FillRect', win, param.BGcolor);
        Screen('DrawTextures', win, stimTex(ceil(numel(stimTex)/2)), [], param.stimRect);
        Screen('FillRect', win, param.chColor, param.chRect);
        Screen('Flip', win);
        detectKey = recordValidKeys(GetSecs, inf, kb, keys);
        if strcmp(param.exitKey, detectKey), break; end    

        Screen('FillRect', win, param.chColor, param.chRect);
        Screen('Flip', win);pause(0.5);
end

%--- Explain Localizer ----------------------------------------------------

DrawFormattedText(win, TC_instructions('localizer'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

stimDuration_inSec = 0.5;
stimDuration_inFrames = round(stimDuration_inSec/ param.flipInterval );
repetition_trials = [15, 30];
for trialNum = 1:40
    
    [keyIsDown, secs, keyCode] = KbCheck(param.kb_experimenter);
    if keyIsDown && strcmp(KbName(keyCode), param.exitKey)
        exitNow = 1; break;
    end
    
    Screen('FillRect', win, param.chColor, param.chRect); Screen('Flip', win);  
    if ~sum((repetition_trials - trialNum) == 0)
        curr_cat = randi(4);
        curr_exemplar = randi(5);
    end
    
    exemplar = [param.categories{curr_cat}, num2str(curr_exemplar)];
    param.pic_dir = [param.proc_stim, exemplar];
    
    stimTex = TC_makeTrialStim(win, param);
    
    for f = 1 : stimDuration_inFrames
        % draw stim and crosshair on top:
        if f == 1
            Screen('Flip', win, GetSecs + 0.5 - param.flipInterval/2);
        end
        Screen('FillRect', win, param.BGcolor);
        Screen('DrawTextures', win, stimTex(ceil(numel(stimTex)/2)), [], param.stimRect);
        Screen('FillRect', win, param.chColor, param.chRect);
        Screen('Flip', win);
    end
end

%--- Explain guess --------------------------------------------------------

DrawFormattedText(win, TC_instructions('Guess'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

%--- Show Question 1 ------------------------------------------------------
sx = 'center';
sy = 'center';
vSpacing = 1.4;

% randomize response options order:
ordr = randperm(4);
response_str = ['Image category: \n\n\n\n\n ',...
    param.categories{ordr(1)}, '      ', ...
    param.categories{ordr(2)},  '      ', ...
    param.categories{ordr(3)},  '      ', ...
    param.categories{ordr(4)}, '\n\n\n', ...
    '1          2          3          4'];

DrawFormattedText(win, response_str, sx, sy, param.fontColor, [], [], [], vSpacing);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end

%--- Explain experience ---------------------------------------------------

DrawFormattedText(win, TC_instructions('MeaningfulExperience'), 'center',...
    'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win); pause(1);
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end    

%--- Show Question 2 ------------------------------------------------------
inst = 'PdetectionQ'; % seen / unseen
DrawFormattedText(win, TC_instructions(inst), sx, sy, ...
    param.fontColor, [], [], [], vSpacing);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end

%--- Summary --------------------------------------------------------------
DrawFormattedText(win, TC_instructions('Summary'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win); pause(1)
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end


%---- Practice a block ----------------------------------------------------

trials.nTrials = 20;
params.nTrialsBetweenBreaks = trials.nTrials;
param.isfMRI = 0;
param.isMEG = 0;
param.isPractice = 1;
param.true_pre_stim_all_inSecs = 2*ones(1, trials.nTrials);
param.true_post_stim_all_inSecs = 1.5*ones(1, trials.nTrials);

trials.stimID = Shuffle(repmat(1:20, 1, 5));
TC_runBlock(win, param, trials, 0);

%---- Practice a faster block ---------------------------------------------
param.true_pre_stim_all_inSecs = 0.75*ones(1, trials.nTrials);
param.true_post_stim_all_inSecs = 1*ones(1, trials.nTrials);
param.true_responseDuration_inSecs = 1.5;

trials.stimID = Shuffle(repmat(1:20, 1, 5));
data1 = TC_runBlock(win, param, trials, 0);

%---- one more block ------------------------------------------------------
trials.stimID = Shuffle(repmat(1:20, 1, 5));
data2 = TC_runBlock(win, param, trials, 0);

% estimate accuracy score
seen = [(data1.detectR == 1) (data2.detectR == 1)];
unseen = [(data1.detectR == 2) (data2.detectR == 2)];
cat_response = [data1.selected_cat data2.selected_cat];
no_response_vis = [data1.detectR <= 0 data2.detectR <= 0];;
no_response_cat = cat_response <= 0;
exemplar = [data1.exemplar data2.exemplar];
categories = {'face' 'house' 'object' 'animal'};

correct = zeros(1, 40);
for trial_i = 1:40
    if cat_response(trial_i) > 0
        correct(trial_i) = ~isempty(strfind(exemplar{trial_i}, ...
            categories{cat_response(trial_i)}));
    end
end

seen = seen & ~no_response_vis & ~no_response_cat;
unseen = unseen & ~no_response_vis & ~no_response_cat;
correct = correct & ~no_response_vis & ~no_response_cat;
corr_S = (correct & seen); perc_corr_S = 100*sum(corr_S)/sum(seen);
corr_U = (correct & unseen); perc_corr_U = 100*sum(corr_U)/sum(unseen);

S_score = (100 - perc_corr_S)^2;
U_score = (25 - perc_corr_U)^2;

% display scores
DrawFormattedText(win, ['S score: ' num2str(S_score) ', U score: ' num2str(U_score) ', S-U: ' num2str(perc_corr_S - perc_corr_U)], 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
recordValidKeys(GetSecs, inf, kb, keys);

%---- Another practice block if performance is not good -------------------
trials.stimID = Shuffle(repmat(1:20, 1, 5));
data3 = TC_runBlock(win, param, trials, 0);

%---- Display instructions about scanner ----------------------------------
inst = 'scanner_instructions'; % seen / unseen
DrawFormattedText(win, TC_instructions(inst), sx, sy, ...
    param.fontColor, [], [], [], vSpacing);
Screen('Flip', win); pause(1);
detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end

%---- End Practice --------------------------------------------------------

DrawFormattedText(win, TC_instructions('practiceEnd'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
recordValidKeys(GetSecs, inf, kb, keys);

Screen('CloseAll');




