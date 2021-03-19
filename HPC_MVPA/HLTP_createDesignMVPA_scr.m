function cfg = HLTP_createDesignMVPA_scr(cfg)
%

if ~isfield(cfg, 'good_blocks')
    cfg.good_blocks = HLTP_getBlockNums([cfg.subdir]);
end

if strfind(cfg.tp, 'beta') % if analyzing GLM betas, not BOLD timepoints
    % get which conditions are missing from which blocks
    filename = [cfg.subdir '/proc_data/behavior/missing_conditions'];
    fid = fopen(filename);
    msng = textscan(fid, '%s', 'delimiter', '\n');
    fclose(fid);
    
    for i = 1:numel(msng{1})
        msng{1}(i) = strrep(msng{1}(i), '(', '[');
        msng{1}(i) = strrep(msng{1}(i), ')', ']');
        eval(cell2mat(msng{1}(i)));
    end

    if cfg.files.response_cat % here assuming conditions_realscr_responsecatGLM is used
        stimuli = {'rec_animal_real_responsecat' 'unrec_animal_real_responsecat' 'rec_face_real_responsecat' 'unrec_face_real_responsecat' 'rec_house_real_responsecat' 'unrec_house_real_responsecat' 'rec_object_real_responsecat' 'unrec_object_real_responsecat' 'rec_animal_scrambled_responsecat' 'unrec_animal_scrambled_responsecat' 'rec_face_scrambled_responsecat' 'unrec_face_scrambled_responsecat' 'rec_house_scrambled_responsecat' 'unrec_house_scrambled_responsecat' 'rec_object_scrambled_responsecat' 'unrec_object_scrambled_responsecat'};
    else    
        stimuli = {'rec_animal' 'unrec_animal' 'rec_face' 'unrec_face' 'rec_house' 'unrec_house' 'rec_object' 'unrec_object' 'rec_animal_scrambled' 'unrec_animal_scrambled' 'rec_face_scrambled' 'unrec_face_scrambled' 'rec_house_scrambled' 'unrec_house_scrambled' 'rec_object_scrambled' 'unrec_object_scrambled'};
    end

    msng_blocks = cell(numel(stimuli), 1);
    for stim = 1:numel(stimuli)
        msng_blocks{stim} = eval([stimuli{stim} '_missed']);
    end
end

imgs = {};
labels = [];
chunks = [];
for blk = cfg.good_blocks
    blockdir = [cfg.subdir, '/proc_data/func/block', num2str(blk)];
        glmdir=[blockdir, '/', cfg.inputname , '/stats/'];
        
        % sort inputs
        for cls = 1:numel(cfg.classes)
            cls_index = round(cfg.classes(cls) / 2);
            if ~sum(ismember(msng_blocks{cls_index}, blk))
                class_beta = [glmdir 'pe' num2str(cfg.classes(cls)) cfg.beta_suffix];
                imgs = [imgs; class_beta];
                chunks = [chunks; blk];
                if strcmp(cfg.conditions, 'cat')
                    if numel(cfg.classes) > 4 %if including both rec and unrec
                        if cls < 3; curr_label = 1; elseif 2 < cls & cls < 5; curr_label = 2; elseif 4 < cls & cls < 7; curr_label = 3; else curr_label = 4; end
                        else curr_label = cls;
                    end
                elseif strcmp(cfg.conditions, 'rec')
                    if rem(cls, 2) % rec beta
                        curr_label = 1;
                    else % unrec
                        curr_label = -1;
                    end
                end
                labels = [labels; curr_label];
            end
        end
end
    cfg.files.name = imgs;
    cfg.files.label = labels;
    cfg.files.chunk = chunks;

cfg.design = make_design_cv(cfg);
end
