function TC_dummyTrials(win, param, data)

% win       experimental window
% param     parameters

 
%------ Experimenter manual exit-------------------------------------------
exitNow = 0;
[keyIsDown, secs, keyCode] = KbCheck(param.kb_experimenter);
if keyIsDown && sum(strcmp(KbName(keyCode), param.exitKey))
    exitNow = 1; return
end

%------ Fixation point-----------------------------------------------------
Screen('FillRect', win, param.chColor, param.chRect);
Screen('Flip', win);

% ---- Prepare stimulus ---------------------------------------------------


trials.stimID = randi(20, 1, 10);

data.exemplar = {};
for i = 1:10
    curr_cat = ceil(trials.stimID(i)/param.stimExemplars);
    curr_exemplar = trials.stimID(i) - ((curr_cat - 1) * param.stimExemplars);
    data.exemplar{i} = [param.categories{curr_cat}, num2str(curr_exemplar)];
end

for i = 1:10
param.pic_dir = [param.proc_stim, data.exemplar{i}];
invisible = 0.1; visible = .6; % might need to be further calibrated
if ~param.isQmini
    if rand > 0.5, param.stimContrast = visible; 
    else param.stimContrast = invisible;
    end
end
stimTex = TC_makeTrialStim(win, param, trials.stimID(i));

Screen('FillRect', win, param.chColor, param.chRect);
if i == 1 % if first trial of block
    data.timing.chOnset(i) = Screen('Flip', win); % record PT timing
else
    Screen('Flip', win);
    data.timing.chOnset(i) = data.timing.trialCompleteTime(i-1);
end

%----- Prestimulus Gap ----------------------------------------------------
Screen('FillRect', win, param.chColor, param.chRect);
param.startTrInSec = param.true_ITIDuration_inSecs;

% ---- Present stimulus ---------------------------------------------------

data = TC_showTrialStim(stimTex, win, param, i, data);
Screen('Close', stimTex);

% ----- Poststimulus Gap --------------------------------------------------
if param.postStimDuration_inSecs > 0
    Screen('FillRect', win, param.chColor, param.chRect);
    postVBL = Screen('Flip', win);
end

% ----- Get behavioral response -------------------------------------------
sx = 'center';
sy = 'center';
vSpacing = 1.4;

% ----- Recognition (Question1) -------------------------------------------
% randomize response options order:
ordr = randperm(4);
response_str = ['Image category: \n\n\n\n\n ',...
    param.categories{ordr(1)}, '      ', ...
    param.categories{ordr(2)},  '      ', ...
    param.categories{ordr(3)},  '      ', ...
    param.categories{ordr(4)}, '\n\n\n', ...
    '1          2          3          4'];

DrawFormattedText(win, response_str, sx, sy, param.fontColor, [], [], [], vSpacing);

if param.postStimDuration_inSecs > 0
    data.timing.r2VBL(i) = Screen('Flip', win, ...
        data.timing.stimVBL(i) + param.true_postStimDuration_inSecs - param.flipInterval/2); % includes stim duration in post-stim time
else
    data.timing.r2VBL(i) = screen('Flip', win);
end

[catKey, data.catRT(i), data.catTime(i)] = ...
    recordValidKeys(data.timing.r2VBL(i), ...
    param.true_responseDuration_inSecs - param.flipInterval/2, param.kb_subject, union(param.AllResponseKeys, param.exitKey)); % add "-param.flipInterval/2" so that the next flip will be on time

if param.isfMRI
% if response was much before end of trial, flip fixation cross to mark response
    if GetSecs < data.timing.r2VBL(i) + param.true_responseDuration_inSecs - param.flipInterval/2
        Screen('FillRect', win, param.chColor, param.chRect); Screen('Flip', win);
    end
end

if ~exist('catKey','var'), catKey = -1; end

% ----- Detection ---------------------------------------------------------
inst = 'PdetectionQ'; % seen / unseen
DrawFormattedText(win, TC_instructions(inst), sx, sy, ...
    param.fontColor, [], [], [], vSpacing);


% flip the response cue:
if param.postResponseDelay    
    data.timing.r1VBL(i) = Screen('Flip',  win, ...
        data.timing.r2VBL(i) + param.true_responseDuration_inSecs - param.flipInterval/2);
else
    data.timing.r1VBL(i) = Screen('Flip',  win);
end

% wait for response:
[detectKey, data.detectRT(i), data.detectTime(i)] = ...
    recordValidKeys(data.timing.r1VBL(i), ...
    param.responseDuration_inSecs - param.flipInterval/2, param.kb_subject, param.allowedResponseKeys); % added "param.flipInterval/2" here also

Screen('FillRect', win, param.chColor, param.chRect);
Screen('Flip', win); % flip fixation cross after response

% if response was much before end of trial, flip screen again to mark end
if GetSecs < data.timing.r1VBL(i) + param.true_responseDuration_inSecs - param.flipInterval/2
    Screen('FillRect', win, param.chColor, param.chRect); Screen('Flip', win, ...
    data.timing.r1VBL(i) + param.true_responseDuration_inSecs - param.flipInterval/2);
end % otherwise if response was at end, flipping again would unlock timing from TRs

%----sort out response-----------------------------------------------------
exitNow = 0;
switch detectKey
    case param.YesResponseKey,          data.detectR(i) =  1;   
    case param.NoResponseKey,           data.detectR(i) =  2;
    case 'noanswer',                    data.detectR(i) = -1;
    case 'invalid',                     data.detectR(i) = -2;
    case 'cell',                        data.detectR(i) = -3;
    case param.exitKey,                 data.detectR(i) = -4; exitNow = 1;
    otherwise,                          data.detectR(i) = -5;
end
data.detectKey(i) = detectKey(1);

switch catKey
    case param.Category1Key,          data.catR(i) =  1;
    case param.Category2Key,          data.catR(i) =  2;
    case param.Category3Key,          data.catR(i) =  3;
    case param.Category4Key,          data.catR(i) =  4;
    case 'noanswer',                  data.catR(i) = -1;
    case 'invalid',                   data.catR(i) = -2;
    case 'cell',                      data.catR(i) = -3;
    case param.exitKey,               data.catR(i) = -4; exitNow = 1;
    otherwise,                        data.catR(i) = -5;
end
data.catKey(i) = catKey(1);

if data.catR(i) > 0 && data.catR(i) <= numel(param.categories)
    data.selected_cat(i) = ordr(data.catR(i));
    data.selected_catName(i) = param.categories(data.selected_cat(i));
else
    data.selected_cat(i) = data.catR(i);
end


Screen('Close', stimTex);
%---End Trial--------------------------------------------------------------
Screen('FillRect', win, param.chColor, param.chRect);

if param.isfMRI
    data.timing.trialCompleteTime(i) = Screen('Flip', win,...
        data.timing.chOnset(i) + param.true_trialDuration_inSecs(i) - param.flipInterval/2); %trialVBL
else
    data.timing.trialCompleteTime(i) = Screen('Flip', win,...
        data.timing.r1VBL(i) + param.true_responseDuration_inSecs - param.flipInterval/2);
end
if param.isQuest
    data.timing.ITIVBL(i) = data.timing.trialCompleteTime(i);
end
%data.timing.trialCompleteTime(i) = data.timing.trialVBL(i);

end
