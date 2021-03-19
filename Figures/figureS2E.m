%% scatter of decoding accuracy v roi size

scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
fig_dir = [scripts_dir, '/Figures'];
data_file = [fig_dir, '/source_data/Source Data.xls'];

% load data
T = readtable(data_file, 'Sheet', 'S2E', 'Range', 'A2:E601');
T.Properties.VariableNames = {'Subject', 'ROI', 'Cortical', 'Voxel_count', 'Recognized_decoding_accuracy'};

colors = repmat([1 0 0], 600, 1); % red for cortex
colors(~T.Cortical, :) = repmat([0 0 1], 74, 1); % blue for subcortex (not hippocampus)

figure; hold on;
scatter(T.Voxel_count(T.Cortical), T.Recognized_decoding_accuracy(T.Cortical), 60, colors(T.Cortical, :), 'filled');
scatter(T.Voxel_count(~T.Cortical), T.Recognized_decoding_accuracy(~T.Cortical), 60, colors(~T.Cortical, :), 'filled');
set(gca, 'FontSize', 16);
xlabel('number of voxels');
ylabel('decoding accuracy (%)');
plot(xlim, [25 25], 'k--');
[~, l] = legend({'cortical', 'subcortical'}, 'FontSize', 16);
ll = findobj(l, 'type', 'patch');
set(ll, 'MarkerSize', 8);
box off
legend boxoff