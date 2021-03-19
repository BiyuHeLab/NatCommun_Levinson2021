function crosshairDestRect = makeCrosshairDestRect(crosshairLength_inPixels,crosshairWidth_inPixels,midW,midH)
% crosshairDestRect = makeCrosshairDestRect(crosshairLength_inPixels,crosshairWidth_inPixels,midW,midH)
%
% Makes a destination rect for a crosshair to appear in the center of the
% screen. A 4 x 2 rect is returned, with the first column containing the
% rect for the vertical portion of the crosshair and the second column
% containing the rect for the horizontal portion. This 4 x 2 rect can be
% passed into Screen('FillRect') to draw the crosshair.
% 
% "crosshairLength_inPixels" is the size of the length of the crosshair in
% pixels. If not specified, length is defaulted to 20 pixels.
%
% "crosshairWidth_inPixels", if not specified, is defaulted to
% round(crosshairLength_inPixels / 10).
%
% "midW" and "midH" are the central pixel values for the width and height
% dimensions of the screen. They are retrieved using Screen('Rect') if not
% specified, so if you don't specify these values you must already have a
% PTB window open.
%
% REQUIRES: getScreenMidpoint.m
%
% History
% 11/21/07 BM wrote it.

%%%%% get default values for input variables, if not specified
if ~exist('crosshairLength_inPixels','var') || isempty(crosshairLength_inPixels)
    crosshairLength_inPixels = 20;
end

if ~exist('crosshairWidth_inPixels','var') || isempty(crosshairWidth_inPixels)
    crosshairWidth_inPixels = round(crosshairLength_inPixels / 10);
end

if ~exist('midW','var') || ~exist('midH','var') || isempty(midW) || isempty(midH)
    [midW,midH] = getScreenMidpoint;
end

%%%%% make dest rect for the crosshair
destCrosshairVertical = [midW-crosshairWidth_inPixels/2 midH-crosshairLength_inPixels/2 ...
                         midW+crosshairWidth_inPixels/2 midH+crosshairLength_inPixels/2];
destCrosshairHorizontal = [midW-crosshairLength_inPixels/2 midH-crosshairWidth_inPixels/2 ...
                           midW+crosshairLength_inPixels/2 midH+crosshairWidth_inPixels/2];
                       
crosshairDestRect = [destCrosshairVertical' destCrosshairHorizontal'];