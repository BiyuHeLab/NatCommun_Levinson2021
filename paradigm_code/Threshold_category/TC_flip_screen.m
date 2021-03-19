function TC_flip_screen(win, param, screen_name)
% make here all the screens for gap,etc

switch screen_name
    case 'loading'
        Screen('FillRect', win, param.BGcolor);
        DrawFormattedText(win, 'Loading...', 'center', 'center', ...
        param.fontColor, [], [], [], 1.4);
        Screen('Flip', win);
    otherwise Screen('Flip', win);
end
end