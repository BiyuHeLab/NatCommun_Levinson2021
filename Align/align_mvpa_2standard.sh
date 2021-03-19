# align searchlight decoding analyses to standard space

data_dir= ""# PATH TO MAIN DATA DIRECTORY
timepoint="betas"
custom="" # name of particular analysis folder
output="res_balanced_accuracy" # output of interest
subjects="01 04 05 07 08 09 11 13 15 16 18 19 20 22 25 26 29 30 31 32 33 34 35 37 38"


for subj in $subjects; do
    func_dir=$data_dir/sub${subj}/proc_data/func
    mvpa_dir=$func_dir/mvpa/$timepoint/$custom/results
    flirt -in $mvpa_dir/${output} -ref $func_dir/block1/block1_preproc.feat/reg/standard -applyxfm -init $func_dir/block1/block1_preproc.feat/reg/highres2standard.mat -out $mvpa_dir/${output}_standard
done



# permutations
for subj in $subjects; do
    func_dir=$data_dir/sub${subj}/proc_data/func
    mvpa_dir=$func_dir/mvpa/$timepoint/$custom/results/perm
    for i in `seq -f "%04g" 1 100`; do
        flirt -in $mvpa_dir/perm${i}_${output} -ref $func_dir/block1/block1_preproc.feat/reg/standard -applyxfm -init $func_dir/block1/block1_preproc.feat/reg/highres2standard.mat -out $mvpa_dir/perm${i}_${output}_standard
    done
done