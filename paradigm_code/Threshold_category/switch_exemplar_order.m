contrast = param.stimContrast
newcontrast = [];
newcontrast(1:5) = contrast(16:20);
newcontrast(6:10) = contrast(1:5);
newcontrast(11:15) = contrast(6:10);
newcontrast(16:20) = contrast(11:15);

figure;hold on;
bar(1:numel(newcontrast), newcontrast);
set(gca, 'xtick', 1:20, 'xticklabel', exemplar_labels(1:20));
ylabel('contrast'); ylim([0 1]);