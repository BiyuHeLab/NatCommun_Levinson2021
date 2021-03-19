
% consolidate all the behavior across subjects and save into .csv, for use in other software packages
% initialize
categories = {'face' 'house' 'object' 'animal'};
columns = {'subject' 'trial' 'recognition' 'stim_cat' 'response_cat' 'real' 'exemplar' 'catRT' 'recRT'};
for col = 1:numel(columns)
    full_data.(columns{col}) = [];
end

for col = columns
    full_data.(char(col)) = [];
end

subjects = {'01' '04' '05' '07' '08' '09' '11' '13' '15' '16' '18' '19' '20' '22' '25' '26' '29' '30' '31' '32' '33' '34' '35' '37' '38'};
data_dir = ''; % PATH TO MAIN DATA DIRECTORY

for subj = subjects
    proc_dir = [data_dir, '/sub', char(subj), '/proc_data/behavior'];
    bhv_data = load([proc_dir, '/bhv_data.mat']);
    sub_data.trial = (1:bhv_data.n_trials)';
    sub_data.subject = repmat(subj, bhv_data.n_trials, 1);
    sub_data.recognition = (bhv_data.rec - bhv_data.unrec)'; % 1 = rec, 0 = no response, -1 = unrec
    sub_data.stim_cat = bhv_data.cat_stimulus'; % 1=face, 2=house, 3=object, 4=animal
    sub_data.response_cat = bhv_data.cat_response';
    sub_data.response_cat(sub_data.response_cat <= 0) = 0; % 0=no response
    sub_data.real = bhv_data.real'; % 1 = real, 0 = scrambled
    sub_data.exemplar = bhv_data.exemplar';
    sub_data.catRT = bhv_data.cat_RT';
    sub_data.recRT = bhv_data.vis_RT';
    for col = columns
        full_data.(char(col)) = [full_data.(char(col)); sub_data.(char(col))];
    end
    clear sub_data
end

T = struct2table(full_data);
writetable(T, [data_dir, '/group_results/behavior/full_behavior.csv'], 'Delimiter', ',');