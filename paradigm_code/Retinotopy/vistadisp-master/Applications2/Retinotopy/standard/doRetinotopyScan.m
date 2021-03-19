function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 11.09.15 JW added a check for modality. If modality is ECoG, then call
%           ShowScanStimulus with the argument timeFromT0 == false. See
%           ShowScanStimulus for details. 

% defaults
if ~exist('params', 'var'), error('No parameters specified!'); end

% make/load stimulus
stimulus = retLoadStimulus(params);

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);

try
    % check for OpenGL
    %AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    Screen('Preference','SkipSyncTests', 1);
    
    % Open the screen
    params.display                = retOpenScreen(params.display, 0);
    params.display.devices        = params.devices;
    
    % to allow blending
    Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Store the images in textures
    stimulus = createTextures(params.display,stimulus);
    
    % If necessary, flip the screen LR or UD  to account for mirrors
    % We now do a single screen flip before the experiment starts (instead
    % of flipping each image). This ensures that everything, including
    % fixation, stimulus, countdown text, etc, all get flipped.
    retScreenReverse(params, stimulus);
    
    % If we are doing ECoG, then add photodiode flash to every other frame
    % of stimulus. This can be used later for syncing stimulus to electrode
    % outputs.
    stimulus = retECOGtrigger(params, stimulus);
    
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        retResetColorMap(params);
        
        % wait for go signal
        onlyWaitKb = false;
        promptString = {'Please fixate on the center dot.'; 'Press any key whenever its color changes.'};  % 7/14/17 MAX add brief instructions
        pressKey2Begin(params.display, onlyWaitKb, [], [promptString], params.triggerKey); % promptString is displayed until fMRI trigger
        % see MAX update to pressKey2Begin for NYU 7T fMRI trigger issues


        % If we are doing eCOG, then signal to photodiode that expt is
        % starting by giving a patterned flash
        retECOGdiode(params);
        
        % countdown + get start time (time0)
        if isfield(params, 'countdown') && params.countdown > 0 % ignore countdown if params.countdown is 0 (9/21/17 MAX)
            % note this is apparently accounted for in the countDown
            % script, but it is messy and this may help account for trigger
            % issues.
            [time0] = countDown(params.display,params.countdown,params.startScan, params.trigger);
        else
            time0 = GetSecs;
        end
        time0   = time0 + params.startScan; % we know we should be behind by that amount
        
        
        % go
        if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
            timeFromT0 = false;
        else timeFromT0 = true;
        end
        [response, timing, quitProg] = showScanStimulus(params.display,stimulus,time0, timeFromT0); %#ok<ASGLU>
        
        % reset priority
        Priority(0);
        
        % get performance
        [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        fprintf('[%s]: percent correct: %.1f %%, reaction time: %.1f secs',mfilename,pc,rc);
        
        % save
        if params.savestimparams,
            filename = ['C:\Users\stimulus\Desktop\Experiments\HLTP_fMRI\paradigm_code\Retinotopy\' datestr(now,30) '.mat'];
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.', mfilename,filename);
        end;
        
        % don't keep going if quit signal is given
        if quitProg, break; end;
        
    end;
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);

catch ME
    % clean up if error occurred
    Screen('CloseAll'); setGamma(0); Priority(0); ShowCursor;
    warning(ME.identifier, ME.message);
end;


return;








