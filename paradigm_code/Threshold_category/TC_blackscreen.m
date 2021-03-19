clear;
exp_type = init_exptype(); 
exp_type.isPractice = 0;
exp_type.isDebug = 0;

% open PT window
if exp_type.isDebug, winsize = [0 0 600 400]; else winsize = [];end
win = openScreen(0, winsize);

[param, trials] = TC_getParameters(win, 50, exp_type);

%keys = union(param.AllResponseKeys, param.exitKey);
kb = param.kb_experimenter;
param.BGcolor = 0;
Screen('FillRect', win, param.BGcolor); Screen('Flip', win); 

for t = 1:1000
    pause(2)
    [keyIsDown, secs, keyCode] = KbCheck(param.kb_experimenter);
    if keyIsDown && sum(strcmp(KbName(keyCode), param.exitKey))
        break;
    end
end
sca;
