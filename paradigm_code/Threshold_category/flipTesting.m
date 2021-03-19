clear;
Priority(1);
exp_type = init_exptype(); 
exp_type.isQuest = 1;
exp_type.isDebug = 0;

startData = startExperiment('HLTP');
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end;
win = openScreen(0, winsize);
%Screen('Preference', 'ConserveVRAM', 4096);

[param, trials] = TC_getParameters(win, startData.distFromScreen_inCm, exp_type);

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
        % flip
        if f == 1
            %if  ~param.isQuest
                data.timing.stimVBL = Screen('Flip', win);
            %else
                %data.timing.stimVBL(trialNum) = Screen('Flip', win, ...
                    %data.timing.chVBL(trialNum) - param.flipInterval/2);
            %end
            data.flip_int(f) = data.timing.stimVBL;
        else
            data.flip_int(f) = Screen('Flip', win, data.flip_int(f - 1) - param.flipInterval/2);
        end
    end
    Screen('FillRect', win, param.chColor, param.chRect);
    data.timing.postVBL = Screen('Flip', win);
    sca