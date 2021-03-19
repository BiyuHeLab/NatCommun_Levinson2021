function [percrec, perccorr] = HLTP_recRate_accuracy_by_block(raw_dir, proc_dir, subj)
% plot recognition rates over time

categories = {'animal', 'face', 'house', 'object'};
exemplar_labels = {'a1', 'a2', 'a3', 'a4', 'a5', 'f1', 'f2', 'f3', 'f4', ...
        'f5', 'h1', 'h2', 'h3', 'h4', 'h5', 'o1', 'o2', 'o3', 'o4', 'o5', ...
        's1', 's2', 's3', 's4'};

real = [];
load([proc_dir, 'bhv_data.mat']);
categories = unique(categories);
unique_exemplars = unique(exemplar(1:n_trials));
n_blocks = n_trials / 24;

rec = rec & ~no_response_vis & ~no_response_cat;
unrec = unrec & ~no_response_vis & ~no_response_cat;
corr = correct & ~no_response_vis & ~no_response_cat;
real_full = real & ~no_response_vis & ~no_response_cat;
scrambled_full = scrambled & ~no_response_vis & ~no_response_cat;
%%%%
used = sum(rec + unrec); %number of trials included in below analysis

raw = load([raw_dir, 'datafile.mat']);
clear correct real scrambled;
trial_iter = 1;
for i = 1:n_blocks
    blk_index = trial_iter:trial_iter+23;
    recog.(['block' num2str(i)]) = rec(blk_index);
    unrecog.(['block' num2str(i)]) = unrec(blk_index);
    correct.(['block' num2str(i)]) = corr(blk_index);
    real.(['block' num2str(i)]) = real_full(blk_index);
    scrambled.(['block' num2str(i)]) = scrambled_full(blk_index);
    used_trials.(['block' num2str(i)]) = recog.(['block' num2str(i)]) + unrecog.(['block' num2str(i)]);

    percent_rec_scrambled.(['block' num2str(i)]) = 100 * sum(scrambled.(['block' num2str(i)]) & recog.(['block' num2str(i)]))...
        /sum(scrambled.(['block' num2str(i)]));
    percent_rec_real.(['block' num2str(i)]) = 100 * sum(real.(['block' num2str(i)]) & recog.(['block' num2str(i)])) ...
        /sum(real.(['block' num2str(i)]));
    
    % percent correct for each category
    % + 1 to include scrambled
    percent_rec.(['block' num2str(i)]) = zeros(1, numel(categories));
    percent_correct_R.(['block' num2str(i)]) = zeros(1, numel(categories) + 1);
    percent_correct_U.(['block' num2str(i)]) = zeros(1, numel(categories) + 1);
    corr_R.(['block' num2str(i)]) = (correct.(['block' num2str(i)]) & recog.(['block' num2str(i)]) & real.(['block' num2str(i)]));
    corr_U.(['block' num2str(i)]) = (correct.(['block' num2str(i)]) & unrecog.(['block' num2str(i)]) & real.(['block' num2str(i)]));
    corr_scrambled_R.(['block' num2str(i)]) = (correct.(['block' num2str(i)]) & recog.(['block' num2str(i)]) & scrambled.(['block' num2str(i)]));
    corr_scrambled_U.(['block' num2str(i)]) = (correct.(['block' num2str(i)]) & unrecog.(['block' num2str(i)]) & scrambled.(['block' num2str(i)]));
    
    for c = 1:numel(categories)
        cat_img = ~cellfun(@isempty, strfind(exemplar(blk_index), categories{c})) & real.(['block' num2str(i)]);
        cat_labels{c} = [categories{c}, '\newline', num2str(sum(cat_img))];
        percent_rec.(['block' num2str(i)])(c) = 100*sum(recog.(['block' num2str(i)])(cat_img))/sum(cat_img);
        percent_correct_R.(['block' num2str(i)])(c) = 100*sum(corr_R.(['block' num2str(i)])(cat_img)) / sum(recog.(['block' num2str(i)])(cat_img) & real.(['block' num2str(i)])(cat_img));
        percent_correct_U.(['block' num2str(i)])(c) = 100*sum(corr_U.(['block' num2str(i)])(cat_img)) / sum(unrecog.(['block' num2str(i)])(cat_img) & real.(['block' num2str(i)])(cat_img));
    end
    cat_labels{5} = ['scr', '\newline', num2str(sum(scrambled.(['block' num2str(i)])))];
    percent_correct_scrambled.(['block' num2str(i)]) = 100 * sum(scrambled.(['block' num2str(i)]) & correct.(['block' num2str(i)]))...
        /sum(scrambled.(['block' num2str(i)]));
    percent_correct_R.(['block' num2str(i)])(5) = 100*sum(corr_scrambled_R.(['block' num2str(i)])(scrambled.(['block' num2str(i)]))) / sum(recog.(['block' num2str(i)])(scrambled.(['block' num2str(i)])));
    percent_correct_U.(['block' num2str(i)])(5) = 100*sum(corr_scrambled_U.(['block' num2str(i)])(scrambled.(['block' num2str(i)]))) / sum(unrecog.(['block' num2str(i)])(scrambled.(['block' num2str(i)])));
    
    trial_iter = trial_iter + 24;
end


x = [1:n_blocks];
y_percrec = [];
y_percrecA = [];
y_percrecF = [];
y_percrecH = [];
y_percrecO = [];
y_percrecS = [];
y_perccorrR = [];
y_perccorrA = [];
y_perccorrF = [];
y_perccorrH = [];
y_perccorrO = [];
y_perccorrS = [];
flds = fields(recog);
for f = 1:numel(flds)
    y_percrec = [y_percrec percent_rec_real.(flds{f})];
    y_percrecA = [y_percrecA percent_rec.(flds{f})(1)];
    y_percrecF = [y_percrecF percent_rec.(flds{f})(2)];
    y_percrecH = [y_percrecH percent_rec.(flds{f})(3)];
    y_percrecO = [y_percrecO percent_rec.(flds{f})(4)];
    y_percrecS = [y_percrecS percent_rec_scrambled.(flds{f})];
end
flds = fields(correct);
for f = 1:numel(flds)
    %y_perccorrR = [y_perccorr percent_correct_R.(flds{f})];
    y_perccorrA = [y_perccorrA percent_correct_R.(flds{f})(1)];
    y_perccorrF = [y_perccorrF percent_correct_R.(flds{f})(2)];
    y_perccorrH = [y_perccorrH percent_correct_R.(flds{f})(3)];
    y_perccorrO = [y_perccorrO percent_correct_R.(flds{f})(4)];
    y_perccorrS = [y_perccorrS percent_correct_scrambled.(flds{f})];
end


% plot all real images perc rec across intervals
figure; hold on;
plot(x, y_percrecA, '-o', x, y_percrecF, '-o', x, y_percrecH, '-o', x, y_percrecO, '-o');
plot(x, y_percrec, '-ok', 'LineWidth', 3)
ylim([0 100]);
legend(categories, 'average')
xlabel('task block');
ylabel('percent recognized');
title(['sub ' subj ' recognition rate across blocks']);
set(gca, 'xtick', x);
print([proc_dir, 'block_recognition'], '-dpng', '-r300'); close all;

% plot real images perc rec v. scrambled across intervals
figure; hold on;
plot(x, y_percrec, '-o', x, y_percrecS, '-o');
ylim([0 100]);
legend('real', 'scrambled');
xlabel('task block');
ylabel('percent recognized');
title(['sub ' subj ' recognition rate across blocks']);
set(gca, 'xtick', x);
print([proc_dir, 'block_recognition_realscr'], '-dpng', '-r300'); close all;

% output variables
percrec = [y_percrecA; y_percrecF; y_percrecH; y_percrecO; y_percrecS];
perccorr = [y_perccorrA; y_perccorrF; y_perccorrH; y_perccorrO; y_perccorrS];
