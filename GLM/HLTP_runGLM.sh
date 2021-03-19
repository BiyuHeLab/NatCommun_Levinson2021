#!/bin/sh

# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories # point to location of 'directories' file
. $scripts_dir/analysis_parameters

subj=$1 #subject number is input with syntax: sh HLTP_runGLM.sh XX
subj_dir="$data_dir/sub$subj"
anal_dir="$subj_dir/proc_data"
. $subj_dir/sub_params

glms="conditions conditions_responsecat conditions_realscr conditions_realscr_responsecat"
index=0 # running total of task blocks
for i in $good_blocks; do
    ((index++))
    block_dir=$anal_dir/func/block${i}
    cd $block_dir

    for dsg in $glms; do
        cp $scripts_dir/feat_designs/HLTP_${dsg}GLM_design.fsf $block_dir/HLTP_${dsg}GLM_design.fsf
        sed -i -e "s#BLOCKDIR#${block_dir}#g" $block_dir/HLTP_${dsg}GLM_design.fsf
        sed -i -e "s/BNUM/${i}/g" $block_dir/HLTP_${dsg}GLM_design.fsf
        sed -i -e "s#FSLDIR#${FSLDIR}#g" $block_dir/HLTP_${dsg}GLM_design.fsf
	feat "HLTP_${dsg}GLM_design.fsf" # run GLM model
	cp -r $block_dir/block${i}_preproc.feat/reg/ $block_dir/${dsg}GLM.feat/reg # move registration files from preprocessing into GLM folder
	rm HLTP_${dsg}GLM_design.fsf
    done
done

########## run condition-based fixed effects ###########

. $anal_dir/behavior/missing_conditions
mkdir $anal_dir/func/fixed_conditions_glms
cd $anal_dir/func/fixed_conditions_glms
glms=("" _responsecat _realscr _realscr_responsecat) # blank refers to stimulus-based; responsecat refers to response-based category

glm_idx=1 # iterate through glms so we know when to add individual scrambled regressors
for glm in "${glms[@]}"; do
    ((glm_idx++))
    if [ $glm_idx -gt 2 ]; then
        realscr="_realscr"
        conditions="rec_animal unrec_animal rec_face unrec_face rec_house unrec_house rec_object unrec_object rec_animal_scrambled unrec_animal_scrambled rec_face_scrambled unrec_face_scrambled rec_house_scrambled unrec_house_scrambled rec_object_scrambled unrec_object_scrambled"
    else
        realscr=""
        conditions="rec_animal unrec_animal rec_face unrec_face rec_house unrec_house rec_object unrec_object"
    fi
    for c in $conditions; do
        index=0
        data="" # string holding GLM .feat directories for blocks to input into fixed effects
        evval=""
        group=""
        eval missed_blocks=${c}${glm}_missed[@]
        for curr_block in $good_blocks; do
            useblock=true
            for i in "${!missed_blocks}"; do
                if [[ "${i}" = "${curr_block}" ]]; then
                    useblock=false
                fi
            done
            if $useblock; then
                ((index++))
		        data="${data}\# 4D AVW data or FEAT directory (${index})NEWLINEset feat_files(${index}) \\\"ANALDIR/func/block${curr_block}/conditions${glm}GLM\.feat\\\"NEWLINE"
                evval="${evval}\# Higher-level EV value for EV 1 and input ${index}NEWLINEset fmri(evg${index}\.1) 1.0NEWLINE"
                group="${group}\# Group membership for input ${index}NEWLINEset fmri(groupmem\.${index}) 1NEWLINE"
            fi
        done
        cp $scripts_dir/feat_designs/HLTP_fixed_conditions${realscr}GLM_design.fsf $anal_dir/func/fixed_conditions_glms${realscr}/HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e 's:FEATDATA:'"${data}"':g' HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e "s:NUMBLOCKS:${index}:g" HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e "s:EVVAL:${evval}:g" HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e "s:GROUPMEM:${group}:g" HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e $'s:NEWLINE:\\\n:g' HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e "s:CONDITION:${c}${glm}:g" HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e "s:FSLDIR:${FSLDIR}:g" HLTP_fixed_${c}${glm}GLM_design.fsf
        sed -i -e "s:ANALDIR:${anal_dir}:g" HLTP_fixed_${c}${glm}GLM_design.fsf

        arr=($conditions)
        for i in "${!arr[@]}"; do
            if [[ "${arr[$i]}" = "${c}" ]]; then
                cond_index=$i
                ((cond_index++))
            fi
        done
        sed -i -e "s:set fmri(copeinput.${cond_index}) 0:set fmri(copeinput.${cond_index}) 1:g" HLTP_fixed_${c}${glm}GLM_design.fsf

        feat HLTP_fixed_${c}${glm}GLM_design.fsf
        rm HLTP_fixed_${c}${glm}GLM_design.fsf
    done
done

# object localizer GLM
loc_designs="categoryGLM"
cd $anal_dir/func/loc
for dsg in $loc_designs; do
    cp $scripts_dir/feat_designs/loc_${dsg}_design.fsf $anal_dir/func/loc/loc_${dsg}_design.fsf
    sed -i -e "s#ANALDIR#${anal_dir}#g" $anal_dir/func/loc/loc_${dsg}_design.fsf
    sed -i -e "s#FSLDIR#${FSLDIR}#g" $anal_dir/func/loc/loc_${dsg}_design.fsf
    $FSLDIR/bin/feat loc_${dsg}_design.fsf
    cp -r $anal_dir/func/loc/loc_preproc.feat/reg/ $anal_dir/func/loc/loc_${dsg}.feat/reg/
done

# object localizer GLM customized for MVPA
cp $scripts_dir/feat_designs/loc_mvpa_GLM_design.fsf loc_mvpa_GLM_design_${sub}.fsf

locmvpadir="${data_dir}/sub${sub}/proc_data/func/loc/mvpa"
mkdir -p $locmvpadir

sed -i -e "s#LOCMVPADIR#${locmvpadir}#g" loc_mvpa_GLM_design_${sub}.fsf
sed -i -e "s#SUBJ#${sub}#g" loc_mvpa_GLM_design_${sub}.fsf
sed -i -e "s#ANALDIR#${data_dir}#g" loc_mvpa_GLM_design${sub}.fsf

feat loc_mvpa_GLM_design_${sub}.fsf
cp -r ${data_dir}/sub${sub}/proc_data/func/loc/loc_preproc.feat/reg/ $locmvpadir/loc_mvpa_GLM.feat/reg
rm loc_mvpa_GLM_design_${sub}.fsf
pes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"
for p in $pes; do
gunzip $locmvpadir/loc_mvpa_GLM.feat/stats/pe${p}.nii.gz
done
gunzip $locmvpadir/loc_mvpa_GLM.feat/mask.nii.gz