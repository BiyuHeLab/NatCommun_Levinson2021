function TC_prepare_screen(win, param, screen_name)
% make here all the screens for gap,etc

switch screen_name
    case 'loading'
        Screen('FillRect', win, param.BGcolor);
        Screen('TextSize', win, 25);
        Screen('TextColor', win, [255 0 0]);
        DrawFormattedText(win, 'Loading ...', 'center', 'center', param.fontColor);
end
end