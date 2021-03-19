#!/bin/sh

# MAIN PURPOSE OF THIS SCRIPT: RE-RUN CLUSTER-BASED THRESHOLDING, USING A NEW THRESHOLD, ON EXISTING HIGHER-ORDER GLM ANALYSIS.

# Given a set of subjects where some have incomplete acquisition windows (missing voxels), calculates whole-brain GLM result in FSL.
# Each voxel's statistic is calculated only from those subjects that have a data point at that voxel.
# This is useful because FSL by default will only calculate statistics on voxels that are shared by all subjects.
# A separate analysis is run for each possible group of subjects, to generate a value at each voxel that includes the maximum number of subjects.
# Written 10/1/18 by MGL

## PREPARATION AND PARAMETERS
# STEPS TO DO:
# 1. For each subject to fix, create an "inverse mask" where brain voxels are 0, and all other voxels are 1.
# 2. Write a script that runs a group GLM analysis using a particular group of subjects. There should also be a version of the script whose name ends with "_withfix". Alternatively, you can skip the GLM-running steps below and create each one manually.
# 3. Edit below parameters with your analysis details

glm_type=$1
all_subs="01 04 05 07 08 09 11 13 15 16 18 19 20 22 25 26 29 30 31 32 33 34 35 37 38"
subs_to_fix="01 05 11 13"
good_subs="04 07 08 09 15 16 18 19 20 22 25 26 29 30 31 32 33 34 35 37 38"
anal_dir="" # PATH TO MAIN DATA DIRECTORY
scripts_dir= # PATH TO SCRIPTS DIRECTORY
scripts_dir=$scripts_dir/GLM
group_glm_script=HLTP_group_$glm_type # name of group GLM script from Step 2
main_glm_name=HLTP_$glm_type # prefix of analysis directory
# now fix all zstats and zfstats
#zclusts="1 2 3 4" # which t-test z statistics to fix, this depends on design
#zfclusts="" # which f-test z statistics to fix
zthresh=2.3
pthresh=0.05

main_glm_dir=$anal_dir/group_results/${main_glm_name}/${main_glm_name}.gfeat

## run cluster-based thresholding
cd $main_glm_dir/cope1.feat/stats
zclusts=$(ls zstat{?,??}.nii.gz | wc -l) # extract number of zstats with 1 or 2 digits
zfclusts=$(ls zfstat{?,??}.nii.gz | wc -l) # extract number of zfstats with 1 or 2 digits
cd $main_glm_dir/cope1.feat
dlh=$(cat stats/smoothness | grep 'DLH' | grep -Eo '[0-9].*')
vol=$(cat stats/smoothness | grep 'VOLUME' | grep -Eo '[0-9]*')
for z in $(seq $zclusts); do
    fslmaths stats/zstat${z} thresh_zstat${z}
    cluster -i thresh_zstat${z} -t $zthresh --othresh=thresh_zstat${z} -o cluster_mask_zstat${z} --connectivity=26 --mm --olmax=lmax_zstat${z}_std.txt --scalarname=Z -p $pthresh -d $dlh --volume=$vol -c stats/cope${z} > cluster_zstat${z}_std.txt
    cluster2html . cluster_zstat${z} -std
done
for zf in $(seq $zfclusts); do
    fslmaths stats/zfstat${zf} thresh_zfstat${zf}
    cluster -i thresh_zfstat${zf} -t $zthresh --othresh=thresh_zfstat${zf} -o cluster_mask_zfstat${zf} --connectivity=26 --mm --olmax=lmax_zfstat${zf}_std.txt --scalarname=Z -p $pthresh -d $dlh --volume=$vol > cluster_zfstat${zf}_std.txt
    cluster2html . cluster_zfstat${zf} -std
done
