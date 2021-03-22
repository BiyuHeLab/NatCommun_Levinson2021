%% scatter of decoding accuracy v roi size

scripts_dir = ''; % PATH TO SCRIPTS DIRECTORY
fig_dir = [scripts_dir, '/Figures'];
data_file = [fig_dir, '/source_data/Source Data.xls'];

% load data
T = readtable(data_file, 'Sheet', 'S2E', 'Range', 'A1:E601');

% compute means & SEMs
voxelCount = reshape(T.VoxelCount, 24, 25); % ROIs by subject
% voxel counts are almost identical across subjects (just anatomical MRI
% differences), so use the average as the x-axis
voxelCount_mean = mean(voxelCount, 2);
cortical = T.Cortical(1:24);
decodingAccuracy = reshape(T.categoryDecodingAccuracy_RecognizedRealObjects, 24, 25);
decodingAccuracy_mean = mean(decodingAccuracy, 2);
decodingAccuracy_std = std(decodingAccuracy, 0, 2);
decodingAccuracy_se = decodingAccuracy_std / sqrt(25);

cortical = T.Cortical(1:24);
sig = [0; 1; 1; 1; 0; 1; 0; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0; 1; 1; 1; 0; 0]; % which ROIs showed significant category decoding (Figure 4B)

colors = repmat([1 0 0], 24, 1); % red for cortex
colors(~cortical, :) = repmat([0 0 1], 3, 1); % blue for subcortex (not hippocampus)

figure; hold on;
errorbar(voxelCount_mean(cortical), decodingAccuracy_mean(cortical), decodingAccuracy_se(cortical), 'LineStyle', 'none', 'CapSize', 0, 'Color', colors(3, :));
errorbar(voxelCount_mean(~cortical), decodingAccuracy_mean(~cortical), decodingAccuracy_se(~cortical), 'LineStyle', 'none', 'CapSize', 0, 'Color', colors(1, :));
s1 = scatter(voxelCount_mean(cortical & sig), decodingAccuracy_mean(cortical & sig), 60, colors(cortical & sig, :), 'filled', 'MarkerFaceAlpha', .5);
s2 = scatter(voxelCount_mean(cortical), decodingAccuracy_mean(cortical), 60, colors(cortical, :));
s3 = scatter(voxelCount_mean(~cortical), decodingAccuracy_mean(~cortical), 60, colors(~cortical, :));
set(gca, 'FontSize', 16);
xlabel('number of voxels');
ylabel('decoding accuracy (%)');
plot(xlim, [25 25], 'k--');
[~, l] = legend([s1 s2 s3], {'cortical (significant)', 'cortical (non-significant)', 'subcortical'}, 'FontSize', 16);
ll = findobj(l, 'type', 'patch');
set(ll, 'MarkerSize', 8);
box off
legend boxoff
