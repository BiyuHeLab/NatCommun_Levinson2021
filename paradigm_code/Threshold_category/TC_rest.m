% TC_rest
clearvars;
% initialize experiment type
exp_type = init_exptype(); 
exp_type.isDebug = 0;

initials = input('Enter subjects initials:   ', 's');
run_number = input('Enter run number:   ', 's');
rest_duration = 5 * 60; %s
 
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end;

win = openScreen(0, winsize);

% get parameters:
param = TC_getParameters(win, 60, exp_type);
param.isfMRI = 1;  

if param.isfMRI        
    Screen('FillRect', win, param.BGcolor);
    DrawFormattedText(win, 'Please keep your eyes on the fixation cross once it appears.', 'center', 'center', ...
        param.fontColor, [], [], [], 1.4);
    Screen('Flip', win);
    recordValidKeys(GetSecs, inf, param.kb_experimenter, param.fMRIkey);
end

Screen('FillRect', win, param.BGcolor);
Screen('FillRect', win, param.chColor, param.chRect);
Screen('Flip', win);

% Wait for exit key, just in case:
recordValidKeys(GetSecs, rest_duration, param.kb_experimenter, param.exitKey);

% Finish
DrawFormattedText(win, TC_instructions('ThresholdEnd'), 'center', 'center', ...
    param.fontColor, [], [], [], 1.4);
Screen('Flip', win);
recordValidKeys(GetSecs, inf, param.kb_experimenter);
Screen('CloseAll');

