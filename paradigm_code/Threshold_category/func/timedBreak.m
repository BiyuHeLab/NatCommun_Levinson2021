function timedBreak(window,keyboardNumber,breakDuration,breakText,earlyExitOption,warningTime)
% timedBreak(window,keyboardNumber,breakDuration,breakText,earlyExitOption,warningTime)
%
% During a PTB experiment, take a break of predefined length. When the
% break is nearly over, display a countdown on the screen showing how many
% seconds are left.
%
% * breakDuration is the length of the break in seconds. If breakDuration
% is set to Inf, then the break ends when any button is pressed.
% * breakText is the text that is displayed to the subject during the
% break (e.g. "break time", or feedback on recent performance, etc).
% * earlyExitOption, if set to 1, allows the subject to exit out of the
% break before breakDuration seconds have passed by pressing any key. If 
% set to 0, the break will last exactly breakDuration seconds.
% * warningTime specifies when the countdown for the break begins to be
% displayed. The countdown appears when there are warningTime seconds left
% in the break. If warningTime is not specified, no countdown is provided.

t0 = GetSecs;

if ~exist('earlyExitOption','var') || isempty(earlyExitOption)
    earlyExitOption = 0;
end

exitOnNextKey = 0;
exitText = ['\n\nKey press registered.\n\n\n' ...
    'If you''re ready to continue, press any key again.'];

keypressBuffer = .3;

if exist('warningTime','var') && warningTime > 0
    showWarning = 1;
else 
    showWarning = 0;
end

DrawFormattedText(window,breakText,'center','center');
Screen('Flip',window);

%% break ends when user presses button
if breakDuration == Inf
    KbWait(keyboardNumber);

    breakText = [breakText exitText];
    DrawFormattedText(window,breakText,'center','center');
    Screen('Flip',window);
    WaitSecs(keypressBuffer);

    KbWait(keyboardNumber);
    
    return

%% break ends in specified time; countdown warning is shown
elseif showWarning
    while GetSecs - t0 < breakDuration - warningTime
        if earlyExitOption && KbCheck(keyboardNumber)
            if exitOnNextKey, return;
            else
                exitOnNextKey = 1;
                breakText = [breakText exitText];
                DrawFormattedText(window,breakText,'center','center');
                Screen('Flip',window);
                WaitSecs(keypressBuffer);
            end
        end
    end
    
    while GetSecs - t0 < breakDuration
        remainingTime_inSecs = breakDuration - ceil(GetSecs - t0) + 1;
        [nx ny] = DrawFormattedText(window,breakText,'center','center');
        DrawFormattedText(window,['\n\nexperiment resumes in\n' num2str(remainingTime_inSecs) ' seconds'],'center',ny);
        Screen('Flip',window);
        
        if earlyExitOption && KbCheck(keyboardNumber)
            if exitOnNextKey, return;
            else
                exitOnNextKey = 1;
                breakText = [breakText exitText];
                [nx ny] = DrawFormattedText(window,breakText,'center','center');
                DrawFormattedText(window,['\n\nexperiment resumes in\n' num2str(remainingTime_inSecs) ' seconds'],'center',ny);
                Screen('Flip',window);
                WaitSecs(keypressBuffer);
                
            end
        end
    end
else
    
%% break ends in specified time, no countdown
    while GetSecs - t0 < breakDuration
        if earlyExitOption && KbCheck(keyboardNumber)
            if exitOnNextKey, return;
            else
                exitOnNextKey = 1;
                breakText = [breakText exitText];
                DrawFormattedText(window,breakText,'center','center');
                Screen('Flip',window);
                WaitSecs(keypressBuffer);
                
            end
        end
    end
end