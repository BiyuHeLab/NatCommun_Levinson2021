function [key RT secs] = recordValidKeys(startTime,duration,deviceNumber,validKeys)
% [key RT secs] = recordValidKeys(startTime,duration,deviceNumber,validKeys)
%
% Modified from recordKeys.
% - Functions the same way as recordKeys (see below), but:
%   * if cell array "validKeys" is specified, ignores all key presses not 
%     contained in validKeys
%   * if validKeys aren't specified, all key presses are considered valid
%   * always returns on valid key press
% - Contents of validKeys must be key labels as defined in KbName.
%   * e.g. validKeys = {'1!' '0)' 'space'};
%
% The third output variable "secs" is a GetSecs timestamp of the time at
% which the valid key was pressed. Value is 0 if duration expires without a
% valid key press.
%
% History
% 1/29/08 BM modified recordValidKeys from recordKeys.
% 6/30/08 BM made code more efficient; functionality is the same
% 8/03/08 BM added secs output
%
%
% *** recordKeys history ***
% Modified from collectKeys.
% Collects keypresses for a given duration.
% Duration is in seconds.
% If using OSX, you MUST provide a deviceNumber.
% If using Windows, you do not need to provide a deviceNumber -- if you do,
% it will be ignored.
% Optional argument exitIfKey: if exitIfKey==1, function returns after
% first keypress. 
%
% Example usage: do this if duration = length of event
%   [keys RT] = recordKeys(GetSecs,0.5,deviceNumber)
%
% Example usage: do this if duration = endEvent-trialStart
%   goTime = 0;
%   startTime = GetSecs;  % This is the time the trial starts
%   goTime = goTime + pictureTime;  % This is the duration from startTime to the end of the next event
%   Screen(Window,'Flip');
%   [keys RT] = recordKeys(startTime,goTime,deviceNumber);
%   goTime = goTime + blankTime;    % This is the duration from startTime to the end of the next event
%   Screen(Window,'Flip');
%   [keys RT] = recordKeys(startTime,goTime,deviceNumber);
%
% A note about the above example: it's best to calculate the duration from
% the beginning of each trial, rather than from the beginning of each
% event. Some commands may cause delays (like Flip), and if you calculate
% duration by event, these delays will accumulate. If you calculate
% duration from the beginning of the trial, your presentations may be a
% tiny bit truncated, but you'll be on schedule. It's your call.
% Even better: calculate duration from the beginning of the experiment.
%
% Using deviceNumber:
% KbCheck only collects from the first key input device found. On a laptop,
% this is usually the laptop keyboard. However, often you'll want to collect
% from another device, like the buttonbox in the scanner! You MUST specify
% the device number, or none of the input from the buttonbox will be
% collected. Device numbers change according to what order the USB devices
% were plugged in, and you may find that you can only perform this check
% ONCE using the command d=PsychHID('Devices'); so DO NOT change the device
% arrangement (which port each is plugged into) after performing the check.
% Restarting Matlab will allow you to use d=PsychHID('Devices') again
% successfully.
% On Windows, KbCheck records simultaneously from all keyboards -- you
% cannot specify.
%
% collectKeys:
% JC 02/16/2006 Wrote it.
% JC 02/28/2006 Added deviceNumber.
% JC 08/14/2006 Added break if time is up, even if key is being held down.
% recordKeys:
% JC 03/31/2007 Changed from etime to GetSecs. Added platform check. Added cell check.
% JC 07/02/2007 Added exitIfKey.
% JC 08/02/2007 Fixed "Don't start until keys are released" to check for
% duration exceeded

myStart = GetSecs;    % Record the time the function is called (not same as startTime)
key=[];
KbName('UnifyKeyNames');

if exist('validKeys','var') && ~isempty(validKeys)
    keyIsValid = 0;
else
    keyIsValid = 1;
end

% set up KbCheck according to OS
if ~exist('deviceNumber','var')
    if IsOSX
        error('You are using OSX and you MUST provide a deviceNumber! recordValidKeys will fail.\n');
    else
        deviceNumber = [];
    end
    
end

% Don't start until keys are released
while KbCheck(deviceNumber)
    if GetSecs - startTime > duration, break, end
end

% Now check for keys
while (GetSecs - startTime) < duration
    [keyIsDown,secs,keyCode] = KbCheck(deviceNumber);
    if keyIsDown
        
        key = KbName(keyCode);
        RT = secs - myStart;

        if ~keyIsValid && ~iscell(key) && any(strcmp(validKeys,key))
            keyIsValid=1;
            break
        end
        
        if keyIsValid, break, end

    end
end

% check for bad inputs
if isempty(key)
    key = 'noanswer';
    RT = 0;
    secs = 0;
    
elseif iscell(key)  % Sometimes KbCheck returns a cell array (if multiple keys are mashed?)
    key = 'cell';
    RT = 0;
    secs = 0;
    
elseif ~keyIsValid
    key = 'invalid';
    RT = 0;
    secs = 0;
end