% combines multiple datafiles if subject restarted task
% manually enter datafile name (numbered), and number of trials
% copy and paste contents rather than running function

subj = '32';
data_dir = ''; % PATH TO MAIN DATA DIRECTORY
PTBoutdir = dir([data_dir, '/sub', subj, '/raw_data/*data']);
raw_dir = [PTBoutdir.folder, '/', PTBoutdir.name, '/'];
d1 = load([raw_dir, 'datafile1']);  ntr1 = 288;
d2 = load([raw_dir, 'datafile2']);  ntr2 = 144;

param = d1.param;
data = d1.data;
dataQ = d1.dataQ

fnames = fieldnames(data);
for f = 1:numel(fnames)
    if numel(data.(fnames{f})) >= min(ntr1, ntr2)
        data.(fnames{f}) = [d1.data.(fnames{f})(1:ntr1), d2.data.(fnames{f})(1:ntr2)];
    end    
end
data.blockStartTime = [d1.data.blockStartTime, d2.data.blockStartTime];

fnames = fieldnames(d1.data.timing);
for f = 1:numel(fnames)
    if numel(data.timing.(fnames{f})) >= min(ntr1, ntr2)
        data.timing.(fnames{f}) = [d1.data.timing.(fnames{f})(1:ntr1), d2.data.timing.(fnames{f})(1:ntr2)];
    end    
end

fnames = fieldnames(d1.param);
for f = 1:numel(fnames)
    if numel(param.(fnames{f})) == 360 || numel(param.(fnames{f})) == ntr1
        param.(fnames{f}) = [d1.param.(fnames{f})(1:ntr1), d2.param.(fnames{f})(1:ntr2)];
    end
end
save([raw_dir, 'datafile.mat'], 'data', 'param', 'dataQ');
