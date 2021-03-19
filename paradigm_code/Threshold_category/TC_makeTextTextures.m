function t = TC_makeTextTextures(win, param)

[midW, midH] = getScreenMidpoint(win);

resetBGcolor = param.BGcolor;
Screen('TextColor', win, param.fontColor);

largeFontSize = 30;
smallFontSize = 15;

respOptions1 = '  1                 2\n';
respOptions2 = 'right              left';
respOptionsAll = [respOptions1 respOptions2];

[t.respText, respRect] = makeTextTexture(win, 'right or left?', resetBGcolor, largeFontSize);
[t.respOptions, respOptionsRect] = makeTextTexture(win, respOptionsAll,  resetBGcolor, smallFontSize);

t.respRect = CenterRectOnPoint(respRect, midW, ...
    midH - ceil(4 * param.stimHeight_inPixels / 2 + RectHeight(respRect)/2));
t.respOptionsRect = CenterRectOnPoint(respOptionsRect, midW, ...
    midH + ceil(4 * param.stimHeight_inPixels / 2 + RectHeight(respOptionsRect)/2));

end
