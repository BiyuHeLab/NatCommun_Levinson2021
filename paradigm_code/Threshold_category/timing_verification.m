% timing verification 
ntrials = 15;
stimulus_onset = data.timing.stimVBL(1:ntrials);
response_screen_onset1 = data.timing.r1VBL(1:ntrials);
response_screen_onset2 = data.timing.r2VBL(1:ntrials);
trial_onset = data.timing.chOnset(1:ntrials);


actual_ITI = round(diff(stimulus_onset));
inter_question_delay = round(response_screen_onset1 - response_screen_onset2);
after_q2_delay = round(trial_onset(2:end) - response_screen_onset1(1:(end - 1)));
pre_stim_interval = round(stimulus_onset - trial_onset);
post_stim_interval = round(response_screen_onset2 - stimulus_onset);




 