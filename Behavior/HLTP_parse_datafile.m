%HLTP_parse_datafile   Parse the file that is created in psychtoolbox
%
%   [bhv_data, bhv_dataQ] = HLTP_parse_datafile(raw_dir, proc_dir, parse_main, parse_quest)
%   has four input arguments.  
%   raw_dir directory where datafile.mat is located
%   proc_dir directory where the new struct is to be saved
%   outputs are structs containing the parsed behavioral data (bhv from behavior)
%   bhv_data    - main HLTP experiment
%   bhv_dataQ   - Quest
%   adapted from HLTP MEG for HLTP fMRI
%   optimized for unix (/, not \)
function [bhv_data, bhv_dataQ] = HLTP_parse_datafile(raw_dir, proc_dir, parse_main, parse_quest)
    load([raw_dir, 'datafile.mat']);
    bhv_data.categories = param.categories;
    n_exemplars = 5;
    
    if strcmpi(parse_main, 'yes');
        
        scrambled_index = '6';
       
        n = numel(data.exemplar);
        bhv_data.n_trials = n;
        bhv_data.rec = (data.detectR(1:n) == 1);
        bhv_data.unrec = (data.detectR(1:n) == 2);
        bhv_data.cat_response = data.selected_cat(1:n);
        bhv_data.cat_responseName = {};
        for i = 1:n
            if bhv_data.cat_response(i) > 0
                bhv_data.cat_responseName(i) = bhv_data.categories(bhv_data.cat_response(i));
            else bhv_data.cat_responseName(i) = {[]};
            end
        end
        bhv_data.cat_stimulus = ceil(data.stimID(1:n) / (n_exemplars + 1));
        bhv_data.exemplar = data.exemplar;
        bhv_data.no_response_vis = data.detectR(1:n) <= 0;
        bhv_data.no_response_cat = bhv_data.cat_response <= 0;
        bhv_data.cat_RT = data.catRT(1:n);
        bhv_data.vis_RT =  data.detectRT(1:n);
        bhv_data.scrambled = ~cellfun(@isempty, strfind(data.exemplar, scrambled_index));
        bhv_data.real = ~bhv_data.scrambled;
        bhv_data.contrast = param.stimContrast;
        bhv_data.correct = zeros(1, bhv_data.n_trials);
        bhv_data.scrambled_correct = zeros(1, bhv_data.n_trials);
        for trial_i = 1:bhv_data.n_trials
            if bhv_data.cat_response(trial_i) > 0
                bhv_data.correct(trial_i) = ~isempty(strfind(data.exemplar{trial_i}, ...
                    bhv_data.categories{bhv_data.cat_response(trial_i)}));
            end
        end
        
        save([proc_dir, 'bhv_data.mat'], '-struct', 'bhv_data');
        
        % MINI QUEST
        if isfield(dataQ, 'mini')
            bhv_dataQmini.categories = {'face', 'house', 'object', 'animal'};
            n = numel(dataQ.mini.exemplar);
            bhv_dataQmini.n_trials = n;
            bhv_dataQmini.rec = (dataQ.mini.detectR(1:n) == 1);
            bhv_dataQmini.unrec = (dataQ.mini.detectR(1:n) == 2);
            bhv_dataQmini.cat_response = dataQ.mini.selected_cat(1:n);
            bhv_dataQmini.cat_stimulus = ceil(dataQ.mini.stimID(1:n)/(n_exemplars));
            bhv_dataQmini.exemplar = dataQ.mini.exemplar;
            bhv_dataQmini.no_response_vis = dataQ.mini.detectR(1:n) <= 0;
            bhv_dataQmini.no_response_cat = bhv_dataQmini.cat_response <= 0;
            bhv_dataQmini.cat_RT = dataQ.mini.catRT(1:n);
            bhv_dataQmini.vis_RT =  dataQ.mini.detectRT(1:n);
            bhv_dataQmini.contrast = dataQ.mini.Wg;
            bhv_dataQmini.qID = dataQ.mini.qID;
            bhv_dataQmini.correct = zeros(1, bhv_dataQmini.n_trials);
            for trial_i = 1:bhv_dataQmini.n_trials
                if bhv_dataQmini.cat_response(trial_i) > 0
                    bhv_dataQmini.correct(trial_i) = ~isempty(strfind(dataQ.mini.exemplar{trial_i}, ...
                        bhv_dataQmini.categories{bhv_dataQmini.cat_response(trial_i)}));
                end
            end
            save([proc_dir, '/bhv_dataQmini.mat'], '-struct', 'bhv_dataQmini');
        end
    end
    
    if strcmpi(parse_quest, 'yes')
        bhv_dataQ.categories = {'face', 'house', 'object', 'animal'};
        n = numel(dataQ.exemplar);
        bhv_dataQ.n_trials = n;
        bhv_dataQ.rec = (dataQ.detectR(1:n) == 1);
        bhv_dataQ.unrec = (dataQ.detectR(1:n) == 2);
        bhv_dataQ.cat_response = dataQ.selected_cat(1:n);
        bhv_dataQ.cat_stimulus = ceil(dataQ.stimID(1:n)/(n_exemplars));
        bhv_dataQ.exemplar = dataQ.exemplar;
        bhv_dataQ.no_response_vis = dataQ.detectR(1:n) <= 0;
        bhv_dataQ.no_response_cat = bhv_dataQ.cat_response <= 0;
        bhv_dataQ.cat_RT = dataQ.catRT(1:n);
        bhv_dataQ.vis_RT =  dataQ.detectRT(1:n);
        bhv_dataQ.contrast = dataQ.Wg;
        bhv_dataQ.qID = dataQ.qID;
        bhv_dataQ.correct = zeros(1, bhv_dataQ.n_trials);
        for trial_i = 1:bhv_dataQ.n_trials
            if bhv_dataQ.cat_response(trial_i) > 0
                bhv_dataQ.correct(trial_i) = ~isempty(strfind(dataQ.exemplar{trial_i}, ...
                    bhv_dataQ.categories{bhv_dataQ.cat_response(trial_i)}));
            end
        end
        save([proc_dir, '/bhv_dataQ.mat'], '-struct', 'bhv_dataQ');
    end
    
end