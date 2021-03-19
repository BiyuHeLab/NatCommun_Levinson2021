% Presents a sequence of 5 words to ensure subject can see areas of the
% screen necessary for task.
% Words progress following any key press.
% First sequence is for before subject is pushed into scanner. Second
% sequence is for after subject is in bore to confirm vision.

close all; clear;

exp_type = init_exptype(); 
exp_type.isfMRI = 1;
exp_type.isDebug = 0;

% open PT window
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end
[win, num, wRect] = openScreen(0, winsize); % wRect is used, but not num

[param, trials] = TC_getParameters(win, 50, exp_type);

keys = union(param.AllResponseKeys, param.readyKey);
kb = param.kb_experimenter;

Screen('FillRect', win, param.BGcolor); Screen('Flip', win);

% begin first sequence after 'enter' press
detectKey = recordValidKeys(GetSecs, inf, kb, {param.exitKey, param.readyKey});
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'hand', 'center', 'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'moose', 'left', 'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'table', 'center', [], param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'three', 'right', 'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'dedicate', 'center', 0.95*wRect(4), param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
Screen('Flip', win);

% begin second sequence after 'enter' press
detectKey = recordValidKeys(GetSecs, inf, kb, {param.exitKey, param.readyKey});
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'believe', 'center', 'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'sofa', 'left', 'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'green', 'center', [], param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'person', 'right', 'center', param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
DrawFormattedText(win, 'screen', 'center', 0.95*wRect(4), param.fontColor, [], [], [], 1.4);
Screen('Flip', win);

detectKey = recordValidKeys(GetSecs, inf, kb, keys);
if strcmp(param.exitKey, detectKey), sca; return; end
Screen('Flip', win);

% wait for esc to exit
detectKey = recordValidKeys(GetSecs, inf, kb, param.exitKey);
sca;