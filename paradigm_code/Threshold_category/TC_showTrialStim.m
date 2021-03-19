% show stimulus for defined amount of time
function data = TC_showTrialStim(stimTex, win, param, trialNum, data)
    data.flip_int = zeros(1, param.stimDuration_inFrames);
    
%     % flip 20 times before stimulus onset, to "warm up" display
%     for i = 1:10
%         %Screen('FillRect', win, param.BGcolor);
%         Screen('FillRect', win, param.chColor, param.chRect);
%         Screen('Flip', win);
%     end
    
    for f = 1 : param.stimDuration_inFrames    
        % draw stim and crosshair on top:
        %Screen('FillRect', win, param.BGcolor);
        Screen('DrawTextures', win, stimTex(max((numel(stimTex) > 1)*f, 1)), [], param.stimRect);
        Screen('FillRect', win, param.chColor, param.chRect);
        % flip
        if f == 1
            %if  ~param.isQuest
                data.timing.stimVBL(trialNum) = Screen('Flip', win, data.timing.chOnset(trialNum) + ...
                    param.startTrInSec - param.flipInterval/2);
            %else
                %data.timing.stimVBL(trialNum) = Screen('Flip', win, ...
                    %data.timing.chVBL(trialNum) - param.flipInterval/2);
            %end
            data.flip_int(f) = data.timing.stimVBL(trialNum);
        else
            data.flip_int(f) = Screen('Flip', win, data.flip_int(f - 1) - param.flipInterval/2);
        end
    end
    Screen('FillRect', win, param.chColor, param.chRect);
    data.timing.postVBL(trialNum) = Screen('Flip', win);

end