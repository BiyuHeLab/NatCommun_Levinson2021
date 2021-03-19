function TC_plotBlockData(data, param)
% plots behavioral data at end of each block and saves on dropbox
% plot will include all trials to date

fdir = 'C:\Users\stimulus\Dropbox\';% DROPBOX DIR

subj = 'sub'
categories = {'face', 'house', 'object', 'animal'};
exemplar = data.exemplar;
n_exemplars = 5;
scrambled_index = '6';

n = numel(data.exemplar);
n_trials = n;
seen = (data.detectR(1:n) == 1);
unseen = (data.detectR(1:n) == 2);
cat_response = data.selected_cat(1:n);
no_response_vis = data.detectR(1:n) <= 0;
no_response_cat = cat_response <= 0;

correct = zeros(1, n_trials);
for trial_i = 1:n_trials
    if cat_response(trial_i) > 0
        correct(trial_i) = ~isempty(strfind(data.exemplar{trial_i}, ...
            categories{cat_response(trial_i)}));
    end
end


%%% PLOT

if param.isQuest | param.isQmini
    categories = {'animal', 'face', 'house', 'object'};
    exemplar_labels = {'a1', 'a2', 'a3', 'a4', 'a5', 'f1', 'f2', 'f3', 'f4', ...
        'f5', 'h1', 'h2', 'h3', 'h4', 'h5', 'o1', 'o2', 'o3', 'o4', 'o5'};
    unique_exemplars = unique(exemplar(1:n_trials));
    
    
    %%%% take out trials with no response %%%%
    seen = seen & ~no_response_vis & ~no_response_cat;
    unseen = unseen & ~no_response_vis & ~no_response_cat;
    correct = correct & ~no_response_vis & ~no_response_cat;
    %%%%
    used_trials = seen | unseen;
    num_used_trials = sum(used_trials); %number of trials included in below analysis
    
    % percent correct for each category
    
    percent_seen = zeros(1, numel(categories));
    percent_correct_S = zeros(1, numel(categories));
    percent_correct_U = zeros(1, numel(categories));
    corr_S = (correct & seen);
    corr_U = (correct & unseen);
    
    % percent seen for each category
    cat_img = {};
    for i = 1:numel(categories)
        cat_img{i} = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i})) & used_trials;
        cat_labels{i} = [categories{i}, '\newline', num2str(sum(cat_img{i}))];
        percent_seen(i) = 100*sum(seen(cat_img{i}))/sum(cat_img{i});
        percent_correct_S(i) = 100*sum(corr_S(cat_img{i})) / sum(seen(cat_img{i}));
        percent_correct_U(i) = 100*sum(corr_U(cat_img{i})) / sum(unseen(cat_img{i}));
    end
    %cat_labels = categories;
    sub_title = {['Subject: ', subj], [num2str(num_used_trials), ' trials']};
    
    if ~param.isQmini
        f = figure('visible', 'off');
        subplot(2,3,1); hold on;
        bar(1, percent_seen(1), 'facecolor', [0 0 0]);
        bar(2, percent_seen(2), 'facecolor', [0.5 0.5 0.5]);
        bar(3, percent_seen(3), 'facecolor', [0 0 0]);
        bar(4, percent_seen(4), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
        plot([0 5], [50 50], 'r--'); ylabel('% seen'); ylim([1 100]);
        title(sub_title);
        
        subplot(2,3,2); hold on;
        bar(1:4, [percent_correct_S' percent_correct_U']);
        set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
        plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
        legend('seen', 'unseen');
        title(sub_title);
        
        subplot(2,3,3); hold on;
        bar(1:2, [nansum(percent_correct_S)/numel(categories) nansum(percent_correct_U)/numel(categories)]);
        set(gca, 'xtick', 1:2, 'xticklabel', {'S', 'U'});
        plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
        title(sub_title);
        
        % percent seen for each exemplar
        percent_seen_ex  = zeros(1, numel(unique_exemplars));
        percent_seen_corr = zeros(1, numel(unique_exemplars));
        percent_unseen_corr = zeros(1, numel(unique_exemplars));
        for i = 1:numel(unique_exemplars)
            curr_ex = strcmp(exemplar, unique_exemplars{i}) & used_trials;
            n_exemplars = sum(curr_ex);
            percent_seen_ex(i) = 100 * sum(seen(curr_ex)) / n_exemplars;
            percent_seen_corr(i) = 100 * sum(seen(curr_ex) & correct(curr_ex)) / sum(seen(curr_ex));
            percent_unseen_corr(i) = 100 * sum(unseen(curr_ex) & correct(curr_ex)) / sum(unseen(curr_ex));
        end
        
        a_index = [1:5];
        f_index = [6:10];
        h_index = [11:15];
        o_index = [16:20];
        
        subplot(2,3,4); hold on;
        bar(a_index, percent_seen_ex(a_index), 'facecolor', [0 0 0]);
        bar(f_index, percent_seen_ex(f_index), 'facecolor', [0.5 0.5 0.5]);
        bar(h_index, percent_seen_ex(h_index), 'facecolor', [0 0 0]);
        bar(o_index, percent_seen_ex(o_index), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels);
        plot([0 25], [50 50], 'r--'); ylabel('% seen'); ylim([1 100]);
        title(sub_title);
        
        subplot(2,3,5); hold on;
        bar(a_index, percent_seen_corr(a_index), 'facecolor', [0 0 0]);
        bar(f_index, percent_seen_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
        bar(h_index, percent_seen_corr(h_index), 'facecolor', [0 0 0]);
        bar(o_index, percent_seen_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
        plot([0 25], [25 25], 'r--'); ylabel('% correct of Seen'); ylim([1 100]);
        sub_title_S = {['Subject: ', subj], [num2str(sum(seen)), ' trials']};
        title(sub_title_S);
        
        subplot(2,3,6); hold on;
        bar(a_index, percent_unseen_corr(a_index), 'facecolor', [0 0 0]);
        bar(f_index, percent_unseen_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
        bar(h_index, percent_unseen_corr(h_index), 'facecolor', [0 0 0]);
        bar(o_index, percent_unseen_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
        plot([0 25], [25 25], 'r--'); ylabel('% correct of UnSeen'); ylim([1 100]);
        sub_title_U = {['Subject: ', subj], [num2str(sum(unseen)), ' trials']};
        title(sub_title_U);
        
        scrpos = [0.2708 0.3021 20.8646 9.4479]; % a good large but arbitrary figure size
        set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
        print([fdir, 'quest_behav'], '-dpng', '-r300'); close all;
        
    elseif param.isQmini
        f = figure('visible', 'off');
        subplot(1,2,1); hold on;
        bar(0.5, nansum(percent_seen) / numel(categories));
        xlabel('all images');
        set(gca, 'xtick', []);
        plot([0 1], [50 50], 'r--'); ylabel('% seen'); ylim([1 100]);
        title(sub_title);
        
        subplot(1,2,2); hold on;
        bar(1:2, [nansum(percent_correct_S)/numel(categories) nansum(percent_correct_U)/numel(categories)]);
        set(gca, 'xtick', 1:2, 'xticklabel', {'S', 'U'});
        plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
        title(sub_title);
        
        scrpos = [0.2708 0.3021 20.8646 9.4479]; % a good large but arbitrary figure size
        set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
        print([fdir, 'miniquest_behav'], '-dpng', '-r300'); close all;
    end
    
    % confusion matrices
    categories = {'face', 'house', 'object', 'animal'};
    cat_img = {};
    for i = 1:numel(categories)
        cat_img{i} = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i})) & used_trials;
    end
    
    conf_mat_S = zeros(numel(categories));     % Seen
    conf_mat_U = zeros(numel(categories));     % Unseen
    conf_mat_rea = zeros(numel(categories));   % Real
    
    % For each stimulus category
    for s = 1:numel(categories)
        stim_trials = cat_img{s};%(cat_protocol == s);
        real_stim_trials = stim_trials;
        % For each response category
        for r = 1:numel(categories)
            resp_trials = (cat_response == r);
            
            conf_mat_S(s, r) = sum(resp_trials(seen & real_stim_trials))...
                / sum(real_stim_trials & seen);
            conf_mat_U(s, r) = sum(resp_trials(unseen & real_stim_trials))...
                / sum(real_stim_trials & unseen);
            
            conf_mat_rea(s, r) = sum(resp_trials(real_stim_trials))...
                ./sum(real_stim_trials);
            
        end
    end
    
    % figures:
    cat_init = cell(1, numel(categories));
    for c = 1:numel(categories)
        cat_init{c} = categories{c}(1);
    end
    
    figure('visible', 'off', 'position', [40 40 400 400]);
    subplot(2, 2, 1);
    imagesc(conf_mat_rea, [0 1]); title('total')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    subplot(2, 2, 3)
    imagesc(conf_mat_S, [0 1]);     title('seen')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    subplot(2, 2, 4)
    imagesc(conf_mat_U, [0 1]);    title('unseen')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    set(gcf,'PaperPositionMode','auto');colormap hot
    print([fdir, '/conf_matsQ'], '-dpng', '-r300'); close all;
    
    
    
    
    
    
    %% main task
elseif ~param.isQuest
    scrambled_img = ~cellfun(@isempty, strfind(data.exemplar, scrambled_index));
    real_img = ~scrambled_img;
    
    exemplar_labels = {'a1', 'a2', 'a3', 'a4', 'a5', 'f1', 'f2', 'f3', 'f4', ...
        'f5', 'h1', 'h2', 'h3', 'h4', 'h5', 'o1', 'o2', 'o3', 'o4', 'o5', ...
        's1', 's2', 's3', 's4'};
    unique_exemplars = unique(exemplar(1:n_trials));
    
    categories = {'face', 'house', 'object', 'animal'};
    cat_img = {};
    for i = 1:numel(categories)
        cat_img{i} = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i}));
    end
    
    % confusion matrices
    conf_mat_S = zeros(numel(categories));     % Seen
    conf_mat_U = zeros(numel(categories));     % Unseen
    conf_mat_rea = zeros(numel(categories));   % Real
    conf_mat_scr = zeros(numel(categories));   % Scrambled
    
    % For each stimulus category
    for s = 1:numel(categories)
        stim_trials = cat_img{s};%(cat_protocol == s);
        real_stim_trials = stim_trials & real_img;
        scr_stim_trials = stim_trials & scrambled_img;
        % For each response category
        for r = 1:numel(categories)
            resp_trials = (cat_response == r);
            
            conf_mat_S(s, r) = sum(resp_trials(seen & real_stim_trials))...
                / sum(real_stim_trials & seen);
            conf_mat_U(s, r) = sum(resp_trials(unseen & real_stim_trials))...
                / sum(real_stim_trials & unseen);
            
            conf_mat_rea(s, r) = sum(resp_trials(real_stim_trials))...
                ./sum(real_stim_trials);
            conf_mat_scr(s, r) = sum(resp_trials(scr_stim_trials))...
                ./sum(scr_stim_trials);
            
        end
    end
    
    % figures:
    cat_init = cell(1, numel(categories));
    for c = 1:numel(categories)
        cat_init{c} = categories{c}(1);
    end
    
    f = figure('visible', 'off', 'position', [40 40 400 400]);
    subplot(2, 2, 1);
    imagesc(conf_mat_rea, [0 1]); title('real')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    subplot(2, 2, 2)
    imagesc(conf_mat_scr, [0 1]);    title('scram')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    subplot(2, 2, 3)
    imagesc(conf_mat_S, [0 1]);     title('seen')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    subplot(2, 2, 4)
    imagesc(conf_mat_U, [0 1]);    title('unseen')
    set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
    
    set(gcf,'PaperPositionMode','auto');colormap hot
    print([fdir, '/conf_mats'], '-dpng', '-r300'); close all;
    
    categories = {'animal', 'face', 'house', 'object'};
    %%%% take out trials with no response %%%%
    seen = seen & ~no_response_vis & ~no_response_cat;
    unseen = unseen & ~no_response_vis & ~no_response_cat;
    correct = correct & ~no_response_vis & ~no_response_cat;
    real_img = real_img & ~no_response_vis & ~no_response_cat;
    scrambled_img = scrambled_img & ~no_response_vis & ~no_response_cat;
    %%%%
    used_trials = sum(seen + unseen); %number of trials included in below analysis
    
    
    % percent seen for each category
    percent_seen_scrambled = 100 * sum(scrambled_img & seen)...
        /sum(scrambled_img);
    percent_seen_real = 100 * sum(real_img & seen) ...
        /sum(real_img);
    
    % percent correct for each category
    
    percent_seen = zeros(1, numel(categories));
    percent_correct_S = zeros(1, numel(categories));
    percent_correct_U = zeros(1, numel(categories));
    corr_S = (correct & seen & real_img);
    corr_U = (correct & unseen & real_img);
    
    cat_img = {};
    for i = 1:numel(categories)
        cat_img{i} = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i})) & real_img;
        cat_labels{i} = [categories{i}, '\newline', num2str(sum(cat_img{i}))];
        percent_seen(i) = 100*sum(seen(cat_img{i}))/sum(cat_img{i});
        percent_correct_S(i) = 100*sum(corr_S(cat_img{i})) / sum(seen(cat_img{i}) & real_img(cat_img{i}));
        percent_correct_U(i) = 100*sum(corr_U(cat_img{i})) / sum(unseen(cat_img{i}) & real_img(cat_img{i}));
    end
    %cat_labels = categories;
    cat_labels{5} = ['scr', '\newline', num2str(sum(scrambled_img))];
    sub_title = {['Subject: ', subj], [num2str(used_trials), ' trials']};
    
    f = figure('visible', 'off');
    subplot(2,3,1); hold on;
    bar(1, percent_seen(1), 'facecolor', [0 0 0]);
    bar(2, percent_seen(2), 'facecolor', [0.5 0.5 0.5]);
    bar(3, percent_seen(3), 'facecolor', [0 0 0]);
    bar(4, percent_seen(4), 'facecolor', [0.5 0.5 0.5]);
    bar(5, percent_seen_scrambled, 'facecolor', [0 0 0]);
    set(gca, 'xtick', 1:5, 'xticklabel', cat_labels);
    plot([0 6], [50 50], 'r--'); ylabel('% seen'); ylim([1 100]);
    title(sub_title);
    
    subplot(2,3,2); hold on;
    bar(1:4, [percent_correct_S' percent_correct_U']);
    set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
    plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
    legend('seen', 'unseen');
    title(sub_title);
    
    subplot(2,3,3); hold on;
    bar(1:2, [nansum(percent_correct_S)/numel(categories) nansum(percent_correct_U)/numel(categories)]);
    set(gca, 'xtick', 1:2, 'xticklabel', {'S', 'U'});
    plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
    title(sub_title);
    
    % percent seen for each exemplar
    percent_seen_ex  = zeros(1, numel(unique_exemplars));
    percent_seen_corr = zeros(1, numel(unique_exemplars));
    percent_unseen_corr = zeros(1, numel(unique_exemplars));
    for i = 1:numel(unique_exemplars)
        curr_ex = strcmp(exemplar, unique_exemplars{i}) & (real_img | scrambled_img);
        n_exemplars = sum(curr_ex);
        percent_seen_ex(i) = 100 * sum(seen(curr_ex)) / n_exemplars;
        percent_seen_corr(i) = 100 * sum(seen(curr_ex) & correct(curr_ex)) / sum(seen(curr_ex));
        percent_unseen_corr(i) = 100 * sum(unseen(curr_ex) & correct(curr_ex)) / sum(unseen(curr_ex));
    end
    scrambled_seen_perc = percent_seen_ex(6:6:end);
    percent_seen_ex(6:6:end) = [];
    percent_seen_ex(21:24) = scrambled_seen_perc;
    percent_seen_corr(6:6:end) = [];
    percent_unseen_corr(6:6:end) = [];
    a_index = [1:5];
    f_index = [6:10];
    h_index = [11:15];
    o_index = [16:20];
    s_index = [21:24];
    
    subplot(2,3,4); hold on;
    bar(a_index, percent_seen_ex(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_seen_ex(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_seen_ex(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_seen_ex(o_index), 'facecolor', [0.5 0.5 0.5]);
    bar(s_index, percent_seen_ex(s_index), 'facecolor', [0 0 0]);
    set(gca, 'xtick', 1:24, 'xticklabel', exemplar_labels);
    plot([0 25], [50 50], 'r--'); ylabel('% seen'); ylim([1 100]);
    title(sub_title);
    
    subplot(2,3,5); hold on;
    bar(a_index, percent_seen_corr(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_seen_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_seen_corr(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_seen_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
    plot([0 25], [25 25], 'r--'); ylabel('% correct of Seen'); ylim([1 100]);
    sub_title_S = {['Subject: ', subj], [num2str(sum(seen)), ' trials']};
    title(sub_title_S);
    
    subplot(2,3,6); hold on;
    bar(a_index, percent_unseen_corr(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_unseen_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_unseen_corr(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_unseen_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
    plot([0 25], [25 25], 'r--'); ylabel('% correct of UnSeen'); ylim([1 100]);
    sub_title_U = {['Subject: ', subj], [num2str(sum(unseen)), ' trials']};
    title(sub_title_U);
    
    scrpos = [0.2708 0.3021 20.8646 9.4479]; % a good large but arbitrary figure size
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
    print([fdir, 'task_behav'], '-dpng', '-r300'); close all;
    
    
end

end
