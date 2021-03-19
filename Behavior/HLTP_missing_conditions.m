function HLTP_missing_conditions(proc_dir)
% for each block, find conditions for which no trials exist and save in
% file

real = [];
load([proc_dir, 'bhv_data.mat']);
n_blocks = n_trials / 24;


for c = 1:numel(categories)
    missing_conditions.(['rec_' categories{c}]) = [];
    missing_conditions.(['unrec_' categories{c}]) = [];
    missing_conditions.(['rec_' categories{c} '_responsecat']) = [];
    missing_conditions.(['unrec_' categories{c} '_responsecat']) = [];
    missing_conditions.(['rec_' categories{c} '_scrambled']) = [];
    missing_conditions.(['unrec_' categories{c} '_scrambled']) = [];
    missing_conditions.(['rec_' categories{c} '_scrambled_responsecat']) = [];
    missing_conditions.(['unrec_' categories{c} '_scrambled_responsecat']) = [];
    missing_conditions.(['rec_' categories{c} '_real_responsecat']) = [];
    missing_conditions.(['unrec_' categories{c} '_real_responsecat']) = [];
end

trial_iter = 1;
for blk = 1:n_blocks
    blk_index = trial_iter:trial_iter+23;
    for c = 1:numel(categories)
        % based on stimulus category
        cat_img = ~cellfun(@isempty, strfind(exemplar(blk_index), categories{c})) & real(blk_index);
        if ~sum(cat_img & rec(blk_index))
            missing_conditions.(['rec_' categories{c}]) = [missing_conditions.(['rec_' categories{c}]) blk];
        end
        if ~sum(cat_img & unrec(blk_index))
            missing_conditions.(['unrec_' categories{c}]) = [missing_conditions.(['unrec_' categories{c}]) blk];
        end
        % based on response category
        cat_img = cat_response(blk_index) == c;
        if ~sum(cat_img & rec(blk_index))
            missing_conditions.(['rec_' categories{c} '_responsecat']) = [missing_conditions.(['rec_' categories{c} '_responsecat']) blk];
        end
        if ~sum(cat_img & unrec(blk_index))
            missing_conditions.(['unrec_' categories{c} '_responsecat']) = [missing_conditions.(['unrec_' categories{c} '_responsecat']) blk];
        end
        if ~sum(cat_img & rec(blk_index) & real(blk_index))
            missing_conditions.(['rec_' categories{c} '_real_responsecat']) = [missing_conditions.(['rec_' categories{c} '_real_responsecat']) blk];
        end
        if ~sum(cat_img & unrec(blk_index) & real(blk_index))
            missing_conditions.(['unrec_' categories{c} '_real_responsecat']) = [missing_conditions.(['unrec_' categories{c} '_real_responsecat']) blk];
        end
        if ~sum(cat_img & rec(blk_index) & scrambled(blk_index))
            missing_conditions.(['rec_' categories{c} '_scrambled_responsecat']) = [missing_conditions.(['rec_' categories{c} '_scrambled_responsecat']) blk];
        end
        if ~sum(cat_img & unrec(blk_index) & scrambled(blk_index))
            missing_conditions.(['unrec_' categories{c} '_scrambled_responsecat']) = [missing_conditions.(['unrec_' categories{c} '_scrambled_responsecat']) blk];
        end        
        % scrambled images
        cat_img = ~cellfun(@isempty, strfind(exemplar(blk_index), categories{c})) & scrambled(blk_index);
        if ~sum(cat_img & rec(blk_index))
            missing_conditions.(['rec_' categories{c} '_scrambled']) = [missing_conditions.(['rec_' categories{c} '_scrambled']) blk];
        end
        if ~sum(cat_img & unrec(blk_index))
            missing_conditions.(['unrec_' categories{c} '_scrambled']) = [missing_conditions.(['unrec_' categories{c} '_scrambled']) blk];
        end
    end
    trial_iter = trial_iter + 24;    
end

noblocks = '.';
flds = fields(missing_conditions);
for f = 1:numel(flds)
    if numel(missing_conditions.(flds{f})) == n_blocks
        noblocks = [noblocks ' ' flds{f}];
    end
end
        

str_format = {};
for c = 1:numel(categories)
    curr_cat = categories{c};
    str_format = [str_format; ['rec_' curr_cat '_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['rec_' curr_cat])))] ')'];
    str_format = [str_format; ['unrec_' curr_cat '_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['unrec_' curr_cat]))) ')']];
    str_format = [str_format; ['rec_' curr_cat '_responsecat_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['rec_' curr_cat '_responsecat'])))] ')'];
    str_format = [str_format; ['unrec_' curr_cat '_responsecat_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['unrec_' curr_cat '_responsecat'])))] ')'];
    str_format = [str_format; ['rec_' curr_cat '_scrambled_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['rec_' curr_cat '_scrambled'])))] ')'];
    str_format = [str_format; ['unrec_' curr_cat '_scrambled_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['unrec_' curr_cat '_scrambled'])))] ')'];
    str_format = [str_format; ['rec_' curr_cat '_scrambled_responsecat_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['rec_' curr_cat '_scrambled_responsecat'])))] ')'];
    str_format = [str_format; ['unrec_' curr_cat '_scrambled_responsecat_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['unrec_' curr_cat '_scrambled_responsecat'])))] ')'];
    str_format = [str_format; ['rec_' curr_cat '_real_responsecat_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['rec_' curr_cat '_real_responsecat'])))] ')'];
    str_format = [str_format; ['unrec_' curr_cat '_real_responsecat_missed=(' strtrim(sprintf('%d ', ...
        missing_conditions.(['unrec_' curr_cat '_real_responsecat'])))] ')'];    
end
str_format = [str_format; 'noblocks="' sprintf('%s ', noblocks) ' ."'];


fname = fopen([proc_dir 'missing_conditions'], 'w');
fprintf(fname, '%s\n', str_format{:});
fclose(fname);