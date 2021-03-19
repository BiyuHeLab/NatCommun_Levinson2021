% stimuli images must already be generated using some other method
% (e.g., see TC_makeTrialStim)

files = dir;
names = {files.name};
names(1:2) = [];
%remove scrambled if scrambled images already exist
%scrambled = strfind(names, '6');
%scrambled_index = find(not(cellfun('isempty', scrambled)));
%names(scrambled_index) = [];

figure;
for i = 1:numel(names)
    load(names{i});
    subplot(4,6,i);
    imshow(imdata);
end
suptitle('images');

% scrpos = [0.2708 0.3021 17.8646 7.4479];
% set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
% print(['old_contrasts'], '-dpng', '-r300'); close all;



%BGcolor = 127;


files4 = dir;
names4 = {files4.name};
names4(1:3) = [];
names4(6) = [];

figure;
for i = 1:numel(names4)
    load(names4{i})
    subplot(4,5,i);
    imshow(names4{i});
end
scrpos = [0.2708 0.3021 17.8646 7.4479];
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
print('contrast4', '-dpng', '-r300'); close all;

%contrast 7
files7 = dir;
names7 = {files7.name};
names7(1:3) = [];

figure;
for i = 1:numel(names7)
    load(names7{i})
    subplot(4,5,i);
    imshow(names7{i});
end
scrpos = [0.2708 0.3021 17.8646 7.4479];
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', scrpos)
print(['contrast7'], '-dpng', '-r300'); close all;