#!/bin/sh

# call as sh group_anova.sh $subjects
# where $subjects is a list of subj numbers like "01 02 03 04"
subjects=$@
#subnums="$(echo -e "${subjects}" | tr -d '[:space:]')"
subs_to_fix="01 05 11 13"
missingsubs=""
for sub in $subs_to_fix; do
    if [[ $subjects != *"$sub"* ]]; then
        missingsubs="$missingsubs $sub"
    fi
done
missingsubs="$(echo -e "${missingsubs}" | tr -d '[:space:]')"


# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories # point to location of 'directories' file
. $scripts_dir/analysis_parameters

anal_dir="$data_dir/group_results/HLTP_anova_realscr"
mkdir $anal_dir


copes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
conditions=(rec_animal unrec_animal rec_face unrec_face rec_house unrec_house rec_object unrec_object rec_animal_scrambled unrec_animal_scrambled rec_face_scrambled unrec_face_scrambled rec_house_scrambled unrec_house_scrambled rec_object_scrambled unrec_object_scrambled)
glms=("")
#glms=("" _responsecat) # blank refers to stimulus-based; responsecat refers to response-based category
preset_evs=15 # number of evs in design, excluding subject means

for glm in "${glms[@]}"; do

data=""
group=""
means=""
meantitles=""
orthos=""
evval1=""
evval2=""
evval3=""
evval4=""
evval5=""
evval6=""
evval7=""
evval8=""
evval9=""
evval10=""
evval11=""
evval12=""
evval13=""
evval14=""
evval15=""

index=0
sub_idx=0
subsarray=($subjects)
num_subs=${#subsarray[@]}

for s in $subjects; do
    ((sub_idx++))
    sub_mean_ev=$(($sub_idx + $preset_evs))
    . ${data_dir}/sub${s}/proc_data/behavior/missing_conditions
    sub_dir="${data_dir}/sub${s}/proc_data/func/fixed_conditions_glms_realscr"
    for c in $copes; do if [[ $noblocks != *" ${conditions[$c-1]} "* ]]; then
        ((index++))
        data="${data}\# 4D AVW data or FEAT directory (${index})NEWLINEset feat_files(${index}) \\\"${sub_dir}/fixed_${conditions[$c-1]}${glm}\.gfeat/cope${c}.feat\\\"NEWLINE"
	group="${group}\# Group membership for input ${index}NEWLINEset fmri(groupmem\.${index}) 1NEWLINE"

	if (( $c < 3 || (8 < $c & $c < 11) )); then # if animal cope
	    ev2="1.0"
	    ev3="0"
	    ev4="0"
	    ev6="0"
	    ev7="0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev5="1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="1.0"
                    ev10="1.0"
                    ev11="0"
                    ev12="0"
                    ev13="1.0"
                    ev14="0"
                    ev15="0"
                else # if scrambled cope
                    if [[ "$noblocks" == *" ${conditions[9]} "* ]]; then ev1="0"; ev2="2.0"; ev5="0"; ev8="-2.0"; ev9="0"; ev10="-2.0"; ev13="0"; else ev8="-1.0"; ev9="-1.0"; ev10="-1.0"; ev13="-1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[14]} "* ]] || [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev13="0"; fi
                    ev11="0"
                    ev12="0"
                    ev14="0"
                    ev15="0"
                fi
	    else
		ev1="-1.0"
		ev5="-1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="-1.0"
                    ev10="1.0"
                    ev11="0"
                    ev12="0"
                    ev13="-1.0"
                    ev14="0"
                    ev15="0"
                else
                    if [[ "$noblocks" == *" ${conditions[8]} "* ]]; then ev1="0"; ev2="2.0"; ev5="0"; ev8="-2.0"; ev9="0"; ev10="-2.0"; ev13="0"; else ev8="-1.0"; ev9="1.0"; ev10="-1.0"; ev13="1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[14]} "* ]] || [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev13="0"; fi
                    ev11="0"
                    ev12="0"
                    ev14="0"
                    ev15="0"
                fi
	    fi
	elif (( (2 < $c & $c < 5) || (10 < $c & $c < 13) )); then # if face cope
	    ev2="0"
	    ev3="1.0"
	    ev4="0"
	    ev5="0"
	    ev7="0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev6="1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="1.0"
                    ev10="0"
                    ev11="1.0"
                    ev12="0"
                    ev13="0"
                    ev14="1.0"
                    ev15="0"
                else
                    if [[ "$noblocks" == *" ${conditions[11]} "* ]]; then ev1="0"; ev3="2.0"; ev6="0"; ev8="-2.0"; ev9="0"; ev11="-2.0"; ev14="0"; else ev8="-1.0"; ev9="-1.0"; ev11="-1.0"; ev14="-1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[14]} "* ]] || [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev14="0"; fi
                    ev10="0"
                    ev12="0"
                    ev13="0"
                    ev15="0"
                fi
	    else
		ev1="-1.0"
		ev6="-1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="-1.0"
                    ev10="0"
                    ev11="1.0"
                    ev12="0"
                    ev13="0"
                    ev14="-1.0"
                    ev15="0"
                else
                    if [[ "$noblocks" == *" ${conditions[10]} "* ]]; then ev1="0"; ev3="2.0"; ev6="0"; ev8="-2.0"; ev9="0"; ev11="-2.0"; ev14="0"; else ev8="-1.0"; ev9="1.0"; ev11="-1.0"; ev14="1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[14]} "* ]] || [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev14="0"; fi
                    ev10="0"
                    ev12="0"
                    ev13="0"
                    ev15="0"
                fi
	    fi
        elif (( (4 < $c & $c < 7) || (12 < $c & $c < 15) )); then # if house cope
	    ev2="0"
	    ev3="0"
	    ev4="1.0"
	    ev5="0"
	    ev6="0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev7="1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="1.0"
                    ev10="0"
                    ev11="0"
                    ev12="1.0"
                    ev13="0"
                    ev14="0"
                    ev15="1.0"
                else
                    if [[ "$noblocks" == *" ${conditions[13]} "* ]]; then ev1="0"; ev4="2.0"; ev7="0"; ev8="-2.0"; ev9="0"; ev12="-2.0"; ev15="0"; else ev8="-1.0"; ev9="-1.0"; ev12="-1.0"; ev15="-1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[14]} "* ]] || [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev15="0"; fi
                    ev10="0"
                    ev11="0"
                    ev13="0"
                    ev14="0"
                fi
            else
		ev1="-1.0"
		ev7="-1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="-1.0"
                    ev10="0"
                    ev11="0"
                    ev12="1.0"
                    ev13="0"
                    ev14="0"
                    ev15="-1.0"
                else
                    if [[ "$noblocks" == *" ${conditions[12]} "* ]]; then ev1="0"; ev4="2.0"; ev7="0"; ev8="-2.0"; ev9="0"; ev12="-2.0"; ev15="0"; else ev8="-1.0"; ev9="1.0"; ev12="-1.0"; ev15="1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[14]} "* ]] || [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev15="0"; fi
                    ev10="0"
                    ev11="0"
                    ev13="0"
                    ev14="0"
                fi
	    fi
        else # if object cope
	    ev2="-1.0"
	    ev3="-1.0"
	    ev4="-1.0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev5="-1.0"
		ev6="-1.0"
		ev7="-1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="1.0"
                    ev10="-1.0"
                    ev11="-1.0"
                    ev12="-1.0"
                    ev13="-1.0"
                    ev14="-1.0"
                    ev15="-1.0"
                else
                    if [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev1="0"; ev2="-2.0"; ev3="-2.0"; ev4="-2.0"; ev5="0"; ev6="0"; ev7="0"; ev8="-2.0"; ev9="0"; ev10="2.0": ev11="2.0"; ev12="2.0"; ev13="0"; ev14="0"; ev15="0"; else ev8="-1.0"; ev9="-1.0"; ev10="1.0"; ev11="1.0"; ev12="1.0"; ev13="1.0"; ev14="1.0"; ev15="1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[8]} "* ]] || [[ "$noblocks" == *" ${conditions[9]} "* ]]; then ev13="0"; fi
                    if [[ "$noblocks" == *" ${conditions[10]} "* ]] || [[ "$noblocks" == *" ${conditions[11]} "* ]]; then ev14="0"; fi
                    if [[ "$noblocks" == *" ${conditions[13]} "* ]] || [[ "$noblocks" == *" ${conditions[14]} "* ]]; then ev15="0"; fi
                fi
	    else
		ev1="-1.0"
		ev5="1.0"
		ev6="1.0"
		ev7="1.0"
                if (( $c < 9 )); then # if real cope
                    ev8="1.0"
                    ev9="-1.0"
                    ev10="-1.0"
                    ev11="-1.0"
                    ev12="-1.0"
                    ev13="1.0"
                    ev14="1.0"
                    ev15="1.0"
                else
                    if [[ "$noblocks" == *" ${conditions[15]} "* ]]; then ev8="-2.0"; ev9="0"; ev10="2.0": ev11="2.0"; ev12="2.0"; ev13="0"; ev14="0"; ev15="0"; else ev8="-1.0"; ev9="1.0"; ev10="1.0"; ev11="1.0"; ev12="1.0"; ev13="-1.0"; ev14="-1.0"; ev15="-1.0"; fi
                    if [[ "$noblocks" == *" ${conditions[8]} "* ]] || [[ "$noblocks" == *" ${conditions[9]} "* ]]; then ev13="0"; fi
                    if [[ "$noblocks" == *" ${conditions[10]} "* ]] || [[ "$noblocks" == *" ${conditions[11]} "* ]]; then ev14="0"; fi
                    if [[ "$noblocks" == *" ${conditions[13]} "* ]] || [[ "$noblocks" == *" ${conditions[14]} "* ]]; then ev15="0"; fi
                fi
	    fi
	fi

        evval1="${evval1}set fmri(evg${index}\.1) ${ev1}NEWLINE"
        evval2="${evval2}set fmri(evg${index}\.2) ${ev2}NEWLINE"
        evval3="${evval3}set fmri(evg${index}\.3) ${ev3}NEWLINE"
        evval4="${evval4}set fmri(evg${index}\.4) ${ev4}NEWLINE"
        evval5="${evval5}set fmri(evg${index}\.5) ${ev5}NEWLINE"
        evval6="${evval6}set fmri(evg${index}\.6) ${ev6}NEWLINE"
        evval7="${evval7}set fmri(evg${index}\.7) ${ev7}NEWLINE"
        evval8="${evval8}set fmri(evg${index}\.8) ${ev8}NEWLINE"
        evval9="${evval9}set fmri(evg${index}\.9) ${ev9}NEWLINE"
        evval10="${evval10}set fmri(evg${index}\.10) ${ev10}NEWLINE"
        evval11="${evval11}set fmri(evg${index}\.11) ${ev11}NEWLINE"
        evval12="${evval12}set fmri(evg${index}\.12) ${ev12}NEWLINE"
        evval13="${evval13}set fmri(evg${index}\.13) ${ev13}NEWLINE"
        evval14="${evval14}set fmri(evg${index}\.14) ${ev14}NEWLINE"
        evval15="${evval15}set fmri(evg${index}\.15) ${ev15}NEWLINE"

	means="${means}set fmri(evg${index}.${sub_mean_ev}) 1.0NEWLINE" #add \ before . if using sed
	for ev in $(seq ${num_subs}); do
	    curr_ev=$(($ev+$preset_evs))
	    if (( $curr_ev != $sub_mean_ev )); then
		means="${means}set fmri(evg${index}.${curr_ev}) 0NEWLINE" #add \ before . if using sed
	    fi
	done
        fi
    done
    meantitles="${meantitles}set fmri(evtitle${sub_mean_ev}) \\\"subj${s}_mean\\\"NEWLINEset fmri(shape${sub_mean_ev}) 2NEWLINEset fmri(convolve${sub_mean_ev}) 0NEWLINEset fmri(convolve_phase${sub_mean_ev}) 0NEWLINEset fmri(tempfilt_yn${sub_mean_ev}) 0NEWLINEset fmri(deriv_yn${sub_mean_ev}) 0NEWLINE"
done

for i in $(seq ${sub_mean_ev}); do
    orthos="${orthos}set fmri(ortho${i}.0) 0NEWLINE"
    for j in $(seq ${sub_mean_ev}); do
	orthos="${orthos}set fmri(ortho${i}.${j}) 0NEWLINE"
    done
done

cp $scripts_dir/feat_designs/HLTP_group_anova_realscrGLM_design.fsf $anal_dir/HLTP_group_anova_realscr${glm}GLM_design.fsf
cd $anal_dir
sed -i -e 's:FEATDATA:'"${data}"':g' HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:EVVAL1:${evval1}${evval2}${evval3}${evval4}${evval5}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:EVVAL2:${evval6}${evval7}${evval8}${evval9}${evval10}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:EVVAL3:${evval11}${evval12}${evval13}${evval14}${evval15}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
echo $means > means.txt
printf '%s\n' '/MEANEVS/r means.txt' 1 '/MEANEVS/d' w | ed HLTP_group_anova_realscr${glm}GLM_design.fsf
rm means.txt
#sed -i -e "s:MEANEVS:${means}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:MEANEVPARAMS:${meantitles}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:GROUPMEM:${group}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:ORTHOS:${orthos}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e $'s:NEWLINE:\\\n:g' HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:FSLDIR:${FSLDIR}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:ANALDIR:${anal_dir}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:NINPUTS:${index}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:NUMEVS:${sub_mean_ev}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:GLMTYPE:${glm}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf
sed -i -e "s:SUBNUMS:_no${missingsubs}:g" HLTP_group_anova_realscr${glm}GLM_design.fsf

feat $anal_dir/HLTP_group_anova_realscr${glm}GLM_design.fsf
done
