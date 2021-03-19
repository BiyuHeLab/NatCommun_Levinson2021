#!/bin/sh

# call as sh loc_group_catsel.sh $subjects
# where $subjects is a list of subj numbers like "01 02 03 04"
subjects=$@
#subnums="$(echo -e "${subjects}" | tr -d '[:space:]')"


# Parameters
scripts_dir= # PATH TO SCRIPTS DIRECTORY
. $scripts_dir/directories # point to location of 'directories' file
. $scripts_dir/analysis_parameters

anal_dir="$data_dir/group_results/loc_catsel"
mkdir $anal_dir


copes="13 14 15 16"
conditions=(animal face house object)

data=""
group=""
means=""
meantitles=""
orthos=""
evval1=""
evval2=""
evval3=""

index=0
sub_idx=0
subsarray=($subjects)
num_subs=${#subsarray[@]}

for s in $subjects; do
    ((sub_idx++))
    sub_mean_ev=$(($sub_idx + 3))
    sub_dir="${data_dir}/sub${s}/proc_data/func/loc/loc_categoryGLM.feat/stats"
    for c in $copes; do
        ((index++))
        data="${data}\# 4D AVW data or FEAT directory (${index})NEWLINEset feat_files(${index}) \\\"${sub_dir}/cope${c}.nii.gz\\\"NEWLINE"
	group="${group}\# Group membership for input ${index}NEWLINEset fmri(groupmem\.${index}) 1NEWLINE"

	if (( $c == 13 )); then # if animal cope
	    ev1="1.0"
	    ev2="0"
	    ev3="0"
	elif (( $c == 14 )); then # if face cope
	    ev1="0"
	    ev2="1.0"
	    ev3="0"
	elif (( $c == 15 )); then # if house cope
	    ev1="0"
	    ev2="0"
	    ev3="1.0"
	else # if object cope
            ev1="0"
	    ev2="0"
	    ev3="0"
	fi

        evval1="${evval1}\# Higher-level EV value for EV 1 and input ${index}NEWLINEset fmri(evg${index}\.1) ${ev1}NEWLINE"
        evval2="${evval2}\# Higher-level EV value for EV 2 and input ${index}NEWLINEset fmri(evg${index}\.2) ${ev2}NEWLINE"
        evval3="${evval3}\# Higher-level EV value for EV 3 and input ${index}NEWLINEset fmri(evg${index}\.3) ${ev3}NEWLINE"

	means="${means}set fmri(evg${index}\.${sub_mean_ev}) 1.0NEWLINE"
	for ev in $(seq ${num_subs}); do
	    curr_ev=$(($ev+3))
	    if (( $curr_ev != $sub_mean_ev )); then
		means="${means}set fmri(evg${index}\.${curr_ev}) 0NEWLINE"
	    fi
	done
    done
    meantitles="${meantitles}set fmri(evtitle${sub_mean_ev}) \\\"subj${s}_mean\\\"NEWLINEset fmri(shape${sub_mean_ev}) 2NEWLINEset fmri(convolve${sub_mean_ev}) 0NEWLINEset fmri(convolve_phase${sub_mean_ev}) 0NEWLINEset fmri(tempfilt_yn${sub_mean_ev}) 0NEWLINEset fmri(deriv_yn${sub_mean_ev}) 0NEWLINEset fmri(con_real5.${sub_mean_ev}) 1.0NEWLINEset fmri(con_real6.${sub_mean_ev}) 1.0NEWLINEset fmri(con_real7.${sub_mean_ev}) 1.0NEWLINEset fmri(con_real8.${sub_mean_ev}) 1.0NEWLINE"
done

for i in $(seq ${sub_mean_ev}); do
    orthos="${orthos}set fmri(ortho${i}.0) 0NEWLINE"
    for j in $(seq ${sub_mean_ev}); do
	orthos="${orthos}set fmri(ortho${i}.${j}) 0NEWLINE"
    done
done

cp $scripts_dir/feat_designs/loc_group_catselGLM_design.fsf $anal_dir/loc_group_catselGLM_design.fsf
cd $anal_dir
sed -i -e 's:FEATDATA:'"${data}"':g' loc_group_catselGLM_design.fsf
sed -i -e "s:EVVAL:${evval1}${evval2}${evval3}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:MEANEVS:${means}${meantitles}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:GROUPMEM:${group}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:ORTHOS:${orthos}:g" loc_group_catselGLM_design.fsf
sed -i -e $'s:NEWLINE:\\\n:g' loc_group_catselGLM_design.fsf
sed -i -e "s:FSLDIR:${FSLDIR}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:ANALDIR:${anal_dir}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:NINPUTS:${index}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:NUMEVS:${sub_mean_ev}:g" loc_group_catselGLM_design.fsf
sed -i -e "s:SUBNUMS::g" loc_group_catselGLM_design.fsf # don't enter particular subject numbers in GLM directory name

feat $anal_dir/loc_group_catselGLM_design.fsf
