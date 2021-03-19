#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 15 15:16:05 2018

@author: podvae01
"""
import numpy as np
import random
import re
from nipype.interfaces import fsl 
import pickle
import socket
import scipy
from scipy import stats
# if doesnt work, run the lines below in terminal and restart spyder
"""
FSLDIR=/usr/local/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
"""

data_dir = '' # main data directory
scripts_dir = '' # scripts directory
group_result = data_dir + '/group_results'
bhv_data_file = group_result +'/behavior/bhv_df.pkl'

subjects = [1,  4,  5,  7,  8,  9, 11, 13, 15, 16, 18, 19, 20, 22, 25, 26, 29,
       30, 31, 32, 33, 34, 35, 37, 38]

random.seed(100)

n_tr_in_block = 227 # note few blocks are missing/ended early

category_id = { "face": 1, "house": 2, "object": 3, "animal": 4}
recognition_id = { "R": 1, "U": -1}

#----- Figures paramters ------------------------------------------------------
hfont = {'fontname':'sans-serif'}

#----- Helper functions -------------------------------------------------------

def save(var, file_name):
    outfile = open(file_name, 'wb')          
    pickle.dump(var, outfile)
    outfile.close()
    
def load(file_name):
    outfile = open(file_name, 'rb')          
    var = pickle.load(outfile)
    outfile.close()
    return var

def get_block_numbers(sub):
    subdir = data_dir + '/sub' + "%02d" % sub
    param_file = subdir + '/sub_params'
    
    lines = []                 
    with open (param_file, 'r+') as in_file:  
        for line in in_file: 
            lines.append(line.rstrip('\n')) 
    for line in lines:
        if line.find("good_blocks") >=0 :
            break;
    return [int(s) for s in re.findall(r'\b\d+\b', line)]


def get_bhv_vars(df):
    n_rec_real = sum(df[df.real == True].recognition == 1)
    n_real = len(df[(df.real == True) & (df.recognition != 0)])
    n_rec_scr = sum(df[df.real == False].recognition == 1)
    n_scr = len(df[(df.real == False) & (df.recognition != 0)])
    p_correct = df.correct.values.mean()   
    catRT =  df.catRT.values.mean()
    recRT =  df.recRT.values.mean()
    HR, FAR, d, c = get_sdt_msr(n_rec_real, n_real, n_rec_scr, n_scr)
    return HR, FAR, d, c, p_correct, catRT, recRT