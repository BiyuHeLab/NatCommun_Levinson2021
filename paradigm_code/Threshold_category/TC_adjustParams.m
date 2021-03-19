function [p, trials] = TC_adjustParams(win, p, trials, paradigm)
switch paradigm
    case 'fMRI'
        p.fMRIkey = '=+';
        p.isfMRI = 1;
        trials.nTrials = 360; 
        [p.midW, p.midH] = getScreenMidpoint(win);
        p.windowRect    = Screen('Rect', win);
        p.flipInterval     = Screen('GetFlipInterval', win, 100, 0.00005, 20);

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
       
        p.postStimDuration_inSecs = 2;     % buffer b/t stim and response
        p.responseDuration_inSecs = 2;%4;     % if Inf, subject has no time limit to respond
        %p.ITIDuration_inSecs      = 10;  % extra time at end of trial to finalize data collection
        
        p.postStimDuration_inFrames = round(p.postStimDuration_inSecs / p.flipInterval);
        p.responseDuration_inFrames = round(p.responseDuration_inSecs / p.flipInterval);
       % p.ITIDuration_inFrames      = round(p.ITIDuration_inSecs / p.flipInterval);
        
        p.true_postStimDuration_inSecs = p.postStimDuration_inFrames * p.flipInterval;
        p.true_responseDuration_inSecs = p.responseDuration_inFrames * p.flipInterval;
       % p.true_ITIDuration_inSecs      = p.ITIDuration_inFrames * p.flipInterval;
        
        p.postResponseDelay = 1; % This is the flag to use if we want delay after response to a first question or a fixed timing
        
        n_categories = 4;
        n_exemplars_in_cat = 6; % 5 + 1 scrambled
        n_blocks = 15;%10;
        n_rep = 15;
        
        n_exemplars = n_categories * n_exemplars_in_cat;
        n_trials = n_rep * n_exemplars;
        p.nTrialsBetweenBreaks = n_trials / n_blocks; % number of trials in one block (24)
        
        % compute which exemplar to show on each trial (each image shown
        % once per block)
        exemplar_code = 1:n_exemplars;
        stim_all = [];
        for i = 1:n_blocks
            stim_order = exemplar_code(randperm(p.nTrialsBetweenBreaks));
            stim_all = [stim_all stim_order];
        end
        
%        % OLD EXEMPLAR RANDOMIZATION ACROSS ALL TRIALS
%         all_exemplars = repmat(exemplar_code, [1, n_rep]);
%         
%         bad_rand = 1;
%         while bad_rand
%             stim_all = all_exemplars(randperm(n_trials));
%             bad_rand = numel(find(diff(stim_all) == 0)) > 2;
%         end
        
        % Single block timing generation
        % MGL - 7/17/17
        
        % PRE-STIM TIMING
        max_time = 20 % seconds
        min_time = 6 % seconds
        delay_val = min_time:2:max_time;
        lambda = 0.125; % we can play with this but deviation from 1 will increase temporal prediction
        xdist = lambda * exp(-lambda * delay_val);
        xdist_norm = p.nTrialsBetweenBreaks * (xdist/ sum(xdist));
        count = round(xdist_norm);

        all_x = [];
        for i = 1:numel(delay_val)
            all_x = [all_x, ones(1, count(i)) * delay_val(i)];
        end

        % generate 15 blocks of permutated pre-stim timings
        pre_stim_all = [];
        for i = 1:n_blocks
            pre_stim_all = [pre_stim_all all_x(randperm(p.nTrialsBetweenBreaks))];
        end
%  figure;h = histogram(pre_stim_all);
%  h.BinEdges = [6:2:20];
%  xlabel('pre-stimulus blank period (s)');
%  ylabel('number of trials');
%  title('pre-stimulus blank period distribution, 360 total trials');
        
        % POST-STIM TIMING
        max_time = 6; % seconds
        min_time = 4; % seconds
        delay_val = min_time:2:max_time;
        lambda = 0.5; % we can play with this but deviation from 1 will increase temporal prediction
        xdist = lambda * exp(-lambda * delay_val);
        xdist_norm = p.nTrialsBetweenBreaks * (xdist/ sum(xdist));
        count = round(xdist_norm);

        all_x = [];
        for i = 1:numel(delay_val)
            all_x = [all_x, ones(1, count(i)) * delay_val(i)];
        end
 
        
        % generate 15 blocks of permutated post-stim timings
        post_stim_all = [];
        for i = 1:n_blocks
            post_stim_all = [post_stim_all all_x(randperm(p.nTrialsBetweenBreaks))];
        end
%  figure;h = histogram(post_stim_all);
%  h.NumBins = 2;
%  h.BinEdges = [4:2:6];
%  xlabel('post-stimulus blank period (s)');
%  ylabel('number of trials');
%  title('post-stimulus blank period distribution, 360 total trials');
  
  
        trials.nTrials = n_trials;
        trials.nBlocks = n_blocks;
        trials.stimID = stim_all;
                
        p.stimExemplars = n_exemplars_in_cat;
        
        p.pre_stim_all = pre_stim_all;
        p.post_stim_all = post_stim_all - p.true_stimDuration_inSecs;
        p.pre_stim_all_inFrames = round(pre_stim_all / p.flipInterval);
        p.post_stim_all_inFrames = round(post_stim_all / p.flipInterval);                       
        p.true_pre_stim_all_inSecs = p.pre_stim_all_inFrames * p.flipInterval;
        p.true_post_stim_all_inSecs = p.post_stim_all_inFrames * p.flipInterval;
        
        p.trialDuration_inSecs = pre_stim_all + post_stim_all + 4;
        p.trialDuration_inFrames = round(p.trialDuration_inSecs / p.flipInterval);
        p.true_trialDuration_inSecs = p.trialDuration_inFrames * p.flipInterval;
        
end