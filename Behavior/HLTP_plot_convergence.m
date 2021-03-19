function HLTP_plot_convergence(raw_dir, proc_dir, parse_main, parse_quest)

exemplar_labels = {'f1', 'f2', 'f3', 'f4', 'f5', 'h1', 'h2', 'h3', 'h4', ...
    'h5', 'o1', 'o2', 'o3', 'o4', 'o5', 'a1', 'a2', 'a3', 'a4', 'a5'}; %for axis labels in plots

load([raw_dir, 'datafile.mat']);
categories = param.categories;

if strcmp(parse_main, 'yes') && isfield(dataQ, 'mini')
    figure; hold on;
    title(['mini QUEST convergence from 1 to ' num2str(param.stimContrast(1) ./ dataQ.orig_stimContrast(1))])
    for i = 1:2
        plot(find(dataQ.mini.qID == i), dataQ.mini.Wg(dataQ.mini.qID == i), '.--');
    end
    %plot(find(dataQ.mini.qID == 1), dataQ.mini.Wg(dataQ.mini.qID == 1), '.--');
    xlabel('trial number');ylabel('contrast');
    print([proc_dir, 'miniquest_convergence'], '-dpng', '-r300'); close all;
end

if strcmp(parse_quest, 'yes')
    figure; hold on;
    title('QUEST convergence per exemplar')
    for i = 1:5
        h1 = plot(find(dataQ.qID == i), dataQ.Wg(dataQ.qID == i), '.--r');
    end
    for i = 6:10
        h2 = plot(find(dataQ.qID == i), dataQ.Wg(dataQ.qID == i), '.--b');
    end
    for i = 11:15
        h3 = plot(find(dataQ.qID == i), dataQ.Wg(dataQ.qID == i), '.--g');
    end
    for i = 16:20
        h4 = plot(find(dataQ.qID == i), dataQ.Wg(dataQ.qID == i), '.--k');
    end
    xlabel('trial number');ylabel('contrast');
    legend([h1 h2 h3 h4], categories);
    print([proc_dir, 'quest_convergence'], '-dpng', '-r300'); close all;
end