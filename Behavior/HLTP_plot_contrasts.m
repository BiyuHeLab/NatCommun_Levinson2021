function HLTP_plot_contrasts(raw_dir, proc_dir, subj, parse_main)
load([raw_dir, 'datafile.mat']);
exemplar_labels = {'a1', 'a2', 'a3', 'a4', 'a5', 'f1', 'f2', 'f3', 'f4', ...
    'f5', 'h1', 'h2', 'h3', 'h4', 'h5', 'o1', 'o2', 'o3', 'o4', 'o5', ...
    's1', 's2', 's3', 's4'};
categories = {'animal', 'face', 'house', 'object'};

% convert exemplar order to alphabetical
exemplar_contrasts = [];
if strcmp(parse_main, 'yes')
    exemplar_contrasts(1:5) = param.stimContrast(19:23);
    exemplar_contrasts(6:10) = param.stimContrast(1:5);
    exemplar_contrasts(11:15) = param.stimContrast(7:11);
    exemplar_contrasts(16:20) = param.stimContrast(13:17);
else
    exemplar_contrasts(1:5) = param.stimContrast(16:20);
    exemplar_contrasts(6:10) = param.stimContrast(1:5);
    exemplar_contrasts(11:15) = param.stimContrast(6:10);
    exemplar_contrasts(16:20) = param.stimContrast(11:15);
end

% plot contrasts
figure; hold on;
plot(1:numel(exemplar_contrasts), exemplar_contrasts, '-or');
ylabel('contrast'); ylim([0 1.0]);
set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
if strcmp(parse_main, 'yes')
    title(['Subject: ', subj, ', exemplar contrasts']);
else
    title(['Subject: ', subj, ', QUEST exemplar contrasts']);
end
print([proc_dir, 'contrasts_', subj], '-dpng', '-r300'); close all;