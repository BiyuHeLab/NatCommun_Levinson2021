% win       experimental window
% param     parameters

% data.timing fields:
%    chOnset - trials start / blank, fixation
%    stimVBL - stimulus presentation time

function [data, exitNow, q] = TC_runTrial(win, param, trials, trialNum, ...
    data, t, q)
 
%------ Experimenter manual exit-------------------------------------------
exitNow = 0;
Priority(1);

[keyIsDown, secs, keyCode] = KbCheck(param.kb_experimenter);
if keyIsDown && sum(strcmp(KbName(keyCode), param.exitKey))
    exitNow = 1; return
end

Screen('TextSize', win, param.TextSize_q);
%------ Fixation point-----------------------------------------------------
%Screen('FillRect', win, param.BGcolor); 
Screen('FillRect', win, param.chColor, param.chRect);
%if ~param.isQuest && rem(trialNum - 1, 24) == 0 % if first trial of block
if t == 1 % if first trial of block
    data.timing.chOnset(trialNum) = Screen('Flip', win); % record PT timing
else
    Screen('Flip', win);
    data.timing.chOnset(trialNum) = data.timing.trialCompleteTime(trialNum-1);
end


% ---- Prepare stimulus ---------------------------------------------------

param.pic_dir = [param.proc_stim, data.exemplar{trialNum}];

if param.isQmini
    if rand > 0.5, param.ITIDuration_inSecs = 2;
    else param.ITIDuration_inSecs = 3;
    end
    param.ITIDuration_inFrames = round(param.ITIDuration_inSecs / param.flipInterval);
    param.true_ITIDuration_inSecs = param.ITIDuration_inFrames * param.flipInterval;
    param.startTrInSec = param.true_ITIDuration_inSecs;
elseif param.isQuest
    if rand > 0.5, param.ITIDuration_inSecs = 0.75; 
    else param.ITIDuration_inSecs = 1.0;
    end
    param.ITIDuration_inFrames = round(param.ITIDuration_inSecs / param.flipInterval);
    param.true_ITIDuration_inSecs = param.ITIDuration_inFrames * param.flipInterval;
    param.startTrInSec = param.true_ITIDuration_inSecs;
else
    param.startTrInSec = param.true_pre_stim_all_inSecs(trialNum);
    param.true_postStimDuration_inSecs = param.true_post_stim_all_inSecs(trialNum);
end


if param.isQuest
    % get stim param for current quest
    if param.isQmini
        Wg = 10^(QuestMean(q(trials.qID(trialNum))));
        % check if stim param is in bounds
        if Wg < 0.5, Wg = 0.5;
        elseif Wg > 1.5, Wg = 1.5;
        end
        param.stimContrast = Wg * param.stimContrast(trials.stimID(trialNum));
    else
        Wg = 10^( QuestMean(q( trials.qID(trialNum) )) );
        if Wg > 0.8,       Wg = 0.8;%if Wg > 1, Wg = 1;
        elseif Wg < 0,   Wg = 0;
        end
        param.stimContrast = Wg;
    end
end

if param.isPractice
    invisible = 0.1; visible = 0.3;
    if rand > 0.5, param.stimContrast = visible; 
    else param.stimContrast = invisible; 
    end
end

stimTex = TC_makeTrialStim(win, param, trials.stimID(trialNum));    

%----- Prestimulus Gap ----------------------------------------------------
% Screen('FillRect', win, param.chColor, param.chRect);
% if param.isQuest || param.isPractice
%     if t == 1        
%         data.timing.chVBL(trialNum) = ...
%             Screen('Flip', win, data.timing.chOnset(trialNum) + ...
%             param.true_ITIDuration_inSecs - param.flipInterval/2);
%         % if this isn't the first trial, start immediately after previous trial has ended
%     else
%         % time trial start from start of previous trial
%         data.timing.chVBL(trialNum) = ...
%             Screen('Flip', win, data.timing.ITIVBL(trialNum-1) + ...
%             param.true_ITIDuration_inSecs - param.flipInterval/2);
%     end
% end

% save descriptive trial data
data.stimID(trialNum)       = trials.stimID(trialNum);
data.trialNum(trialNum)     = trialNum;
if param.isQuest && param.isQmini
    data.Wg(trialNum) = Wg;
else
    if numel(param.stimContrast) > 1 %if there is individual contrast for each exemplar
        data.Wg(trialNum) = param.stimContrast(data.stimID(trialNum));
    else
        data.Wg(trialNum) = param.stimContrast;
    end
end

if param.isQuest
    data.qID(trialNum)      = trials.qID(trialNum);
end

% ---- Present stimulus ---------------------------------------------------
data = TC_showTrialStim(stimTex, win, param, trialNum, data);
Screen('Close', stimTex);

% ----- Poststimulus Gap --------------------------------------------------
% NOW JUST ENCODED IN BEHAVIORAL RESPONSE SECTION % 
%if param.postStimDuration_inSecs > 0
%    Screen('FillRect', win, param.chColor, param.chRect);
%    data.timing.postVBL(trialNum) = Screen('Flip', win);
%end

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
    data.timing.r2VBL(trialNum) = Screen('Flip', win, ...
        data.timing.stimVBL(trialNum) + param.true_postStimDuration_inSecs - param.flipInterval/2); % includes stim duration in post-stim time
else
    data.timing.r2VBL(trialNum) = screen('Flip', win);
end

[catKey, data.catRT(trialNum), data.catTime(trialNum)] = ...
    recordValidKeys(data.timing.r2VBL(trialNum), ...
    param.true_responseDuration_inSecs - param.flipInterval/2, param.kb_subject, union(param.AllResponseKeys, param.exitKey)); % add "-param.flipInterval/2" so that the next flip will be on time

if param.isfMRI
% if response was much before end of trial, flip fixation cross to mark response
    if GetSecs < data.timing.r2VBL(trialNum) + param.true_responseDuration_inSecs - param.flipInterval/2
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
    data.timing.r1VBL(trialNum) = Screen('Flip',  win, ...
        data.timing.r2VBL(trialNum) + param.true_responseDuration_inSecs - param.flipInterval/2);
else
    data.timing.r1VBL(trialNum) = Screen('Flip',  win);
end

% wait for response:
[detectKey, data.detectRT(trialNum), data.detectTime(trialNum)] = ...
    recordValidKeys(data.timing.r1VBL(trialNum), ...
    param.responseDuration_inSecs - param.flipInterval/2, param.kb_subject, param.allowedResponseKeys); % added "param.flipInterval/2" here also

Screen('FillRect', win, param.chColor, param.chRect);
Screen('Flip', win); % flip fixation cross after response

% if response was much before end of trial, flip screen again to mark end
if param.postResponseDelay && GetSecs < data.timing.r1VBL(trialNum) + param.true_responseDuration_inSecs - param.flipInterval/2
    Screen('FillRect', win, param.chColor, param.chRect); Screen('Flip', win, ...
    data.timing.r1VBL(trialNum) + param.true_responseDuration_inSecs - param.flipInterval/2);
end % otherwise if response was at end, flipping again would unlock timing from TRs

%----sort out response-----------------------------------------------------
exitNow = 0;
switch detectKey
    case param.YesResponseKey,          data.detectR(trialNum) =  1;   
    case param.NoResponseKey,           data.detectR(trialNum) =  2;
    case 'noanswer',                    data.detectR(trialNum) = -1;
    case 'invalid',                     data.detectR(trialNum) = -2;
    case 'cell',                        data.detectR(trialNum) = -3;
    case param.exitKey,                 data.detectR(trialNum) = -4; exitNow = 1;
    otherwise,                          data.detectR(trialNum) = -5;
end
data.detectKey(trialNum) = detectKey(1);

switch catKey
    case param.Category1Key,          data.catR(trialNum) =  1;
    case param.Category2Key,          data.catR(trialNum) =  2;
    case param.Category3Key,          data.catR(trialNum) =  3;
    case param.Category4Key,          data.catR(trialNum) =  4;
    case 'noanswer',                  data.catR(trialNum) = -1;
    case 'invalid',                   data.catR(trialNum) = -2;
    case 'cell',                      data.catR(trialNum) = -3;
    case param.exitKey,               data.catR(trialNum) = -4; exitNow = 1;
    otherwise,                        data.catR(trialNum) = -5;
end
data.catKey(trialNum) = catKey(1);

if data.catR(trialNum) > 0 && data.catR(trialNum) <= numel(param.categories)
    data.selected_cat(trialNum) = ordr(data.catR(trialNum));
else
    data.selected_cat(trialNum) = data.catR(trialNum);
end

if param.isQuest && data.detectR(trialNum) >= 0
    q( trials.qID(trialNum) ) = ...
        QuestUpdate(q( trials.qID(trialNum) ), log10(Wg), ...
        data.detectR(trialNum) == 1);
end

Screen('Close', stimTex);
%---End Trial--------------------------------------------------------------
Screen('FillRect', win, param.chColor, param.chRect);

data.timing.trialCompleteTime(trialNum) = Screen('Flip', win);
% if param.isfMRI
%     data.timing.trialCompleteTime(trialNum) = Screen('Flip', win,...
%         data.timing.chOnset(trialNum) + param.true_trialDuration_inSecs(trialNum) - param.flipInterval/2); %trialVBL
% else
%     data.timing.trialCompleteTime(trialNum) = Screen('Flip', win,...
%         data.timing.r1VBL(trialNum) + param.true_responseDuration_inSecs - param.flipInterval/2);
% end
if param.isQuest
    data.timing.ITIVBL(trialNum) = data.timing.trialCompleteTime(trialNum);
end
%data.timing.trialCompleteTime(trialNum) = data.timing.trialVBL(trialNum);

end
