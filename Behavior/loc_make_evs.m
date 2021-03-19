function loc_make_evs(raw_dir, proc_dir)


ev_dir = [proc_dir, '/func/loc/evs'];
mkdir(ev_dir);
cd(ev_dir);

locdata = load([raw_dir, '/locdata.mat']);
ntr = 221;
bhv_data.categories = {'face', 'house', 'object', 'animal'};
block_on_tr = 7;
block_of_tr = 4;
n_blocks = 20;
start_tr = 1;
block_onset_times = start_tr + 1:11:ntr;
ev_vis = zeros(1, ntr);
for tt = block_onset_times
    ev_vis(tt:(tt + block_on_tr - 1)) = 1;
end
ev_vis(222:end) = [];
dlmwrite(['visual_ev.txt'], ev_vis, 'delimiter', '\n');
block_names = locdata.data.exemplar(:, 1);
for cat = 1:numel(bhv_data.categories)
    ev = zeros(1, ntr);
    block_event = ~cellfun(@isempty, strfind(block_names, bhv_data.categories{cat}));
    for tt = block_onset_times(block_event)
        ev(tt:(tt + block_on_tr - 1)) = 1;
    end
    ev(222:end) = [];
    dlmwrite([bhv_data.categories{cat}, '_ev.txt'], ev, 'delimiter', '\n');
end


%% for TDT decoding - separate ev per block
mkdir([ev_dir, '/mvpa']);
mkdir([ev_dir, '/mvpa/fsl']);
cd([ev_dir, '/mvpa/fsl']);
for cat = 1:numel(bhv_data.categories)
    block_event = ~cellfun(@isempty, strfind(block_names, bhv_data.categories{cat}));
    n = 1; %running total of blocks per category
    for tt = block_onset_times(block_event)
        ev = zeros(1, ntr);
        ev(tt:(tt + block_on_tr - 1)) = 1;
        ev(222:end) = [];
        dlmwrite([bhv_data.categories{cat}, num2str(n), '.txt'], ev, 'delimiter', '\n');
        n = n + 1;
    end
end
