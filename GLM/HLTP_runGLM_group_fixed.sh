#!/bin/sh
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

# Do not edit these parameters unless you've made relevant changes
subs_to_fix_nospace="$(echo -e "${subs_to_fix}" | tr -d '[:space:]')"
nomissing_glm_name=${main_glm_name}_no${subs_to_fix_nospace} # analysis prefix for run without any bad subjects
indiv_glm_base="${main_glm_name}_no" # each GLM directory should have this title, with the excluded subjects listed (i.e., no010506)

## run initial group GLM
cd $scripts_dir
main_glm_dir=$anal_dir/group_results/${main_glm_name}/${main_glm_name}.gfeat
nomissing_glm_dir=$anal_dir/group_results/${main_glm_name}/${nomissing_glm_name}.gfeat
mkdir $anal_dir/group_results
sh ${group_glm_script}_withfix.sh ${good_subs} # creates "nomissing_glm" GLM
sh ${group_glm_script}.sh ${all_subs} # creates main GLM

## generate missing voxel masks - shows which voxels are missing from particular subject(s), and will be used later to add missing values to the group GLM
# end result is one mask for every combination of missing subjects
for sub in $subs_to_fix; do
    sub_dir=$anal_dir/sub${sub}/proc_data/func
    fslmaths $nomissing_glm_dir/mask -add $sub_dir/inv_mask -thr 2 -bin $main_glm_dir/missing_${sub}
done
proc_subs=""
for sub in $subs_to_fix; do
    for s2 in $subs_to_fix; do if [[ "$sub" != "$s2" ]]; then
        if [[ $proc_subs != *"$s2"* ]]; then
            fslmaths $main_glm_dir/missing_${sub} -add $main_glm_dir/missing_${s2} -thr 2 -bin $main_glm_dir/missing_${sub}${s2}
            fi; fi
    done
    proc_subs="${proc_subs} ${sub}"
done
proc_subs=""
proc_s2=""
for sub in $subs_to_fix; do
    for s2 in $subs_to_fix; do if [[ "$sub" != "$s2" && $proc_subs != *"$s2"* ]]; then
        for s3 in $subs_to_fix; do if [[ "$sub" != "$s3" && "$s2" != "$s3" && $proc_subs != *"$s3"*  && $proc_s2 != *"$s3"* ]]; then
            fslmaths $main_glm_dir/missing_${sub} -add $main_glm_dir/missing_${s2}${s3} -thr 2 -bin $main_glm_dir/missing_${sub}${s2}${s3}
            fi
        done; fi
        proc_s2="${proc_s2} ${s2}"
    done
    proc_s2=""
    proc_subs="${proc_subs} ${sub}"
done


## make each mask unique, including voxels that are missing from that particular group of subjects only.
# For example, if a voxel is missing from both subject 01 and subjects 02, then it will be included in the missing0102 mask, but not missing01 or missing02.
cd $main_glm_dir
for mask in missing_??.nii.gz; do
    fslmaths $mask unique_$mask
    for mask2 in missing_??.nii.gz; do if [[ "${mask}" != "${mask2}" ]]; then
        fslmaths unique_$mask -sub $mask2 -bin unique_${mask}; fi
    done
done
for mask in missing_????.nii.gz; do
    fslmaths $mask unique_$mask
    for mask2 in missing_????.nii.gz; do if [[ "${mask}" != "${mask2}" ]]; then
        fslmaths unique_$mask -sub $mask2 -bin unique_${mask}; fi
    done
done
for mask in missing_??????.nii.gz; do
    fslmaths $mask unique_$mask
    for mask2 in missing_??????.nii.gz; do if [[ "${mask}" != "${mask2}" ]]; then
        fslmaths unique_$mask -sub $mask2 -bin unique_${mask}; fi
    done
done
fslmaths $nomissing_glm_dir/mask -sub $main_glm_dir/mask -bin $main_glm_dir/unique_missing_${subs_to_fix_nospace}
mask="unique_missing_${subs_to_fix_nospace}.nii.gz"
for m in unique_missing_*.nii.gz; do if [[ "${mask}" != "${m}" ]]; then
fslmaths $mask -sub $m -bin $mask; fi
done


## run group GLMs with each possible combination of subjects; there will be one GLM per mask from the previous step
proc_subs=""
proc_s2=""
for sub in $subs_to_fix; do
    sub_list="${good_subs} ${sub}"
    sh $scripts_dir/${group_glm_script}_withfix.sh $sub_list
    for s2 in $subs_to_fix; do if [[ "$sub" != "$s2" && $proc_subs != *"$s2"* ]]; then
        sub_list="${good_subs} ${sub} ${s2}"
        sh $scripts_dir/${group_glm_script}_withfix.sh $sub_list
        for s3 in $subs_to_fix; do if [[ "$sub" != "$s3" && "$s2" != "$s3" && $proc_subs != *"$s3"* && $proc_s2 != *"$s3"* ]]; then
            sub_list="${good_subs} ${sub} ${s2} ${s3}"
            sh $scripts_dir/${group_glm_script}_withfix.sh $sub_list
            fi
        done; fi
    proc_s2="${proc_s2} ${s2}"
    done
    proc_s2=""
    proc_subs="${proc_subs} ${sub}"
done

sub_list="${good_subs}"


## mask results with missing_voxels masks and add to final results
cd $main_glm_dir/cope1.feat/stats
for filename in *.nii.gz; do
    cp ${filename} back_${filename}
done

proc_subs=""
proc_s2=""
for sub in $subs_to_fix; do
    missing=$sub
    missing="$(echo -e "${missing}" | tr -d '[:space:]')"
    glm_dir=$anal_dir/group_results/${main_glm_name}/${indiv_glm_base}${missing}.gfeat
    cd $glm_dir/cope1.feat/stats
    for filename in *.nii.gz; do
        fslmaths ${filename} -mas $main_glm_dir/unique_missing_${missing} -add $main_glm_dir/cope1.feat/stats/${filename} $main_glm_dir/cope1.feat/stats/${filename}
    done
    for s2 in $subs_to_fix; do if [[ "$sub" != "$s2" && $proc_subs != *"$s2"* ]]; then
        missing="$sub $s2"
        missing="$(echo -e "${missing}" | tr -d '[:space:]')"
        glm_dir=$anal_dir/group_results/${main_glm_name}/${indiv_glm_base}${missing}.gfeat
        cd $glm_dir/cope1.feat/stats
        for filename in *.nii.gz; do
            fslmaths ${filename} -mas $main_glm_dir/unique_missing_${missing} -add $main_glm_dir/cope1.feat/stats/${filename} $main_glm_dir/cope1.feat/stats/${filename}
        done
        for s3 in $subs_to_fix; do if [[ "$sub" != "$s3" && "$s2" != "$s3" && $proc_subs != *"$s3"* && $proc_s2 != *"$s3"* ]]; then
            missing="$sub $s2 $s3"
missing="$(echo -e "${missing}" | tr -d '[:space:]')"
            glm_dir=$anal_dir/group_results/${main_glm_name}/${indiv_glm_base}${missing}.gfeat
            cd $glm_dir/cope1.feat/stats
            for filename in *.nii.gz; do
                fslmaths ${filename} -mas $main_glm_dir/unique_missing_${missing} -add $main_glm_dir/cope1.feat/stats/${filename} $main_glm_dir/cope1.feat/stats/${filename}
            done
            fi
        done; fi
    proc_s2="${proc_s2} ${s2}"
    done
    proc_s2=""
    proc_subs="${proc_subs} ${sub}"
done

## run cluster-based thresholding
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
