function display = setDefaultDisplay
%  display = setDefaultDisplay
%  
%   Most of our expTools code relies on a display calibration. If no
%   calibration file is specified or available, then set some default
%   values. These are the default values.
%
%updated 2-16-2018 for CBI 7T BOLDScreen

display.screenNumber    = max(Screen('screens'));
[width, height] = Screen('WindowSize',display.screenNumber);
display.numPixels       = [width height];
display.dimensions      = [69.8 39.3];
display.pixelSize       = min(display.dimensions./display.numPixels);
display.distance        = 210;  %40;
display.frameRate       = 120;
display.cmapDepth       = q12;
display.gammaTable      = (0:255)'./255*[1 1 1];
display.gamma           = display.gammaTable;
display.backColorRgb    = [128 128 128 255];
display.textColorRgb    = [255 255 255 255];
display.backColorRgb    = 128;
display.backColorIndex  = 128;
display.maxRgbValue     = 255;
display.stimRgbRange    = [0 255];
display.bitsPerPixel    = 32;

