#!/bin/sh

# call as sh group_anova.sh $subjects
# where $subjects is a list of subj numbers like "01 02 03 04"
subjects=$@
#subnums="$(echo -e "${subjects}" | tr -d '[:space:]')"


# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories # point to location of 'directories' file
. $scripts_dir/analysis_parameters

anal_dir="$data_dir/group_results/HLTP_anova_real"
mkdir $anal_dir


copes="1 2 3 4 5 6 7 8"
conditions=(rec_animal unrec_animal rec_face unrec_face rec_house unrec_house rec_object unrec_object)
glms=("")
#glms=("" _responsecat) # blank refers to stimulus-based; responsecat refers to response-based category

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

index=0
sub_idx=0
subsarray=($subjects)
num_subs=${#subsarray[@]}

for s in $subjects; do
    ((sub_idx++))
    sub_mean_ev=$(($sub_idx + 7))
    sub_dir="${data_dir}/sub${s}/proc_data/func/fixed_conditions_glms_realscr"
    for c in $copes; do
        ((index++))
        data="${data}\# 4D AVW data or FEAT directory (${index})NEWLINEset feat_files(${index}) \\\"${sub_dir}/fixed_${conditions[$c-1]}${glm}\.gfeat/cope${c}.feat\\\"NEWLINE"
	group="${group}\# Group membership for input ${index}NEWLINEset fmri(groupmem\.${index}) 1NEWLINE"

	if (( $c < 3 )); then # if animal cope
	    ev2="1.0"
	    ev3="0"
	    ev4="0"
	    ev6="0"
	    ev7="0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev5="1.0"
	    else
		ev1="-1.0"
		ev5="-1.0"
	    fi
	elif (( 2 < $c & $c < 5 )); then # if face cope
	    ev2="0"
	    ev3="1.0"
	    ev4="0"
	    ev5="0"
	    ev7="0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev6="1.0"
	    else
		ev1="-1.0"
		ev6="-1.0"
	    fi
	elif (( 4 < $c & $c < 7 )); then # if house cope
	    ev2="0"
	    ev3="0"
	    ev4="1.0"
	    ev5="0"
	    ev6="0"
	    if (( $c % 2 )); then # if rec cope
	        ev1="1.0"
		ev7="1.0"
	    else
		ev1="-1.0"
		ev7="-1.0"
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
	    else
		ev1="-1.0"
		ev5="1.0"
		ev6="1.0"
		ev7="1.0"
	    fi
	fi

        evval1="${evval1}\# Higher-level EV value for EV 1 and input ${index}NEWLINEset fmri(evg${index}\.1) ${ev1}NEWLINE"
        evval2="${evval2}\# Higher-level EV value for EV 2 and input ${index}NEWLINEset fmri(evg${index}\.2) ${ev2}NEWLINE"
        evval3="${evval3}\# Higher-level EV value for EV 3 and input ${index}NEWLINEset fmri(evg${index}\.3) ${ev3}NEWLINE"
        evval4="${evval4}\# Higher-level EV value for EV 4 and input ${index}NEWLINEset fmri(evg${index}\.4) ${ev4}NEWLINE"
        evval5="${evval5}\# Higher-level EV value for EV 5 and input ${index}NEWLINEset fmri(evg${index}\.5) ${ev5}NEWLINE"
        evval6="${evval6}\# Higher-level EV value for EV 6 and input ${index}NEWLINEset fmri(evg${index}\.6) ${ev6}NEWLINE"
        evval7="${evval7}\# Higher-level EV value for EV 7 and input ${index}NEWLINEset fmri(evg${index}\.7) ${ev7}NEWLINE"

	means="${means}set fmri(evg${index}.${sub_mean_ev}) 1.0NEWLINE" #add \ before . if using sed
	for ev in $(seq ${num_subs}); do
	    curr_ev=$(($ev+7))
	    if (( $curr_ev != $sub_mean_ev )); then
		means="${means}set fmri(evg${index}.${curr_ev}) 0NEWLINE" #add \ before . if using sed
	    fi
	done
    done
    meantitles="${meantitles}set fmri(evtitle${sub_mean_ev}) \\\"subj${s}_mean\\\"NEWLINEset fmri(shape${sub_mean_ev}) 2NEWLINEset fmri(convolve${sub_mean_ev}) 0NEWLINEset fmri(convolve_phase${sub_mean_ev}) 0NEWLINEset fmri(tempfilt_yn${sub_mean_ev}) 0NEWLINEset fmri(deriv_yn${sub_mean_ev}) 0NEWLINE"
done

for i in $(seq ${sub_mean_ev}); do
    orthos="${orthos}set fmri(ortho${i}.0) 0NEWLINE"
    for j in $(seq ${sub_mean_ev}); do
	orthos="${orthos}set fmri(ortho${i}.${j}) 0NEWLINE"
    done
done

cp $scripts_dir/feat_designs/HLTP_group_anovaGLM_design.fsf $anal_dir/HLTP_group_anova${glm}GLM_design.fsf
cd $anal_dir
sed -i -e 's:FEATDATA:'"${data}"':g' HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:EVVAL:${evval1}${evval2}${evval3}${evval4}${evval5}${evval6}${evval7}:g" HLTP_group_anova${glm}GLM_design.fsf
echo $means > means.txt
printf '%s\n' '/MEANEVS/r means.txt' 1 '/MEANEVS/d' w | ed HLTP_group_anova${glm}GLM_design.fsf
rm means.txt
sed -i -e "s:MEANEVPARAMS:${meantitles}:g" HLTP_group_anova${glm}GLM_design.fsf
#sed -i -e "s:MEANEVS:${means}${meantitles}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:GROUPMEM:${group}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:ORTHOS:${orthos}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e $'s:NEWLINE:\\\n:g' HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:FSLDIR:${FSLDIR}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:ANALDIR:${anal_dir}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:NINPUTS:${index}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:NUMEVS:${sub_mean_ev}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:GLMTYPE:_real${glm}:g" HLTP_group_anova${glm}GLM_design.fsf
sed -i -e "s:SUBNUMS::g" HLTP_group_anova${glm}GLM_design.fsf # don't enter particular subject numbers in GLM directory name

feat $anal_dir/HLTP_group_anova${glm}GLM_design.fsf
done
