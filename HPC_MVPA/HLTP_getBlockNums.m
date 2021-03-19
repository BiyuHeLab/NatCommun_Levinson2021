function [good_blocks, bad_blocks] = HLTP_getBlockNums(sub_dir)
% retrieves list of good (usable) blocks from subject's sub_params file,
% and stores as vector in variable good_blocks

sub_params_file = [sub_dir '/sub_params'];
fid = fopen(sub_params_file);
sub_params = textscan(fid, '%s', 'delimiter', '\n');

idx = contains(sub_params{1}, 'good_blocks');
eval(cell2mat(sub_params{1}(idx)));    
good_blocks = str2mat(good_blocks);
good_blocks = str2num(good_blocks);

idx = contains(sub_params{1}, 'bad_blocks');
eval(cell2mat(sub_params{1}(idx)));
bad_blocks = str2mat(bad_blocks);
bad_blocks = str2num(bad_blocks);

fclose(fid);