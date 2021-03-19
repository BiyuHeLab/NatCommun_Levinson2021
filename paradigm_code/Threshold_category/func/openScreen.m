function [window,keyboardNumber,wRect,midW,midH] = openScreen(windowPtrOrScreenNumber, winSize)
% [window,keyboardNumber,wRect,midW,midH] = openScreen(windowPtrOrScreenNumber)
%
% Opens a new screen using windowPtrOrScreenNumber.
% If no input is provided, screen is opened on max(Screen('Screens')).
% 
% Performs some common commands to do at experiment startup.
% - sets highest priority level
% - initializes some MEX files
% - hides cursor
% - unifies key names
%
% History
% 11/20/07 BM wrote it.

%% open window
if ~exist('windowPtrOrScreenNumber','var') || isempty(windowPtrOrScreenNumber)
    windowPtrOrScreenNumber = max(Screen('Screens'));
end

[window,wRect] = Screen('OpenWindow', windowPtrOrScreenNumber, [], winSize);

%% get screen midpoint
[midW,midH]=getScreenMidpoint(window);

%% do other useful PTB startup stuff
priorityLevel=MaxPriority(window);
Priority(priorityLevel);

%HideCursor;

KbName('UnifyKeyNames');

%% initialize some commonly used mex files
% these files take a bit of time to load the first time around
GetSecs;
WaitSecs(.001);

if IsOSX
    keyboardNumber = getKeyboardNumber;
    KbCheck(keyboardNumber);
else
    keyboardNumber = [];
    KbCheck;
end
    