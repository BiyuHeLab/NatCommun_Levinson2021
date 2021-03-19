function HLTP_process_behavior
clear;
scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
data_dir =''; % PATH TO MAIN DATA DIRECTORY
addpath(genpath(scripts_dir));

% data input
subj = input('Enter subject number:   ', 's');
parse_main = input('Parse day 2 data? yes or no:   ', 's');
parse_quest = input('Parse day 1 data? yes or no:   ', 's');
subj_dir = [data_dir '/sub', subj, '/'];
PTBoutdir = dir([subj_dir, 'raw_data/*data']);
raw_dir = [subj_dir, 'raw_data/', PTBoutdir.name, '/'];
tmp_proc_dir = [subj_dir 'proc_data/'];
proc_dir = [tmp_proc_dir, 'behavior/'];
mkdir(proc_dir);
real = []; % initialize 'real' variable to avoid error

HLTP_parse_datafile(raw_dir, proc_dir, parse_main, parse_quest);
HLTP_conf_mat(proc_dir, parse_main, parse_quest);
HLTP_plot_convergence(raw_dir, proc_dir, parse_main, parse_quest);
HLTP_plot_contrasts(raw_dir, proc_dir, subj, parse_main);

%categories = {'animal', 'face', 'house', 'object'};
exemplar_labels = {'a1', 'a2', 'a3', 'a4', 'a5', 'f1', 'f2', 'f3', 'f4', ...
        'f5', 'h1', 'h2', 'h3', 'h4', 'h5', 'o1', 'o2', 'o3', 'o4', 'o5', ...
        's1', 's2', 's3', 's4'}; %for axis labels in plots
    
% analyze main task
if strcmpi(parse_main, 'yes')
    HLTP_make_evs(raw_dir, tmp_proc_dir);
    HLTP_recRate_by_block(raw_dir, proc_dir, subj);
    HLTP_missing_conditions(proc_dir);
    load([proc_dir, 'bhv_data.mat']);
    categories = unique(categories);
    unique_exemplars = unique(exemplar(1:n_trials));
    
    %%%% take out trials with no response %%%%
    rec = rec & ~no_response_vis & ~no_response_cat;
    unrec = unrec & ~no_response_vis & ~no_response_cat;
    correct = correct & ~no_response_vis & ~no_response_cat;
    real = real & ~no_response_vis & ~no_response_cat;
    scrambled = scrambled & ~no_response_vis & ~no_response_cat;
    %%%%
    used_trials = sum(rec + unrec); %number of trials included in below analysis
    
    % percent rec and percent correct for each category
    percent_rec_scrambled = 100 * sum(scrambled & rec)...
        /sum(scrambled);
    percent_rec_real = 100 * sum(real & rec) ...
        /sum(real);
    percent_rec = zeros(1, numel(categories));
    percent_correct_R = zeros(1, numel(categories) + 1); % +1 is to include scrambled
    percent_correct_U = zeros(1, numel(categories) + 1);
    corr_R = (correct & rec & real);
    corr_U = (correct & unrec & real);
    corr_scrambled_R = (correct & rec & scrambled);
    corr_scrambled_U = (correct & unrec & scrambled);
    
    for i = 1:numel(categories)
        cat_img = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i})) & real;
        cat_labels{i} = [categories{i}, '\newline', num2str(sum(cat_img))];
        percent_rec(i) = 100*sum(rec(cat_img))/sum(cat_img);
        percent_correct_R(i) = 100*sum(corr_R(cat_img)) / sum(rec(cat_img) & real(cat_img));
        if percent_rec(i) == 0; percent_correct_R(i) = 0; end
        percent_correct_U(i) = 100*sum(corr_U(cat_img)) / sum(unrec(cat_img) & real(cat_img));
    end
    cat_labels{5} = ['scr', '\newline', num2str(sum(scrambled))];
    percent_correct_scrambled = 100 * sum(scrambled & correct)...
        /sum(scrambled);
    percent_correct_R(5) = 100*sum(corr_scrambled_R(scrambled)) / sum(rec(scrambled));
    percent_correct_U(5) = 100*sum(corr_scrambled_U(scrambled)) / sum(unrec(scrambled));
    sub_title = {['Subject: ', subj], [num2str(used_trials), ' trials']};%sub_title = ['Subject: 01, prestim blank ' num2str(use_blank) 's, ' num2str(used_trials), ' trials'];
    
    % percent rec for each exemplar
    percent_rec_ex  = zeros(1, numel(unique_exemplars));
    percent_rec_corr = zeros(1, numel(unique_exemplars));
    percent_unrec_corr = zeros(1, numel(unique_exemplars));
    for i = 1:numel(unique_exemplars)
        curr_ex = strcmp(exemplar, unique_exemplars{i}) & (real | scrambled);
        n_exemplars = sum(curr_ex);
        percent_rec_ex(i) = 100 * sum(rec(curr_ex)) / n_exemplars;
        percent_rec_corr(i) = 100 * sum(rec(curr_ex) & correct(curr_ex)) / sum(rec(curr_ex));
        percent_unrec_corr(i) = 100 * sum(unrec(curr_ex) & correct(curr_ex)) / sum(unrec(curr_ex));
    end
    scrambled_rec_perc = percent_rec_ex(6:6:end);
    percent_rec_ex(6:6:end) = [];
    percent_rec_ex(21:24) = scrambled_rec_perc;
    percent_rec_corr(6:6:end) = [];
    percent_unrec_corr(6:6:end) = [];    
    
    %%% CREATE PLOTS %%%
    figure;
    subplot(2,3,1); hold on;
    bar(1, percent_rec(1), 'facecolor', [0 0 0]);
    bar(2, percent_rec(2), 'facecolor', [0.5 0.5 0.5]);
    bar(3, percent_rec(3), 'facecolor', [0 0 0]);
    bar(4, percent_rec(4), 'facecolor', [0.5 0.5 0.5]);
    bar(5, percent_rec_scrambled, 'facecolor', [0 0 0]);
    set(gca, 'xtick', 1:5, 'xticklabel', cat_labels);
    plot([0 6], [50 50], 'r--'); ylabel('% rec'); ylim([1 100]);
    variability = std(percent_rec);
    sub_title_catrec = {['Subject: ', subj], [num2str(used_trials), ' trials, stddev ' num2str(variability)]};
    title(sub_title_catrec);
    
    subplot(2,3,2); hold on;
    bar(1:5, [percent_correct_R' percent_correct_U']);
    set(gca, 'xtick', 1:5, 'xticklabel', cat_labels);
    plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
    legend('rec', 'unrec');
    title(sub_title);
    
    subplot(2,3,3); hold on;
    bar(1:4, [100*sum(corr_R)/sum(rec & real) 100*sum(corr_U)/sum(unrec & real) 100*sum(corr_scrambled_R)/sum(rec & scrambled) 100*sum(corr_scrambled_U)/sum(unrec & scrambled)]);
    %bar(1:3, [sum(percent_correct_R(1:numel(categories))/numel(categories)), sum(percent_correct_U(1:numel(categories))/numel(categories)), percent_correct_scrambled]);
    set(gca, 'xtick', 1:4, 'xticklabel', {'R', 'U', 'scr R', 'scr U'});
    plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
    title(sub_title);
    
    a_index = [1:5];%find(contains(unique_exemplars, 'animal') & ~contains(unique_exemplars, '6'));
    f_index = [6:10];%find(contains(unique_exemplars, 'face') & ~contains(unique_exemplars, '6'));
    h_index = [11:15];%find(contains(unique_exemplars, 'house') & ~contains(unique_exemplars, '6'));
    o_index = [16:20];%find(contains(unique_exemplars, 'object') & ~contains(unique_exemplars, '6'));
    s_index = [21:24];
    subplot(2,3,4); hold on;
    bar(a_index, percent_rec_ex(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_rec_ex(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_rec_ex(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_rec_ex(o_index), 'facecolor', [0.5 0.5 0.5]);
    bar(s_index, percent_rec_ex(s_index), 'facecolor', [0 0 0]);
    set(gca, 'xtick', 1:24, 'xticklabel', exemplar_labels);
    plot([0 25], [50 50], 'r--'); ylabel('% rec'); ylim([1 100]);
    variability = std(percent_rec_ex(1:20));
    sub_title_exemplar = {['Subject: ', subj], [num2str(used_trials), ' trials, stddev ' num2str(variability)]};
    title(sub_title_exemplar);
    
    subplot(2,3,5); hold on;
    bar(a_index, percent_rec_corr(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_rec_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_rec_corr(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_rec_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
    plot([0 25], [25 25], 'r--'); ylabel('% correct of rec'); ylim([1 100]);
    sub_title_R = {['Subject: ', subj], [num2str(sum(rec)), ' trials']};
    title(sub_title_R);
    
    subplot(2,3,6); hold on;
    bar(a_index, percent_unrec_corr(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_unrec_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_unrec_corr(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_unrec_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
    plot([0 25], [25 25], 'r--'); ylabel('% correct of Unrec'); ylim([1 100]);
    sub_title_U = {['Subject: ', subj], [num2str(sum(unrec)), ' trials']};
    title(sub_title_U);
    %
    % set(gcf, 'Units', 'inches');
    % scrpos = get(gcf, 'Position');
    scrpos = [0.2708 0.3021 20.8646 9.4479]; % a good large but arbitrary figure size
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
    print([proc_dir, 'behav_analysis'], '-dpng', '-r300'); close all;
    
    % MINI QUEST
    if exist([proc_dir, 'bhv_dataQmini.mat'], 'file');
        load([proc_dir, 'bhv_dataQmini.mat']);
        categories = unique(categories);
        unique_exemplars = unique(exemplar(1:n_trials));
        
        %%%% take out trials with no response %%%%
        rec = rec & ~no_response_vis & ~no_response_cat;
        unrec = unrec & ~no_response_vis & ~no_response_cat;
        correct = correct & ~no_response_vis & ~no_response_cat;
        %%%%
        used_trials = rec | unrec;
        num_used_trials = sum(used_trials); %number of trials included in below analysis
        
        % percent correct and percent rec for each category
        percent_rec = zeros(1, numel(categories));
        percent_correct_R = zeros(1, numel(categories));
        percent_correct_U = zeros(1, numel(categories));
        corr_R = (correct & rec);
        corr_U = (correct & unrec);
        for i = 1:numel(categories)
            cat_img = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i})) & used_trials;
            cat_labels{i} = [categories{i}, '\newline', num2str(sum(cat_img))];
            percent_rec(i) = 100*sum(rec(cat_img))/sum(cat_img);
            percent_correct_R(i) = 100*sum(corr_R(cat_img)) / sum(rec(cat_img));
            percent_correct_U(i) = 100*sum(corr_U(cat_img)) / sum(unrec(cat_img));
        end
        
        % percent rec for each exemplar
        percent_rec_ex  = zeros(1, numel(unique_exemplars));
        percent_rec_corr = zeros(1, numel(unique_exemplars));
        percent_unrec_corr = zeros(1, numel(unique_exemplars));
        for i = 1:numel(unique_exemplars)
            curr_ex = strcmp(exemplar, unique_exemplars{i}) & used_trials;
            n_exemplars = sum(curr_ex);
            percent_rec_ex(i) = 100 * sum(rec(curr_ex)) / n_exemplars;
            percent_rec_corr(i) = 100 * sum(rec(curr_ex) & correct(curr_ex)) / sum(rec(curr_ex));
            percent_unrec_corr(i) = 100 * sum(unrec(curr_ex) & correct(curr_ex)) / sum(unrec(curr_ex));
        end
        percent_rec_ex(isnan(percent_rec_ex))=0;
        percent_rec_corr(isnan(percent_rec_corr))=0;
        percent_unrec_corr(isnan(percent_unrec_corr))=0;
        
        sub_title = {['Subject: ', subj], [num2str(num_used_trials), ' trials']};
        
        %%% CREATE PLOTS %%%
        figure;
        subplot(2,3,1); hold on;
        bar(1, percent_rec(1), 'facecolor', [0 0 0]);
        bar(2, percent_rec(2), 'facecolor', [0.5 0.5 0.5]);
        bar(3, percent_rec(3), 'facecolor', [0 0 0]);
        bar(4, percent_rec(4), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
        plot([0 5], [50 50], 'r--'); ylabel('% rec'); ylim([1 100]);
        variability = std(percent_rec);
        sub_title_catrec = {['Subject: ', subj], [num2str(num_used_trials), ' trials, stddev ' num2str(variability)]};
        title(sub_title_catrec);
        
        subplot(2,3,2); hold on;
        bar(1:4, [percent_correct_R' percent_correct_U']);
        set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
        plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
        legend('rec', 'unrec');
        title(sub_title);
        
        subplot(2,3,3); hold on;
        bar(1:2, [100*sum(corr_R)/sum(rec) 100*sum(corr_U)/sum(unrec)]);
        set(gca, 'xtick', 1:2, 'xticklabel', {'R', 'U'});
        plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
        title(sub_title);
        
        
        a_index = find(contains(unique_exemplars, 'animal'));
        f_index = find(contains(unique_exemplars, 'face'));
        h_index = find(contains(unique_exemplars, 'house'));
        o_index = find(contains(unique_exemplars, 'object'));
        
        new_exemplar_labels = {};
        for i = 1:numel(unique_exemplars)
            new_exemplar_labels{i} = [unique_exemplars{i}(1) unique_exemplars{i}(end)];
        end
        
        subplot(2,3,4); hold on;
        bar(a_index, percent_rec_ex(a_index), 'facecolor', [0 0 0]);
        bar(f_index, percent_rec_ex(f_index), 'facecolor', [0.5 0.5 0.5]);
        bar(h_index, percent_rec_ex(h_index), 'facecolor', [0 0 0]);
        bar(o_index, percent_rec_ex(o_index), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:numel(unique_exemplars), 'xticklabel', new_exemplar_labels);
        plot([0 25], [50 50], 'r--'); ylabel('% rec'); ylim([1 100]);
        percent_rec_ex(isnan(percent_rec_ex))=0;
        variability = std(percent_rec_ex);
        sub_title_exemplar = {['Subject: ', subj], [num2str(num_used_trials), ' trials, stddev ' num2str(variability)]};
        title(sub_title_exemplar);
        
        subplot(2,3,5); hold on;
        bar(a_index, percent_rec_corr(a_index), 'facecolor', [0 0 0]);
        bar(f_index, percent_rec_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
        bar(h_index, percent_rec_corr(h_index), 'facecolor', [0 0 0]);
        bar(o_index, percent_rec_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:numel(unique_exemplars), 'xticklabel', new_exemplar_labels);
        plot([0 25], [25 25], 'r--'); ylabel('% correct of rec'); ylim([1 100]);
        sub_title_R = {['Subject: ', subj], [num2str(sum(rec)), ' trials']};
        title(sub_title_R);
        
        subplot(2,3,6); hold on;
        bar(a_index, percent_unrec_corr(a_index), 'facecolor', [0 0 0]);
        bar(f_index, percent_unrec_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
        bar(h_index, percent_unrec_corr(h_index), 'facecolor', [0 0 0]);
        bar(o_index, percent_unrec_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
        set(gca, 'xtick', 1:numel(unique_exemplars), 'xticklabel', new_exemplar_labels);
        plot([0 25], [25 25], 'r--'); ylabel('% correct of Unrec'); ylim([1 100]);
        sub_title_U = {['Subject: ', subj], [num2str(sum(unrec)), ' trials']};
        title(sub_title_U);
        %
        % set(gcf, 'Units', 'inches');
        % scrpos = get(gcf, 'Position');
        scrpos = [0.2708 0.3021 20.8646 9.4479];
        set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
        print([proc_dir, 'behav_analysisQmini'], '-dpng', '-r300'); close all;
    end
end

%% quest


% data input
if strcmpi(parse_quest, 'yes')
    loc_make_evs(raw_dir, tmp_proc_dir);
    load([proc_dir, 'bhv_dataQ.mat']);
    categories = unique(categories);
    unique_exemplars = unique(exemplar(1:n_trials));
    
    %%%% take out trials with no response %%%%
    rec = rec & ~no_response_vis & ~no_response_cat;
    unrec = unrec & ~no_response_vis & ~no_response_cat;
    correct = correct & ~no_response_vis & ~no_response_cat;
    %%%%
    used_trials = rec | unrec;
    num_used_trials = sum(used_trials); %number of trials included in below analysis
    
    % percent correct and percent rec for each category
    
    percent_rec = zeros(1, numel(categories));
    percent_correct_R = zeros(1, numel(categories));
    percent_correct_U = zeros(1, numel(categories));
    corr_R = (correct & rec);
    corr_U = (correct & unrec);
    for i = 1:numel(categories)
        cat_img = ~cellfun(@isempty, strfind(exemplar(1:n_trials), categories{i})) & used_trials;
        cat_labels{i} = [categories{i}, '\newline', num2str(sum(cat_img))];
        percent_rec(i) = 100*sum(rec(cat_img))/sum(cat_img);
        percent_correct_R(i) = 100*sum(corr_R(cat_img)) / sum(rec(cat_img));
        percent_correct_U(i) = 100*sum(corr_U(cat_img)) / sum(unrec(cat_img));
    end
    
    % percent rec for each exemplar
    percent_rec_ex  = zeros(1, numel(unique_exemplars));
    percent_rec_corr = zeros(1, numel(unique_exemplars));
    percent_unrec_corr = zeros(1, numel(unique_exemplars));
    for i = 1:numel(unique_exemplars)
        curr_ex = strcmp(exemplar, unique_exemplars{i}) & used_trials;
        n_exemplars = sum(curr_ex);
        percent_rec_ex(i) = 100 * sum(rec(curr_ex)) / n_exemplars;
        percent_rec_corr(i) = 100 * sum(rec(curr_ex) & correct(curr_ex)) / sum(rec(curr_ex));
        percent_unrec_corr(i) = 100 * sum(unrec(curr_ex) & correct(curr_ex)) / sum(unrec(curr_ex));
    end
    
    sub_title = {['Subject: ', subj], [num2str(num_used_trials), ' trials']};
    
    figure;
    subplot(2,3,1); hold on;
    bar(1, percent_rec(1), 'facecolor', [0 0 0]);
    bar(2, percent_rec(2), 'facecolor', [0.5 0.5 0.5]);
    bar(3, percent_rec(3), 'facecolor', [0 0 0]);
    bar(4, percent_rec(4), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
    plot([0 5], [50 50], 'r--'); ylabel('% rec'); ylim([1 100]);
    variability = std(percent_rec);
    sub_title_catrec = {['Subject: ', subj], [num2str(num_used_trials), ' trials, stddev ' num2str(variability)]};
    title(sub_title_catrec);
    
    subplot(2,3,2); hold on;
    bar(1:4, [percent_correct_R' percent_correct_U']);
    set(gca, 'xtick', 1:4, 'xticklabel', cat_labels);
    plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
    legend('rec', 'unrec');
    title(sub_title);
    
    subplot(2,3,3); hold on;
    bar(1:2, [100*sum(corr_R)/sum(rec) 100*sum(corr_U)/sum(unrec)]);
    set(gca, 'xtick', 1:2, 'xticklabel', {'R', 'U'});
    plot([0 5], [25 25], 'r--'); ylabel('% correct'); ylim([1 100]);
    title(sub_title);
    
    a_index = find(contains(unique_exemplars, 'animal'));
    f_index = find(contains(unique_exemplars, 'face'));
    h_index = find(contains(unique_exemplars, 'house'));
    o_index = find(contains(unique_exemplars, 'object'));
    
    subplot(2,3,4); hold on;
    bar(a_index, percent_rec_ex(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_rec_ex(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_rec_ex(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_rec_ex(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels);
    plot([0 25], [50 50], 'r--'); ylabel('% rec'); ylim([1 100]);
    variability = std(percent_rec_ex);
    sub_title_exemplar = {['Subject: ', subj], [num2str(num_used_trials), ' trials, stddev ' num2str(variability)]};
    title(sub_title_exemplar);
    
    subplot(2,3,5); hold on;
    bar(a_index, percent_rec_corr(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_rec_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_rec_corr(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_rec_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
    plot([0 25], [25 25], 'r--'); ylabel('% correct of rec'); ylim([1 100]);
    sub_title_R = {['Subject: ', subj], [num2str(sum(rec)), ' trials']};
    title(sub_title_R);
    
    subplot(2,3,6); hold on;
    bar(a_index, percent_unrec_corr(a_index), 'facecolor', [0 0 0]);
    bar(f_index, percent_unrec_corr(f_index), 'facecolor', [0.5 0.5 0.5]);
    bar(h_index, percent_unrec_corr(h_index), 'facecolor', [0 0 0]);
    bar(o_index, percent_unrec_corr(o_index), 'facecolor', [0.5 0.5 0.5]);
    set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
    plot([0 25], [25 25], 'r--'); ylabel('% correct of Unrec'); ylim([1 100]);
    sub_title_U = {['Subject: ', subj], [num2str(sum(unrec)), ' trials']};
    title(sub_title_U);
    %
    % set(gcf, 'Units', 'inches');
    % scrpos = get(gcf, 'Position');
    scrpos = [0.2708 0.3021 20.8646 9.4479];
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
    print([proc_dir, 'behav_analysisQ'], '-dpng', '-r300'); close all;
end