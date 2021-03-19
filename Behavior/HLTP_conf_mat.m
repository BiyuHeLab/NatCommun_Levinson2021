%HLTP_conf_mat Prepare stimulus-response confusion matrices
% adapted from HLTP MEG by EP
function HLTP_conf_mat(proc_dir, parse_main, parse_quest)
    
    if strcmpi(parse_main, 'yes')
        bhv_data = load([proc_dir, 'bhv_data.mat']);
        
        conf_mat_R = zeros(numel(bhv_data.categories));     % Rec
        conf_mat_U = zeros(numel(bhv_data.categories));     % Unrec
        conf_mat_rea = zeros(numel(bhv_data.categories));   % Real
        conf_mat_scr = zeros(numel(bhv_data.categories));   % Scrambled
        conf_mat_scr_R = zeros(numel(bhv_data.categories)); % Scrambled Rec
        conf_mat_scr_U = zeros(numel(bhv_data.categories)); % Scrambled Unrec
        
        % For each stimulus category
        for s = 1:numel(bhv_data.categories)
            stim_trials = (bhv_data.cat_stimulus == s);
            real_stim_trials = stim_trials & bhv_data.real;
            scr_stim_trials = stim_trials & bhv_data.scrambled;
            % For each response category
            for r = 1:numel(bhv_data.categories)
                resp_trials = (bhv_data.cat_response == r);
                
                conf_mat_R(s, r) = sum(resp_trials(bhv_data.rec & real_stim_trials))...
                    / sum(real_stim_trials & bhv_data.rec);
                conf_mat_U(s, r) = sum(resp_trials(bhv_data.unrec & real_stim_trials))...
                    / sum(real_stim_trials & bhv_data.unrec);
                
                conf_mat_rea(s, r) = sum(resp_trials(real_stim_trials))...
                    ./sum(real_stim_trials);
                conf_mat_scr(s, r) = sum(resp_trials(scr_stim_trials))...
                    ./sum(scr_stim_trials);
                
                conf_mat_scr_R(s, r) = sum(resp_trials(bhv_data.rec & scr_stim_trials))...
                    / sum(scr_stim_trials & bhv_data.rec);
                conf_mat_scr_U(s, r) = sum(resp_trials(bhv_data.unrec & scr_stim_trials))...
                    / sum(scr_stim_trials & bhv_data.unrec);
                
            end
        end
        
        save([proc_dir, '/conf_mats'], ...
            'conf_mat_rea', 'conf_mat_scr', 'conf_mat_R', 'conf_mat_U', 'conf_mat_scr_R', 'conf_mat_scr_U');
        
        % figures:
        cat_init = cell(1, numel(bhv_data.categories));
        for c = 1:numel(bhv_data.categories)
            cat_init{c} = bhv_data.categories{c}(1);
        end
        
        h = figure('position', [40 40 600 400]);
        a1 = subplot(2, 3, 1);
        imagesc(conf_mat_rea, [0 1]); title('real')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize1 = getpixelposition(gca);%get(gca, 'Position');
        
        a2 = subplot(2, 3, 2);
        imagesc(conf_mat_R, [0 1]);     title('real rec')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize2 = getpixelposition(gca);%get(gca, 'Position');  
        
        a3 = subplot(2, 3, 3);
        imagesc(conf_mat_U, [0 1]);    title('real unrec')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize3 = getpixelposition(gca);%get(gca, 'Position');
        
        a4 = subplot(2, 3, 4);
        imagesc(conf_mat_scr, [0 1]);    title('scram')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize4 = getpixelposition(gca);%get(gca, 'Position');

        a5 = subplot(2, 3, 5);
        imagesc(conf_mat_scr_R, [0 1]);     title('scr rec')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize5 = getpixelposition(gca);%get(gca, 'Position');
        
        a6 = subplot(2, 3, 6);
        imagesc(conf_mat_scr_U, [0 1]);    title('scr unrec')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize6 = getpixelposition(gca);%get(gca, 'Position');
        
        %set(gcf,'PaperPositionMode','auto');
        colormap hot; colorbar;
        set(h, 'Position', [40 40 650 400]);
        setpixelposition(a1, origsize1); setpixelposition(a2, origsize2); setpixelposition(a3, origsize3); setpixelposition(a4, origsize4); setpixelposition(a5, origsize5); setpixelposition(a6, origsize6);
        %set(a1, 'Position', origsize1); set(a2, 'Position', origsize2); set(a3, 'Position', origsize3); set(a4, 'Position', origsize4);
        print([proc_dir, '/conf_mats'], '-dpng', '-r300'); close all;
    end
    
    
    %quest
    if strcmpi(parse_quest, 'yes')
    bhv_data = load([proc_dir, 'bhv_dataQ.mat']);
        
        conf_mat_R = zeros(numel(bhv_data.categories));     % rec
        conf_mat_U = zeros(numel(bhv_data.categories));     % Unrec
        conf_mat_rea = zeros(numel(bhv_data.categories));   % Real
        
        % For each stimulus category
        for s = 1:numel(bhv_data.categories)
            stim_trials = (bhv_data.cat_stimulus == s);
            real_stim_trials = stim_trials;
            % For each response category
            for r = 1:numel(bhv_data.categories)
                resp_trials = (bhv_data.cat_response == r);
                
                conf_mat_R(s, r) = sum(resp_trials(bhv_data.rec & real_stim_trials))...
                    / sum(real_stim_trials & bhv_data.rec);
                conf_mat_U(s, r) = sum(resp_trials(bhv_data.unrec & real_stim_trials))...
                    / sum(real_stim_trials & bhv_data.unrec);
                
                conf_mat_rea(s, r) = sum(resp_trials(real_stim_trials))...
                    ./sum(real_stim_trials);
                
            end
        end
        
        save([proc_dir, '/conf_matsQ'], ...
            'conf_mat_rea', 'conf_mat_R', 'conf_mat_U');
        
        % figures:
        cat_init = cell(1, numel(bhv_data.categories));
        for c = 1:numel(bhv_data.categories)
            cat_init{c} = bhv_data.categories{c}(1);
        end
        
        h = figure('position', [40 40 400 400]);
        a1 = subplot(2, 2, 1);
        imagesc(conf_mat_rea, [0 1]); title('total')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize1 = getpixelposition(gca);
        
        a2 = subplot(2, 2, 3);
        imagesc(conf_mat_R, [0 1]);     title('rec')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize2 = getpixelposition(gca);
        
        a3 = subplot(2, 2, 4);
        imagesc(conf_mat_U, [0 1]);    title('unrec')
        set(gca, 'xtick', 1:4, 'xticklabel', cat_init,  'ytick', 1:4, 'yticklabel', cat_init);
        origsize3 = getpixelposition(gca);
        
        colormap hot; colorbar;
        set(h, 'Position', [40 40 450 400]);
        setpixelposition(a1, origsize1); setpixelposition(a2, origsize2); setpixelposition(a3, origsize3);    
        print([proc_dir, '/conf_matsQ'], '-dpng', '-r300'); close all;
    end
end