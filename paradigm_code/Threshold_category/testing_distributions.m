load paramstest.mat

%% ----------SINGLE EXEMPLAR-----------% %
%% Pre-Stimulus Timings

% check timing distributions for each exemplar
for i = 1:24
    pre_stim(i,:) = params.pre_stim_all(trials.stimID == i);
end

%Create figure with 24 subplots
f = figure
bkclr = get(f, 'Color');
for i = 1:24
    subplot(4,6,i)
    hist(pre_stim(i, :));
    axis([6 26 0 8]);
    set(gca, 'XTick', [6:2:26]);
    set(gca, 'XTickLabel', {'6', '8', '10', '12', '14', '16', '18', '20', '22', '24', '26'});
end
% set title to full figure
bkax = axes;
set(bkax, 'Xcolor', bkclr, 'Ycolor', bkclr, 'box', 'off', 'Color', 'none');
title('Pre-Stimulus Timings');
uistack(bkax, 'bottom');


%% Post-Stimulus Timings
% check timing distributions for each exemplar
for i = 1:24
    post_stim(i,:) = param.post_stim_all(trials.stimID == i);
end

%Create figure with 24 subplots
figure;
for i = 1:24
    subplot(4,6,i)
    hist(post_stim(i, :));
    axis([2 6 0 15]);
    set(gca, 'XTick', [2:2:6]);
    set(gca, 'XTickLabel', {'2', '4', '6'});
end
% set title to full figure
bkax = axes;
set(bkax, 'Xcolor', 'w', 'Ycolor', 'w', 'box', 'off', 'Color', 'none');
title('Post-Stimulus Timings');
uistack(bkax, 'bottom');


%% --------------CATEGORY-------------- %%
%% Pre-Stimulus Timings

timings = [];
for i = 1:6
    timings = [timings param.pre_stim_all(trials.stimID == i)];
end
pre_stim_cat(1, :) = timings;
timings = [];
for i = 7:12
    timings = [timings param.pre_stim_all(trials.stimID == i)];
end
pre_stim_cat(2, :) = timings;
timings = [];
for i = 13:18
    timings = [timings param.pre_stim_all(trials.stimID == i)];
end
pre_stim_cat(3, :) = timings;
timings = [];
for i = 19:24
    timings = [timings param.pre_stim_all(trials.stimID == i)];
end
pre_stim_cat(4, :) = timings;

%Create figure with 4 subplots
f = figure
for i = 1:4
    subplot(2,2,i)
    hist(pre_stim_cat(i, :));
    axis([6 26 0 30]);
    set(gca, 'XTick', [6:2:26]);
    set(gca, 'XTickLabel', {'6', '8', '10', '12', '14', '16', '18', '20', '22', '24', '26'});
end
% set title to full figure
bkax = axes;
set(bkax, 'Xcolor', 'w', 'Ycolor', 'w', 'box', 'off', 'Color', 'none');
title('Pre-Stimulus Timings');
uistack(bkax, 'bottom');


%% Post-Stimulus Timings

timings = [];
for i = 1:6
    timings = [timings param.post_stim_all(trials.stimID == i)];
end
post_stim_cat(1, :) = timings;
timings = [];
for i = 7:12
    timings = [timings param.post_stim_all(trials.stimID == i)];
end
post_stim_cat(2, :) = timings;
timings = [];
for i = 13:18
    timings = [timings param.post_stim_all(trials.stimID == i)];
end
post_stim_cat(3, :) = timings;
timings = [];
for i = 19:24
    timings = [timings param.post_stim_all(trials.stimID == i)];
end
post_stim_cat(4, :) = timings;

%Create figure with 4 subplots
figure
for i = 1:4
    subplot(2,2,i)
    hist(post_stim_cat(i, :));
    axis([2 6 0 100]);
    set(gca, 'XTick', [2:2:6]);
    set(gca, 'XTickLabel', {'2', '4', '6'});
end
% set title to full figure
bkax = axes;
set(bkax, 'Xcolor', 'w', 'Ycolor', 'w', 'box', 'off', 'Color', 'none');
title('Post-Stimulus Timings');
uistack(bkax, 'bottom');