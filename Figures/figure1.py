#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 21 10:56:41 2018

@author: podvae01
"""
import pandas as pd
import HLTP
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams

#from nilearn import plotting, surface, datasets
#from nilearn.datasets import load_mni152_template


figures_dir = HLTP.scripts_dir + '/Figures'

colors = {'Rec':np.array([113, 88, 177]) / 255.,#([255, 221, 140]) / 255., 
          'Unr':np.array([191, 238, 51]) / 255.,#([164, 210, 255]) / 255., 
          'All':np.array([.1,.1,.1]),#([174, 236, 131]) / 255.,
          'RecD':np.array([73, 48, 137]) / 255.,#([255, 147, 0]) / 255., 
          'UnrD':np.array([141, 188, 1]) / 255.,#([4, 51, 255]) / 255., 
          'AllL':np.array([195, 250, 160]) / 255.,
          'AllD':np.array([127, 202, 96]) / 255.,
          'AllDD':np.array([53, 120, 33]) / 255.,
          'sens':np.array([244, 170, 59]) / 255.,
          'bias':np.array([130, 65, 252]) / 255.    }
colors = {'Rec':np.array([118, 106, 218]) / 255.,#([255, 221, 140]) / 255., 
          'Unr':np.array([122, 184, 99]) / 255.,#([164, 210, 255]) / 255.,  
          'RecD':np.array([118, 106, 218] )* 0.8 / 255.,#([255, 147, 0]) / 255., 
          'UnrD':np.array([122, 184, 99])* 0.8 / 255.#([4, 51, 255]) / 255.
           }
 
fig_width = 7  # width in inches
fig_height = 4.2  # height in inches
fig_size =  [fig_width,fig_height]
params = {    
          'axes.spines.right': False,
          'axes.spines.top': False,
          
          'figure.figsize': fig_size,
          
          'ytick.major.size' : 8,      # major tick size in points
          'xtick.major.size' : 8,    # major tick size in points
              
          'lines.markersize': 6.0,
          # font size
          'axes.labelsize': 14,
          'axes.titlesize': 14,     
          'xtick.labelsize': 12,
          'ytick.labelsize': 12,
          'font.size': 12,

          # linewidth
          'axes.linewidth' : 1.3,
          'patch.linewidth': 1.3,
          
          'ytick.major.width': 1.3,
          'xtick.major.width': 1.3,
          'savefig.dpi' : 800
          }
rcParams.update(params)
rcParams['font.sans-serif'] = 'Helvetica'

#------------------- BEHAVIOR -------------------------------------------------

def print_figure_1F():
    ''' Percent Recognized in real and scrambled trials'''
    
    bhv_df = pd.read_pickle(HLTP.figures_dir +'/source_data/bhv_df.pkl')
    # Subjective Recognition rate
    proportion_R = bhv_df.groupby(['real', 'subject'])['R'].mean()
    percent_seen_real = 100. * proportion_R.xs(1, level='real').values
    percent_seen_scra = 100. * proportion_R.xs(0, level='real').values
    
    data= [percent_seen_real, percent_seen_scra]
    fig, ax = plt.subplots(1, 1, figsize = (1.4, 2.5))
    
    ax.spines['left'].set_position(('outward', 10))
    ax.yaxis.set_ticks_position('left')
    ax.spines['bottom'].set_position(('outward', 15))
    ax.xaxis.set_ticks_position('bottom')
    box1 = plt.boxplot(data, positions = [0,1], patch_artist = True, 
                       widths = 0.8,showfliers=False,
             boxprops=None,    showbox=None,     whis = 0, showcaps = False)
    
    box1['boxes'][0].set( facecolor = [.9,.9,.9], lw=0, zorder=0)
    box1['boxes'][1].set( facecolor = [.9,.9,.9], lw=0, zorder=0)
    
    box1['medians'][0].set( color = [.4,.4,.4], lw=2, zorder=20)
    box1['medians'][1].set( color =  [.4,.4,.4], lw=2, zorder=20)

    plt.plot([-0.5,1.5], [50, 50], '--k')
    
    plt.plot([0, 1], [percent_seen_real, percent_seen_scra], 
             color = [.5, .5, .5], lw = 0.5);
    plt.plot([0], [percent_seen_real], 'o', 
             markerfacecolor = 'k', color = 'k', 
             alpha = 1.);    
    plt.plot([1], [percent_seen_scra], 'o',
             markerfacecolor = [.9, .9, .9], color = 'k', alpha = 1.);          

    plt.xticks(range(2), ['Real', 'Scram'], rotation = 0, fontsize=13)
    plt.locator_params(axis='y', nbins=6)
    #ax.set_xticks( (-0., 1.))
    ax.set_xlim([0., 1.]);
    plt.xlabel('Image'); plt.ylabel('% Recognized')
    plt.ylim([-0.01, 100]);plt.xlim([-.45, 1.45]);
 
    props = {'connectionstyle':'bar','arrowstyle':'-',\
                     'shrinkA':5,'shrinkB':5}
    mx = percent_seen_real.max() + 5
    ax.annotate('***', xy=(0.5, mx + 10), zorder=10, ha = 'center')
    ax.annotate('', xy=(0, mx), xytext=(1, mx), arrowprops=props)
    
    fig.savefig(figures_dir + '/PercentRecognized_pair.png', 
                bbox_inches = 'tight', transparent=True)


def print_figure_1G():
    '''Percent correct category reports by trial type
    real/scrambled and recognized/unrecognized'''
    # Objective categorization accuracy
    correct_pd_group = bhv_df.groupby(['recognition', 'real', 'subject'
                                   ])['correct'].mean()

    correct_R_real = 100. * correct_pd_group.xs((1, 1), 
                                    level=('recognition','real')).values

    correct_U_real = 100. * correct_pd_group.xs((-1, 1), 
                                    level=('recognition','real')).values

    correct_R_scra = 100. * correct_pd_group.xs((1, 0), 
                                    level=('recognition','real')).values

    correct_U_scra = 100. * correct_pd_group.xs((-1, 0), 
                                    level=('recognition','real')).values
    
    n_seen = bhv_df.groupby(['real', 'subject'])['R'].sum()
    n_seen_scra = n_seen.xs(0, level='real').values
    correct_R_scra = correct_R_scra[n_seen_scra > 5]
    correct_U_scra = correct_U_scra[n_seen_scra > 5]
    xdata = [0, 1, 2.5, 3.5]
    data = [correct_R_real, correct_U_real, 
         correct_R_scra, correct_U_scra]
    fig, ax = plt.subplots(1, 1,figsize = (2.5, 2.5))
    ax.spines['left'].set_position(('outward', 10))
    ax.yaxis.set_ticks_position('left')
    ax.spines['bottom'].set_position(('outward', 15))
    ax.xaxis.set_ticks_position('bottom')
    box1 = plt.boxplot(data, positions = xdata, patch_artist = True, widths = 0.8,
             showfliers = False, boxprops = None, showbox = None, 
             whis = 0, showcaps = False)
    box1['boxes'][0].set( facecolor = colors['Rec']*1.15, lw=0, zorder=0)    
    box1['boxes'][1].set( facecolor = colors['Unr']*1.2, lw=0, zorder=0)    
    box1['boxes'][2].set( facecolor = [.9,.9,.9], lw=0, zorder=0)    
    box1['boxes'][3].set( facecolor = [.9,.9,.9], lw=0, zorder=0)    

    box1['medians'][0].set( color = colors['RecD'], lw=2, zorder=20)
    box1['medians'][1].set( color = colors['UnrD'], lw=2, zorder=20)
    box1['medians'][2].set( color = colors['RecD'], lw=2, zorder=20)
    box1['medians'][3].set( color = colors['UnrD'], lw=2, zorder=20)

    plt.plot(xdata[:2], [correct_R_real, correct_U_real],color = [.5,.5,.5], lw = 0.5);
    plt.plot(xdata[2:], [correct_R_scra, correct_U_scra],color = [.5,.5,.5], lw = 0.5);       
    plt.plot([-0.5,4], [25, 25], '--k')

    plt.plot(xdata[0], [correct_R_real], 'o', alpha = 0.9,
             markerfacecolor = colors['Rec'], color = colors['RecD']);    
    plt.plot(xdata[1], [correct_U_real], 'o', alpha = 0.9,
             markerfacecolor = colors['Unr'], color = colors['UnrD']);
    plt.plot(xdata[2], [correct_R_scra], 'o', alpha = 0.9,
             markerfacecolor = [.9,.9,.9], color = colors['RecD']);    
    plt.plot(xdata[3], [correct_U_scra], 'o',alpha = 0.9,
             markerfacecolor = [.9,.9,.9], color = colors['UnrD']);         
    
    plt.xticks(xdata, ['Y', 'N', 'Y', 'N'])
    plt.xlabel('Recognition')
    plt.ylabel('% Correct')
    plt.ylim([0, 100]); plt.xlim([-0.5, 4.]);
    plt.locator_params(axis='y', nbins=5)

    props = {'connectionstyle':'bar','arrowstyle':'-',\
                     'shrinkA':4,'shrinkB':4}
    mx = correct_R_real.max() - 10
    ax.annotate('***', xy=(0.5, mx +7), zorder=10, ha = 'center')
    ax.annotate('', xy=(0, mx), xytext=(1, mx), arrowprops=props)
    
    ax.annotate('***', xy=(3., mx +7), zorder=10, ha = 'center')
    ax.annotate('', xy=(2.5, mx), xytext=(3.5, mx), arrowprops=props)
    fig.savefig(figures_dir + '/PercentCorrect_pair.png', dpi=800, 
                transparent=True, bbox_inches = 'tight')