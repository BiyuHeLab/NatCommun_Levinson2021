function HLTP_make_evs(raw_dir, proc_dir)

bhv_data = load([proc_dir, '/behavior/bhv_data.mat']);
load([raw_dir, '/datafile.mat']);
ntr = 227; % number of TRs per run
num_blocks = numel(data.exemplar) / 24;
bhv_data.categories = {'face', 'house', 'object', 'animal'};

proc_blocks = [1:num_blocks]; % if normal session
%proc_blocks = []; % change if processing abnormal number of blocks


%% Store all converted timing data in one large cell array
% creates evs and stores all data in blocktiming
% create copy of data timing for manipulating
% each timing value is the amount of time passed since the onset of the first trial
trial_iter = 1; %
for blk = proc_blocks
    trial_iter = blk * 24 - 23;
    blocktiming{blk} = struct('trialStart', data.timing.chOnset(trial_iter:trial_iter+23) ...
        - data.timing.chOnset(trial_iter), 'stimOnset', data.timing.stimVBL(trial_iter:trial_iter+23) ...
        - data.timing.chOnset(trial_iter), 'detectionR', data.timing.r1VBL(trial_iter:trial_iter+23) ...
        - data.timing.chOnset(trial_iter), 'categoryR', data.timing.r2VBL(trial_iter:trial_iter+23) ...
        - data.timing.chOnset(trial_iter), 'trialCompleteTime', ...
        data.timing.trialCompleteTime(trial_iter:trial_iter+23) - data.timing.chOnset(trial_iter));
    
    % convert to TR
    timings = {'trialStart' 'stimOnset' 'detectionR' 'categoryR' 'trialCompleteTime'};
    for t = 1:numel(timings)
        blocktiming{blk}.(timings{t}) = round(blocktiming{blk}.(timings{t}) ./ 2) + 1;
        blocktiming{blk}.(timings{t})(blocktiming{blk}.(timings{t}) > ntr) = [];
    end
    
    % include behavior
main_conditions = {'rec' 'unrec' 'real' 'scrambled' 'no_response_vis' 'no_response_cat'};
for i = 1:numel(main_conditions)
    curr_cond = main_conditions{i};
    idx = bhv_data.(curr_cond)(trial_iter:trial_iter+numel(blocktiming{blk}.stimOnset) - 1);
    blocktiming{blk}.(curr_cond) = blocktiming{blk}.stimOnset;
    blocktiming{blk}.(curr_cond) = blocktiming{blk}.stimOnset(idx == 1);
    blocktiming{blk}.([curr_cond '_ev']) = zeros(1, ntr);
    blocktiming{blk}.([curr_cond '_ev'])(blocktiming{blk}.(curr_cond)) = 1;
end
    blocktiming{blk}.no_response = blocktiming{blk}.stimOnset;
    no_response = bhv_data.no_response_vis(trial_iter:trial_iter+numel(blocktiming{blk}.stimOnset) - 1) | bhv_data.no_response_cat(trial_iter:trial_iter+numel(blocktiming{blk}.stimOnset) - 1);
    blocktiming{blk}.no_response = blocktiming{blk}.stimOnset(no_response == 1);
    blocktiming{blk}.no_response_ev = zeros(1, ntr);
    blocktiming{blk}.no_response_ev(blocktiming{blk}.no_response) = 1;
    blocktiming{blk}.no_response_response = [blocktiming{blk}.categoryR(no_response == 1) ...
        blocktiming{blk}.detectionR(no_response == 1)];
    blocktiming{blk}.no_response_response_ev = zeros(1, ntr);
    blocktiming{blk}.no_response_response_ev(blocktiming{blk}.no_response_response) = 1;
    
    blocktiming{blk}.visual_ev = zeros(1, ntr);
    blocktiming{blk}.visual_ev(blocktiming{blk}.stimOnset) = 1;
    
    blocktiming{blk}.response_ev = zeros(1, ntr);
    blocktiming{blk}.response_ev(blocktiming{blk}.categoryR) = 1;
    blocktiming{blk}.response_ev(blocktiming{blk}.detectionR) = 1;
    
    
    % categories
    cat_stimulus = bhv_data.cat_stimulus(trial_iter:trial_iter + numel(blocktiming{blk}.stimOnset) - 1);
    cat_response = bhv_data.cat_response(trial_iter:trial_iter + numel(blocktiming{blk}.stimOnset) - 1);
    cat_ev_names = {};
    resp_ev_names = {};
    for i = 1:numel(bhv_data.categories)
        curr_cat = bhv_data.categories{i};
        blocktiming{blk}.(curr_cat) = blocktiming{blk}.stimOnset(cat_stimulus == i);
        blocktiming{blk}.([curr_cat '_ev']) = zeros(1, ntr);
        blocktiming{blk}.([curr_cat '_ev'])(blocktiming{blk}.(curr_cat)) = 1;
        blocktiming{blk}.(['scrambled_' curr_cat '_ev']) = blocktiming{blk}.([curr_cat '_ev']) & blocktiming{blk}.scrambled_ev;
        blocktiming{blk}.([curr_cat '_ev']) = blocktiming{blk}.([curr_cat '_ev']) & blocktiming{blk}.real_ev;
        blocktiming{blk}.(['rec_' curr_cat '_ev']) = blocktiming{blk}.([curr_cat '_ev']) & blocktiming{blk}.rec_ev;
        blocktiming{blk}.(['unrec_' curr_cat '_ev']) = blocktiming{blk}.([curr_cat '_ev']) & blocktiming{blk}.unrec_ev;
        blocktiming{blk}.(['scrambled_rec_' curr_cat '_ev']) = blocktiming{blk}.(['scrambled_' curr_cat '_ev']) & blocktiming{blk}.rec_ev;
        blocktiming{blk}.(['scrambled_unrec_' curr_cat '_ev']) = blocktiming{blk}.(['scrambled_' curr_cat '_ev']) & blocktiming{blk}.unrec_ev;
        cat_ev_names = [cat_ev_names, curr_cat, ['rec_' curr_cat], ['unrec_' curr_cat], ['scrambled_' curr_cat], ['scrambled_rec_' curr_cat], ['scrambled_unrec_' curr_cat]];
        
        % same type of EVs but category is based on Q1 answer, not stimulus
        % includes both real and scrambled images unless specified
        blocktiming{blk}.([curr_cat '_response']) = blocktiming{blk}.stimOnset(cat_response == i);
        blocktiming{blk}.([curr_cat '_response_ev']) = zeros(1, ntr);
        blocktiming{blk}.([curr_cat '_response_ev'])(blocktiming{blk}.([curr_cat '_response'])) = 1;
        blocktiming{blk}.(['rec_' curr_cat '_response_ev']) = blocktiming{blk}.([curr_cat '_response_ev']) & blocktiming{blk}.rec_ev;
        blocktiming{blk}.(['unrec_' curr_cat '_response_ev']) = blocktiming{blk}.([curr_cat '_response_ev']) & blocktiming{blk}.unrec_ev;
        blocktiming{blk}.(['scrambled_' curr_cat '_response_ev']) = blocktiming{blk}.([curr_cat '_response_ev']) & blocktiming{blk}.scrambled_ev;
        blocktiming{blk}.(['real_' curr_cat '_response_ev']) = blocktiming{blk}.([curr_cat '_response_ev']) & ~blocktiming{blk}.scrambled_ev;
        blocktiming{blk}.(['scrambled_rec_' curr_cat '_response_ev']) = blocktiming{blk}.(['scrambled_' curr_cat '_response_ev']) & blocktiming{blk}.rec_ev;
        blocktiming{blk}.(['scrambled_unrec_' curr_cat '_response_ev']) = blocktiming{blk}.(['scrambled_' curr_cat '_response_ev']) & blocktiming{blk}.unrec_ev;
        blocktiming{blk}.(['real_rec_' curr_cat '_response_ev']) = blocktiming{blk}.(['real_' curr_cat '_response_ev']) & blocktiming{blk}.rec_ev;
        blocktiming{blk}.(['real_unrec_' curr_cat '_response_ev']) = blocktiming{blk}.(['real_' curr_cat '_response_ev']) & blocktiming{blk}.unrec_ev;
        
        resp_ev_names = [resp_ev_names, [curr_cat, '_response'], ['rec_' curr_cat '_response'], ['unrec_' curr_cat '_response'], ['scrambled_' curr_cat '_response'], ['scrambled_rec_' curr_cat '_response'], ['scrambled_unrec_' curr_cat '_response'], ['real_' curr_cat '_response'], ['real_rec_' curr_cat '_response'], ['real_unrec_' curr_cat '_response']];
    end
    
    % write evs
    ev_dir = [proc_dir, '/func/block', num2str(blk), '/evs/'];
    mkdir(ev_dir);
    ev_names = [main_conditions, 'visual', 'response', 'no_response', cat_ev_names];
    for i = 1:numel(ev_names)
        curr_ev = ev_names{i};
        dlmwrite([ev_dir, curr_ev, '_ev.txt'], blocktiming{blk}.([curr_ev '_ev']), 'delimiter', '\n');
    end
    mkdir([ev_dir, 'response_cat']);
    for i = 1:numel(resp_ev_names)
        curr_ev = resp_ev_names{i};
        dlmwrite([ev_dir, 'response_cat/', curr_ev, '_ev.txt'], blocktiming{blk}.([curr_ev '_ev']), 'delimiter', '\n');
    end
    mkdir([ev_dir, 'trials']);
    for t = 1:numel(trial_idx)
        dlmwrite([ev_dir, 'trials/trial_', num2str(t), '_ev.txt'], blocktiming{blk}.trial{t}, 'delimiter', '\n');
    end
end