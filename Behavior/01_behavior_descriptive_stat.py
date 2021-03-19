#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 22 11:07:49 2018

@author: podvae01
"""
import pandas as pd
import numpy as np
import HLTP
from scipy.stats import wilcoxon

#--------- Prepare all behavioral data in a data frame ------------------------
fname = HLTP.group_result + '/behavior/full_behavior.csv'

bhv_df = pd.read_csv(fname)
bhv_df.recognition.replace(0, float('nan'))
bhv_df['correct'] = bhv_df['stim_cat'] == bhv_df['response_cat']
bhv_df['R'] = bhv_df.recognition == 1
bhv_df['U'] = bhv_df.recognition == -1

# Update missing trials for some subjects:
# TODO
bhv_df['fMRI'] = True
bhv_df.loc[(bhv_df.subject == 1) & (bhv_df.trial > (5*24)) & 
           (bhv_df.trial <= (6*24)), 'fMRI'] = False
bhv_df.loc[(bhv_df.subject == 4) & (bhv_df.trial > (11*24)), 'fMRI'] = False 
bhv_df.loc[(bhv_df.subject == 4) & (bhv_df.trial == 24), 'fMRI'] = False 
 
bhv_df.loc[(bhv_df.subject == 11) & (bhv_df.trial > (12*24)) & 
           (bhv_df.trial <= (14*24)), 'fMRI'] = False

bhv_df.loc[(bhv_df.subject == 20) & (bhv_df.trial > (10*24 + 19)) & \
           (bhv_df.trial <= (11*24)), 'fMRI'] = False

bhv_df.loc[(bhv_df.subject == 33) & (bhv_df.trial > (11*24)) & \
           (bhv_df.trial <= (12*24)), 'fMRI'] = False 

# exclude blocks 10,11,13,14
bhv_df.loc[(bhv_df.subject == 37) & (( (bhv_df.trial > (10*24)) & \
           (bhv_df.trial <= (12*24)) ) | ((bhv_df.trial > (13*24)) & \
           (bhv_df.trial <= (15*24)))), 'fMRI'] = False 

# Save the behavior data frame           
bhv_df.to_pickle(HLTP.group_result +'/behavior/bhv_df.pkl')

n_sub = len(bhv_df.subject.unique())

#-------------  proportion recognized images  ---------------------------------
proportion_R = bhv_df.groupby(['real', 'subject'])['R'].mean()

percent_seen_real = 100. * proportion_R.xs(1, level='real'
                                              ).values
percent_seen_scra = 100. * proportion_R.xs(0, level='real'
                                              ).values
print(wilcoxon(percent_seen_real - 50))
print(wilcoxon(percent_seen_real - percent_seen_scra))
print(wilcoxon(percent_seen_scra, alternative = "greater"))

print(wilcoxon(percent_seen_real - 50, alternative = "greater"))
print(wilcoxon(percent_seen_real - percent_seen_scra, alternative = "greater"))
print(wilcoxon(percent_seen_scra, alternative = "greater"))

print('% recognized real:', percent_seen_real.mean(), '+-', \
    percent_seen_real.std() / len(percent_seen_real))
print('% recognized scr:', percent_seen_scra.mean(), '+-', \
    percent_seen_scra.std() / len(percent_seen_scra))

#------------- proportion correct images --------------------------------------

correct_pd_group = bhv_df.groupby(
        ['recognition', 'real', 'subject'])['correct'].mean()

correct_seen = 100. * correct_pd_group.xs((1, 1), 
                                    level=('recognition','real')).values
correct_unseen = 100. * correct_pd_group.xs((-1, 1), 
                                    level=('recognition','real')).values

print(wilcoxon(correct_seen - correct_unseen))
print(wilcoxon(correct_unseen - 25))

print(wilcoxon(correct_seen - correct_unseen, alternative = "greater"))
print(wilcoxon(correct_unseen - 25, alternative = "greater"))

print('% real correct recognized:', correct_seen.mean(), '+-', \
    correct_seen.std() / np.sqrt(len(correct_seen)))
print('% real correct unrecognized:', correct_unseen.mean(), '+-', \
    correct_unseen.std() / np.sqrt(len(correct_unseen)))

n_seen = bhv_df.groupby(['real', 'subject'])['R'].sum()
n_seen_scra = n_seen.xs(0, level='real').values
n_seen_scra_subj = n_seen.xs(0, level='real').index[n_seen_scra <= 5]
s_bhv_dataframe = bhv_df.copy()
for s in n_seen_scra_subj:
    s_bhv_dataframe = s_bhv_dataframe[s_bhv_dataframe.subject != s]
correct_pd_group = s_bhv_dataframe.groupby(
        ['R', 'U', 'real', 'subject'])['correct'].mean()

correct_seen = 100. * correct_pd_group.xs((1, 0), 
                                    level=('R','real')).values

correct_unseen = 100. * correct_pd_group.xs((1, 0), 
                                    level=('U','real')).values
print(wilcoxon(correct_seen - correct_unseen))
print(wilcoxon(correct_seen - 25))
print(wilcoxon(correct_unseen - 25))

print(wilcoxon(correct_seen - correct_unseen, alternative = "greater"))
print(wilcoxon(correct_seen - 25, alternative = "greater"))
print(wilcoxon(correct_unseen - 25, alternative = "greater"))
print('% scr correct recognized:', correct_seen.mean(), '+-', \
    correct_seen.std() / np.sqrt(len(correct_seen)))
print('% scr correct unrecognized:', correct_unseen.mean(), '+-', \
    correct_unseen.std() / np.sqrt(len(correct_unseen)))

m = [percent_seen_real.mean(), percent_seen_scra.mean()]
ste = [percent_seen_real.std(), percent_seen_scra.std()] \
    / np.sqrt(n_sub)
n = len(m)

m = [correct_seen.mean(), correct_unseen.mean()]
ste = [correct_seen.std(), correct_unseen.std()] / np.sqrt(n_sub)

n_categories = 4
cm_mat = {} # dictionary to store confusion matrices
for level in ['R', 'U']:    
    cm_mat[level] = dict((subject, np.zeros((n_categories, n_categories))) 
        for subject in bhv_df.subject.unique())
    for subject in bhv_df.subject.unique():
        data_columns = (bhv_df.subject  == subject) & \
                       (bhv_df[level]   == True) & \
                       (bhv_df.real == True)
        response = bhv_df[data_columns].response_cat.get_values()
        stimulus = bhv_df[data_columns].stim_cat.get_values()
        cm_mat[level][subject] = HLTP.confusion_matrix(stimulus, response)