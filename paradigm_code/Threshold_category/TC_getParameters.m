function [p, trials] = TC_getParameters(window, distFromScreen_inCm, exp_type)

p.TextSize = 45
p.TextSize_q = 55; %text size for questions should be much larger than for instructions
%distFromScreen_inCm = 100;
p.stimSize = 300;%200;


Screen('TextSize', window, p.TextSize)


p.eyetracking = exp_type.eyetracking;
p.isPractice = exp_type.isPractice;
p.isfMRI = exp_type.isfMRI;
p.isMSB = exp_type.isMSB;
p.isQuest = exp_type.isQuest;
p.isQmini = exp_type.isQmini;
p.isDebug = exp_type.isDebug;
p.isBB = exp_type.isBB;
p.exemplar_threshold = exp_type.exemplar_threshold;

if ~p.isDebug, HideCursor(window); end;    

p.distFromScreen_inCm = distFromScreen_inCm;
p.BGcolor   = 127;
p.fontColor = 0;
p.chColor   = 90;
p.chColorR1 = 0;  % crosshair color after response
p.chColorR2 = 0; % crosshair color after rating

%% INPUT: keyboard / button boxes
if IsOSX % set up for NYU downtown
    d = PsychHID('Devices');
    
    for i = 1:length(d)
        if strcmp(d(i).usageName, 'Keyboard')
            %if strcmp(d(i).transport, 'Bluetooth')
                kb_experimenter = i;
            %elseif strcmp(d(i).transport, 'USB')
                kb_subject = i;
            %end
        end
    end
        
    if p.isBB
        p.kb_experimenter = kb_experimenter;
        p.kb_subject      = kb_subject;
    else
        p.kb_experimenter = kb_experimenter;
        p.kb_subject      = p.kb_experimenter;
    end
%     p.keyboardNumber = getKeyboardNumber;
else
    p.kb_experimenter = [];
    p.kb_subject      = p.kb_experimenter;
end

%% stimulus parameters

p.imsize = [300 300];   % pixels (all stimuli should have same resolution)
p.stimNumber = 1;       % number of stimuli presented in each trial
p.stimExemplars = 5;    % number of unique images in each category
p.stimDir = 'stimuli\'; % these are unprocessed pictures
p.proc_stim =  'norm_stim_data_final/';% processed image data matrices
p.categories = {'face', 'house', 'object', 'animal'};
p.graded = 1;           % graded stimulus presentation. 
% filter
x1 = -1:(2/(p.imsize(1) - 1)):1; x2 = x1;
[X1,X2] = meshgrid(x1, x2);
F = mvnpdf([X1(:) X2(:)], [0 0], [.2 0; 0 .2]);
F = reshape(F,length(x2),length(x1));
F = F - min(min(F)); 
p.filter = F ./ max(max(F));
p.stimContrast = .7;

% Defines the spatial-frequency bandwidth in units of Octaves. 
% The spatial-frequency bandwidth determines the cutoff of the filter 
% response as frequency content in the input image varies from the 
% preferred frequency, 1/LAMBDA. 
p.SpatialAspectRatio = 1; % gaussian filter

% size
p.stimWidth_inDegrees  = 15;
p.stimWidth_inPixels   = degrees2pixels(p.stimWidth_inDegrees, distFromScreen_inCm);
p.stimHeight_inPixels  = p.stimWidth_inPixels;

p.cycles_perDegree      = 2;
p.cycleLength_inDegrees = 1/p.cycles_perDegree;
p.cycleLength_inPixels  = degrees2pixels(p.cycleLength_inDegrees, distFromScreen_inCm); 

% angles
p.stimRadialDistance_inDegrees = 4;
p.stimRadialDistance_inPixels  = degrees2pixels(p.stimRadialDistance_inDegrees, distFromScreen_inCm);

p.nStim_perTrial      = 2;
angleIncrement        = 2*pi / p.nStim_perTrial;
p.angleList_inRadians = 0 : angleIncrement : 2*pi - angleIncrement;
p.angleList_inDegrees = p.angleList_inRadians * (180 / pi);

% crosshair
p.chWidth_inDegrees = .7;
%p.chRect = makeCrosshairDestRect(degrees2pixels(p.chWidth_inDegrees, distFromScreen_inCm));
p.chRect = makeCrosshairDestRect(degrees2pixels(p.chWidth_inDegrees, 120));


%% trial parameters
% - if fixedResponseDuration = 1, we wait for responseDuration_inSecs to play
%   out on each trial, no matter when subject answers
% - if fixedResponseDuration = 0, we exit response period once subject
%   enters a response
%p.fixedResponseDuration = 1;%0;

% trial timing specified here
    % adjusted postStimDuration_inSecs to 2
    % adjusted responseDuration_inSecs to 2
p.chDuration_inSecs       = 0.3;
p.stimDuration_inSecs     = 4/60;
if p.exemplar_threshold
    p.postStimDuration_inSecs = 0.5;
    p.responseDuration_inSecs = 1.5;
    p.ITIDuration_inSecs = 0.5;
else
    p.postStimDuration_inSecs = 2;     % buffer b/t stim and response
    p.responseDuration_inSecs = 2;     % if Inf, subject has no time limit to respond
    p.ITIDuration_inSecs      = 0.75;  % extra time at end of trial to finalize data collection
end

% rest periods specified here
p.nTrialsBetweenBreaks = 24;
p.breakDuration_inSecs = 600;  % if Inf, break is ended by subject
p.breakWarning_inSecs  = 10;  % point at which time left starts to count down
p.breakBuffer_inSecs   = 0;   % buffer b/t end of break and start of next trial

%% allowed response keys

p.exitKey='ESCAPE';
p.readyKey='Return';

if p.isMSB
    p.YesResponseKey = '7&';
    p.NoResponseKey = '8*';
    p.Category1Key = '6^';
    p.Category2Key = '7&';
    p.Category3Key = '8*';
    p.Category4Key = '9(';
elseif p.isPractice
    p.YesResponseKey = '2@';
    p.NoResponseKey = '3#';
    p.Category1Key = '1!';
    p.Category2Key = '2@';
    p.Category3Key = '3#';
    p.Category4Key = '4$';
else    
    p.YesResponseKey = '3#';%'8*';
    p.NoResponseKey = '4$';%'9(';
    p.Category4Key = '5%';%'a';
    p.Category1Key = '2@';%'7&';
    p.Category2Key = '3#';%'8*';
    p.Category3Key = '4$';%'9(';
    % switch to below list if practicing in 7T control room
%     p.YesResponseKey = '2@';
%     p.NoResponseKey = '3#';
%     p.Category4Key = '4$';
%     p.Category1Key = '1!';
%     p.Category2Key = '2@';
%     p.Category3Key = '3#';
end

p.allowedResponseKeys = {p.YesResponseKey p.NoResponseKey p.exitKey};
p.AllResponseKeys = {p.Category1Key p.Category2Key p.Category3Key p.Category4Key p.exitKey};
p.fMRIkey = '=+';
%% convert seconds to frames

%p.refreshRate_inHz = Screen('FrameRate',window);
p.flipInterval     = Screen('GetFlipInterval', window, 100, 0.00005, 20);
% use just for debugging:
%p.flipInterval     = 0.0167;
p.refreshRate_inHz = round(1/p.flipInterval);

% trial events in frames
p.chDuration_inFrames       = round(p.chDuration_inSecs / p.flipInterval);

p.stimDuration_inFrames     = round(p.stimDuration_inSecs / p.flipInterval);

p.postStimDuration_inFrames = round(p.postStimDuration_inSecs / p.flipInterval);
p.responseDuration_inFrames = round(p.responseDuration_inSecs / p.flipInterval);
p.ITIDuration_inFrames      = round(p.ITIDuration_inSecs / p.flipInterval);
% p.trialDuration_inFrames    = round(p.trialDuration_inSecs / p.flipInterval);

% trial events in actual seconds
p.true_chDuration_inSecs       = p.chDuration_inFrames * p.flipInterval;
p.true_stimDuration_inSecs     = p.stimDuration_inFrames * p.flipInterval;
p.true_postStimDuration_inSecs = p.postStimDuration_inFrames * p.flipInterval;
p.true_responseDuration_inSecs = p.responseDuration_inFrames * p.flipInterval;
p.true_ITIDuration_inSecs      = p.ITIDuration_inFrames * p.flipInterval;
% p.true_trialDuration_inSecs    = p.trialDuration_inFrames * p.flipInterval;

p.postResponseDelay = 0;
%% drawing tools etc

% stim rects
[p.midW, p.midH] = getScreenMidpoint(window);
p.windowRect    = Screen('Rect', window);
p.stimRect = [p.midW - p.stimSize, p.midH - p.stimSize, ...
    p.midW + p.stimSize, p.midH + p.stimSize];



% p.stimRect = [];
% for i = 1:length(p.angleList_inRadians)
%     angle = p.angleList_inRadians(i);
%     x_pos = p.stimRadialDistance_inPixels * cos(angle);
%     y_pos = p.stimRadialDistance_inPixels * sin(angle);
%     p.stimRect(:,i) = CenterRectOnPoint(stimRect, p.midW - x_pos, p.midH - y_pos)';
% end


% circle filter
x = [1:p.stimWidth_inPixels] - median(1:p.stimWidth_inPixels);
[xx, yy] = meshgrid(x);

p.stimRadii    = sqrt(xx.^2 + yy.^2);
p.circleFilter = (p.stimRadii <= p.stimWidth_inPixels/2);

trials.showResponseOptions = 1;
trials.autoCreate          = 1;
trials.nTrials             = 360;%1000