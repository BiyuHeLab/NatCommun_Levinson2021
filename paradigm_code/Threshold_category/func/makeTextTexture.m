function [textTexture, textRect] = makeTextTexture(window,textString,resetBGcolor,textSize,fontNameOrNumber)

% change text font and size if specified
if exist('textSize','var') && ~isempty(textSize)
    oldTextSize = Screen('TextSize',window,textSize);
end

if exist('fontNameOrNumber','var') && ~isempty(fontNameOrNumber)
    oldFontName = Screen('TextFont',window,fontNameOrNumber);
end

% draw text to back buffer and convert it to a texture
DrawFormattedText(window,textString);
textMatrix = Screen('GetImage',window,[],'backBuffer',[],1);
textMatrix = trimMatrixBorders(textMatrix);

textRect = RectOfMatrix(textMatrix);
textTexture = Screen('MakeTexture',window,trimMatrixBorders(textMatrix));

% reset text font and size
if exist('textSize','var') && ~isempty(textSize)
    Screen('TextSize',window,oldTextSize);
end

if exist('fontNameOrNumber','var') && ~isempty(fontNameOrNumber)
    Screen('TextFont',window,oldFontName);
end

% reset BG color if specified
if exist('resetBGcolor','var') && ~isempty(resetBGcolor)
    Screen('FillRect',window,resetBGcolor);
end