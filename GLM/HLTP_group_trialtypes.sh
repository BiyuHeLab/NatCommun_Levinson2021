#!/bin/sh

# call as sh group_trialtypes.sh $subjects
# where $subjects is a list of subj numbers like "01 02 03 04"
subjects=$@
#subnums="$(echo -e "${subjects}" | tr -d '[:space:]')"


# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories # point to location of 'directories' file
. $scripts_dir/analysis_parameters

anal_dir="$data_dir/group_results/HLTP_trialtypes"
mkdir $anal_dir

copes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
conditions=(rec_animal unrec_animal rec_face unrec_face rec_house unrec_house rec_object unrec_object rec_animal_scrambled unrec_animal_scrambled rec_face_scrambled unrec_face_scrambled rec_house_scrambled unrec_house_scrambled rec_object_scrambled unrec_object_scrambled)
glms=("")
#glms=("" _responsecat) # blank refers to stimulus-based; responsecat refers to response-based category

for glm in "${glms[@]}"; do

data=""
group=""
evval1=""
evval2=""
evval3=""
evval4=""

index=0
sub_idx=0
subsarray=($subjects)
num_subs=${#subsarray[@]}

for s in $subjects; do
    ((sub_idx++))
    . ${data_dir}/sub${s}/proc_data/behavior/missing_conditions
    sub_dir="${data_dir}/sub${s}/proc_data/func/fixed_conditions_glms_realscr"
    for c in $copes; do
        if [[ $noblocks != *" ${conditions[$c-1]} "* ]]; then
            ((index++))
            data="${data}\# 4D AVW data or FEAT directory (${index})NEWLINEset feat_files(${index}) \\\"${sub_dir}/fixed_${conditions[$c-1]}${glm}\.gfeat/cope${c}.feat\\\"NEWLINE"
	    group="${group}\# Group membership for input ${index}NEWLINEset fmri(groupmem\.${index}) 1NEWLINE"

            for ev in $copes; do
                eval ev$ev="0"
            done
            if [[ ${conditions[$c-1]} = "unrec_"*"scrambled" ]]; then ev4="1.0"
            elif [[ ${conditions[$c-1]} = *"unrec"* ]]; then ev2="1.0"
            elif [[ ${conditions[$c-1]} = *"scrambled" ]]; then ev3="1.0"
            else ev1="1.0"
            fi

        evval1="${evval1}\# Higher-level EV value for EV 1 and input ${index}NEWLINEset fmri(evg${index}\.1) ${ev1}NEWLINE"
        evval2="${evval2}\# Higher-level EV value for EV 2 and input ${index}NEWLINEset fmri(evg${index}\.2) ${ev2}NEWLINE"
        evval3="${evval3}\# Higher-level EV value for EV 3 and input ${index}NEWLINEset fmri(evg${index}\.3) ${ev3}NEWLINE"
        evval4="${evval4}\# Higher-level EV value for EV 4 and input ${index}NEWLINEset fmri(evg${index}\.4) ${ev4}NEWLINE"

fi
done
done

cp $scripts_dir/feat_designs/HLTP_group_trialtypesGLM_design.fsf $anal_dir/HLTP_group_trialtypes${glm}GLM_design.fsf
cd $anal_dir
sed -i -e 's:FEATDATA:'"${data}"':g' HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:EVVAL:${evval1}${evval2}${evval3}${evval4}:g" HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:GROUPMEM:${group}:g" HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e $'s:NEWLINE:\\\n:g' HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:FSLDIR:${FSLDIR}:g" HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:ANALDIR:${anal_dir}:g" HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:NINPUTS:${index}:g" HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:GLMTYPE:${glm}:g" HLTP_group_trialtypes${glm}GLM_design.fsf
sed -i -e "s:SUBNUMS::g" HLTP_group_trialtypes${glm}GLM_design.fsf

feat $anal_dir/HLTP_group_trialtypes${glm}GLM_design.fsf
done
