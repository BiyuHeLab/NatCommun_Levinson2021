scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
addpath(genpath(scripts_dir));
fig_dir = [scripts_dir, '/Figures'];


%% remake behavior over time plots
data_file = [fig_dir, '/source_data/bhv_over_time.mat'];
load(data_file);

% statistics: repeated measures anova. one-way of block, averaged across categories
subjects = [1:25]';

percrec = squeeze(nanmean(bhv_over_time.all_percrec, 1));
t = table(subjects, percrec(1, :)', percrec(2, :)', percrec(3, :)', percrec(4, :)', percrec(5, :)', percrec(6, :)', percrec(7, :)', percrec(8, :)', percrec(9, :)', percrec(10, :)', percrec(11, :)', percrec(12, :)', percrec(13, :)', percrec(14, :)', percrec(15, :)', 'VariableNames', {'sub', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8', 'b9', 'b10', 'b11', 'b12', 'b13', 'b14', 'b15'});
blocks = [1:15]';
rm = fitrm(t, 'b1-b15 ~ sub', 'WithinDesign', blocks);
ranovatbl = ranova(rm);

perccorr = squeeze(nanmean(bhv_over_time.all_perccorr, 1));
t = table(subjects, perccorr(1, :)', perccorr(2, :)', perccorr(3, :)', perccorr(4, :)', perccorr(5, :)', perccorr(6, :)', perccorr(7, :)', perccorr(8, :)', perccorr(9, :)', perccorr(10, :)', perccorr(11, :)', perccorr(12, :)', perccorr(13, :)', perccorr(14, :)', perccorr(15, :)', 'VariableNames', {'sub', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8', 'b9', 'b10', 'b11', 'b12', 'b13', 'b14', 'b15'});
blocks = [1:15]';
rm = fitrm(t, 'b1-b15 ~ sub', 'WithinDesign', blocks);
ranovatbl = ranova(rm);



% plot recognition rates - Fig. S1B
errorbounds = zeros(15, 1, 5);
for i = 1:5
    errorbounds(:, 1, i) = bhv_over_time.stderr_percrec(i, 15)';
end
figure; hold on;
boundedline(1:15, bhv_over_time.avg_percrec', errorbounds, '-o', 'cmap', bhv_over_time.colors);
plot([xlim], [50 50], '--', 'Color', [0.5 0.5 0.5]);
xticks(1:15);
xlabel('Task Block');
ylabel('recognition rate (%)');
legend([bhv_over_time.categories, 'scrambled']);
set(gca, 'FontSize', 16);

% plot accuracy - Fig. S1C
errorbounds = zeros(15, 1, 5);
for i = 1:5
    errorbounds(:, 1, i) = bhv_over_time.stderr_perccorr(i, 15)';
end
figure; hold on;
boundedline(1:15, bhv_over_time.avg_perccorr', errorbounds, '-o', 'cmap', bhv_over_time.colors);
xticks(1:15);
xlabel('Task Block');
ylabel('categorization accuracy (%)');
legend({'Rec Animal', 'Rec Face', 'Rec House', 'Rec Object', 'All Scrambled'});
set(gca, 'FontSize', 16);
ylim([0 100]);


%% confusion matrices - Fig. S1D
categories = {'face' 'house' 'object' 'animal'};
load([fig_dir, '/source_data/conf_mats.mat']);
cat_init = cell(1, numel(categories));
for c = 1:numel(categories)
    cat_init{c} = categories{c}(1);
end

h = figure('position', [40 40 600 400]);
a1 = subplot(2, 3, 1);
imagesc(conf_mat_rea, [0 1]); title('real')
set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
origsize1 = getpixelposition(gca);

a2 = subplot(2, 3, 2);
imagesc(conf_mat_R, [0 1]);     title('real rec')
set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
origsize2 = getpixelposition(gca);

a3 = subplot(2, 3, 3);
imagesc(conf_mat_U, [0 1]);    title('real unrec')
set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
origsize3 = getpixelposition(gca);

a4 = subplot(2, 3, 4);
imagesc(conf_mat_scr, [0 1]);    title('scram')
set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
origsize4 = getpixelposition(gca);

a5 = subplot(2, 3, 5);
imagesc(conf_mat_scr_R, [0 1]);     title('scr rec')
set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
origsize5 = getpixelposition(gca);

a6 = subplot(2, 3, 6);
imagesc(conf_mat_scr_U, [0 1]);    title('scr unrec')
set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
origsize6 = getpixelposition(gca);

%set(gcf,'PaperPositionMode','auto');
colormap hot; colorbar;
set(h, 'Position', [40 40 650 400]);
setpixelposition(a1, origsize1); setpixelposition(a2, origsize2); setpixelposition(a3, origsize3); setpixelposition(a4, origsize4); setpixelposition(a5, origsize5); setpixelposition(a6, origsize6);
suplabel('stimulus category', 'y', [.13 .08 .84 .84]);
suplabel('response category', 'x', [.08 .11 .84 .84]);
print([fig_dir, '/conf_mats'], '-dpng', '-r300'); close all;


%% Plot histograms of exemplar recognition per subject - Fig. S1A
subject_exemplar_recognition_rates = load([fig_dir, '/source_data/subject_exemplar_recognition_rates.mat']);

h = cell(25, 1);
n100_by_sub = sum(subject_exemplar_recognition_rates.all(:, 1:20)' == 100)';
n0_by_sub = sum(subject_exemplar_recognition_rates.all(:, 1:20)' == 0)';
figure;
for s = 1:25
    subplot(5,5,s);
    h{s} = histogram(subject_exemplar_recognition_rates.all(s, 1:20), [0 20 40 60 80 100], 'FaceColor', [0.2 0.2 0.2]);
    xlim([0 100]);
    ylim([0 20]);
    xticks([0 50 100]);
    xticklabels({'0', '50', '100'});
    hold on; plot([50 50], ylim, 'k--');
    set(gca, 'FontName', 'Helvetica', 'Color', 'None');
    text(70, 16, ['S', num2str(s)], 'FontSize', 10);
    text(10, 15, ['n_1_0_0 = ', num2str(n100_by_sub(s)), char(10), 'n_0 = ', num2str(n0_by_sub(s))], 'FontSize', 7);
    box off
end
hy = suplabel('number of images', 'y'); hy.FontSize = 12;
hx = suplabel('% recognized', 'x'); hx.FontSize = 12;
set(gcf, 'Position', [4 53 957 683]);

export_fig -painters -r200 -transparent exemplar_rec_histograms.png

% extract mode for each subject (mean rec rate in tallest bin)
modes_rec = nan(1, 25);
for s = 1:25
    [bin_height, bin_idx] = max(h{s}.Values);
    bin_edges = h{s}.BinEdges([bin_idx, bin_idx+1]);
    modes_rec(s) = mean(round(bin_edges));
end
mean(modes_rec) % 46.8
std(modes_rec) % 23.58
std(modes_rec) ./ sqrt(25) % 4.72