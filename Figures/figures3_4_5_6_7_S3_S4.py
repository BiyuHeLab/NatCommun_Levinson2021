# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
from scipy.io import loadmat
import matplotlib.pyplot as plt
from scipy.stats import linregress
import numpy as np
from matplotlib import rcParams
import HLTP

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

colors = {'Rec':np.array([118, 106, 218]) / 255.,#([255, 221, 140]) / 255., 
          'Unr':np.array([122, 184, 99]) / 255.,#([164, 210, 255]) / 255.,  
          }
scr_fill_color = np.array([.85, .85, .85])
scr_edge_color = np.array([0.3, 0.3, 0.3])
red_circle_color = np.array([0.75, 0.2, 0.2])
 
figures_dir = HLTP.scripts_dir + '/Figures'

###### PLOT FIGURE 3 ###################################################
datafile = figures_dir + \
    '/source_data/fig3bdata_percentchange.mat'
          
dt = loadmat(datafile)

betas = dt['fig3bdataraw']['mean'][0][0]
ste = dt['fig3bdataraw']['stderr'][0][0]
roi_names = dt['fig3bdataraw']['roi_names'][0][0][0]
roi_names = np.array([r[0] for r in roi_names])
n_roi = len(betas[:, 1])
sb = np.argsort(betas[:, 0])

xa = 1+np.arange(n_roi)
fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa, betas[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = colors['Rec'], mec = 'none',
             capsize=4, ms = 15)
plt.errorbar(xa, betas[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = colors['Unr'],mec = 'none', 
             capsize=4, ms = 15)

plt.xlim([0, n_roi+2]); plt.ylim([-2., 2.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--')

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
for i, tic in enumerate(plt.gca().get_xticklabels()):
    if i > 9: tic.set_color(np.array([204., 102., 0.])/255) 
    else: tic.set_color(np.array([0., 26., 204.])/255) 
fig.savefig(figures_dir + '/RU_ROI_Uni', 
            dpi=800, transparent=True)


##### FIGURE 4 ########################################s##################

datafile = figures_dir + \
    '/source_data/category_decoding.mat'
           
dt = loadmat(datafile)

accuracy = dt['category_decoding']['ru_rois'][0][0][0][0][1][:, :2]
ste = dt['category_decoding']['ru_rois'][0][0][0][0][2][:, :2]
roi_names =  dt['category_decoding']['ru_rois'][0][0][0][0][5][0]
roi_names = np.array([r[0] for r in roi_names])
sig_diff = np.squeeze(
    dt['category_decoding']['ru_rois'][0][0]['ru_sig_fdr_permtest'][0][0])
sig_diff_to_plot = np.array([sig_diff[s] for s in sb])
sig_diff_roi = np.where(sig_diff_to_plot)[0]
sig_rec = np.squeeze(
    dt['category_decoding']['ru_rois'][0][0]['indiv_p_sig_fdr'][0][0][0])
sig_rec_to_plot = np.array([sig_rec[s] for s in sb])
sig_rec_roi = np.where(sig_rec_to_plot)[0]
sig_unrec = np.squeeze(
    dt['category_decoding']['ru_rois'][0][0]['indiv_p_sig_fdr'][0][0][1])
sig_unrec_to_plot = np.array([sig_unrec[s] for s in sb])
sig_unrec_roi = np.where(sig_unrec_to_plot)[0]

fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa, accuracy[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = colors['Rec'], mec = 'none',
             capsize=4, ms = 15, zorder = 1)
plt.plot(xa[sig_rec_roi], accuracy[:, 0][sb[sig_rec_roi]],
             'o', mec = colors['Rec'], mfc = 'none', ms = 10, mew = 1, zorder = 2)
plt.errorbar(xa, accuracy[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = colors['Unr'],mec = 'none', 
             capsize=4, ms = 15, zorder = 3)

plt.hlines(25, 1, n_roi, ls = '--', zorder = 0)
plt.xlim([0, n_roi+2]); plt.ylim([20., 45.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_diff_roi:
    ax.axvline(n, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)    
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
ax.tick_params(bottom = False)
xx = plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('accuracy (%)')
plt.tight_layout()

for i, tic in enumerate(plt.gca().get_xticklabels()):
    if i > 9: tic.set_color(np.array([204., 102., 0.])/255) 
    else: tic.set_color(np.array([0., 26., 204.])/255) 
fig.savefig(figures_dir + '/RU_ROI_MVPA', 
            dpi=800, transparent=True)



######## FIGURE 7A ##########################
datafile = figures_dir + \
    '/source_data/glm_percent_change.mat'
          
dt = loadmat(datafile, struct_as_record=False)

betas = np.array(dt['glm_percent_change'][0][0].ru_rois[0][0].mean[:, 2:4])
ste = np.array(dt['glm_percent_change'][0][0].ru_rois[0][0].stderr[:, 2:4])

sig_diff = dt['glm_percent_change'][0][0].ru_rois[0][0].scr_ru_sig_fdr[0]
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa, betas[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = scr_fill_color, mec = colors['Rec'],
             capsize=4, ms = 14)
plt.errorbar(xa, betas[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = scr_fill_color, mec = colors['Unr'], 
             capsize=4, ms = 14)

plt.xlim([0, n_roi+2]); plt.ylim([-2., 3]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_roi:
    ax.axvline(n, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)  
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--', zorder = 0)

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
for i, tic in enumerate(plt.gca().get_xticklabels()):
    if i > 9: tic.set_color(np.array([204., 102., 0.])/255) 
    else: tic.set_color(np.array([0., 26., 204.])/255) 
fig.savefig(figures_dir + '/RU_ROI_Uni_scr', 
            dpi=800, transparent=True)


######### FIGURE S4B ##########################################
datafile = figures_dir + \
    '/source_data/glm_percent_change.mat'
          
dt = loadmat(datafile, struct_as_record=False)

betas = np.array([dt['glm_percent_change'][0][0].ru_rois[0][0].ru_differences[0][0].ru_real_diff_mean[0], dt['glm_percent_change'][0][0].ru_rois[0][0].ru_differences[0][0].ru_scr_diff_mean[0]])
betas = betas.T
ste = np.array([dt['glm_percent_change'][0][0].ru_rois[0][0].ru_differences[0][0].ru_real_diff_stderr[0], dt['glm_percent_change'][0][0].ru_rois[0][0].ru_differences[0][0].ru_scr_diff_stderr[0]])
ste = ste.T

fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa, betas[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=scr_edge_color, mfc = scr_edge_color, mec = scr_edge_color,
             capsize=4, ms = 14)
plt.errorbar(xa, betas[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=scr_edge_color, mfc = scr_fill_color, mec = scr_edge_color, 
             capsize=4, ms = 14)

plt.xlim([0, n_roi+2]); plt.ylim([-2., 2.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--', zorder = 0)

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
for i, tic in enumerate(plt.gca().get_xticklabels()):
    if i > 9: tic.set_color(np.array([204., 102., 0.])/255) 
    else: tic.set_color(np.array([0., 26., 204.])/255) 
fig.savefig(figures_dir + '/RU_ROI_Uni_diffs_realscr', 
            dpi=800, transparent=True)


######### FIGURE 7C ###########################################
datafile = figures_dir + \
    '/source_data/category_decoding.mat'
           
dt = loadmat(datafile)

accuracy = dt['category_decoding']['ru_rois'][0][0][0][0][1][:, 2]
ste = dt['category_decoding']['ru_rois'][0][0][0][0][2][:, 2]
sig_diff = dt['category_decoding']['ru_rois'][0][0]['indiv_p_sig_fdr'][0][0][2, :]
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa, accuracy[sb], ste[sb], 
             fmt='.', ecolor=scr_edge_color, mfc = scr_fill_color, mec = scr_edge_color,
             capsize=4, ms = 14, zorder = 1)

plt.hlines(25, 1, n_roi, ls = '--', zorder = 0)
plt.xlim([0, n_roi+2]); plt.ylim([20., 45.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
plt.plot(xa[sig_roi], accuracy[sb[sig_roi]],
         'o', mec = scr_edge_color, mfc = 'none', ms = 11, mew = 1, zorder = 2)
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
ax.tick_params(bottom = False)
xx = plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('accuracy (%)')
plt.tight_layout()

for i, tic in enumerate(plt.gca().get_xticklabels()):
    if i > 9: tic.set_color(np.array([204., 102., 0.])/255) 
    else: tic.set_color(np.array([0., 26., 204.])/255) 
fig.savefig(figures_dir + '/RU_ROI_MVPA_scr', 
            dpi=800, transparent=True)

######## PLOT FIGURE 5 ########################################
## B ##
datafile = figures_dir + \
    '/source_data/glm_percent_change.mat'
          
dt = loadmat(datafile, struct_as_record=False)

betas = np.array([[dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].roi_merged_mR[0][0], dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].roi_merged_mU[0][0]], [dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].roi_merged_mR[0][0], dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].roi_merged_mU[0][0]]])
ste = np.array([[dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].roi_merged_sR[0][0], dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].roi_merged_sU[0][0]], [dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].roi_merged_sR[0][0], dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].roi_merged_sU[0][0]]])


roi_names = np.array(['EVC', 'VTC'])
n_roi = len(betas[:, 1])
sb = np.array([0, 1])

sig_diff = np.array([1, 0])
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

xa = 1+np.arange(n_roi)
fig, ax = plt.subplots(1, 1, figsize = (2.4, 3.5))

plt.errorbar(xa, betas[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = colors['Rec'], mec = 'none',
             capsize=4, ms = 15)
plt.errorbar(xa, betas[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = colors['Unr'],mec = 'none', 
             capsize=4, ms = 15)

plt.xlim([0, n_roi+2]); plt.ylim([0., 2.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_roi:
    ax.axvline(n, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)    
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--', zorder = 0)

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
fig.savefig(figures_dir + '/EVC_VTC_Uni', 
            dpi=800, transparent=True)

## C ##
datafile = figures_dir + \
    '/source_data/category_decoding.mat'
           
dt = loadmat(datafile, struct_as_record=False)

accuracy = np.array([dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].evc[0][0].mean[0][0:2], dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].vtc[0][0].mean[0][0:2]])
ste = np.array([dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].evc[0][0].stderr[0][0:2], dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].vtc[0][0].stderr[0][0:2]])
sig_diff = np.array([0, 1])
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

fig, ax = plt.subplots(1, 1, figsize = (2.4, 3.5))

plt.errorbar(xa, accuracy[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = colors['Rec'], mec = 'none',
             capsize=4, ms = 15)
plt.errorbar(xa, accuracy[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = colors['Unr'],mec = 'none', 
             capsize=4, ms = 15)

plt.hlines(25, 1, n_roi, ls = '--', zorder = 0)
plt.xlim([0, n_roi+2]); plt.ylim([20., 45.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_roi:
    ax.axvline(n, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)    
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
ax.tick_params(bottom = False)
xx = plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('accuracy (%)')
plt.tight_layout()

fig.savefig(figures_dir + '/EVC_VTC_MVPA', 
            dpi=800, transparent=True)


###### FIGURE 7B #############################
datafile = figures_dir + \
    '/source_data/glm_percent_change.mat'
          
dt = loadmat(datafile, struct_as_record=False)

betas = np.array([[dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].roi_merged_mR[0][0], dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].roi_merged_mU[0][0]], [dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].roi_merged_mR[0][0], dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].roi_merged_mU[0][0]]])
ste = np.array([[dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].roi_merged_sR[0][0], dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].roi_merged_sU[0][0]], [dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].roi_merged_sR[0][0], dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].roi_merged_sU[0][0]]])

sig_diff = np.array([0, 0])
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

xa = 1+np.arange(n_roi)
fig, ax = plt.subplots(1, 1, figsize = (2.4, 3.5))

plt.errorbar(xa, betas[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = scr_fill_color, mec = colors['Rec'],
             capsize=4, ms = 14)
plt.errorbar(xa, betas[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = scr_fill_color, mec = colors['Unr'], 
             capsize=4, ms = 14)

plt.xlim([0, n_roi+2]); plt.ylim([0., 2.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_roi:
    ax.axvline(n, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)    
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--', zorder = 0)

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
fig.savefig(figures_dir + '/EVC_VTC_Uni_scr', 
            dpi=800, transparent=True)


######## FIGURE 7D ###########################
datafile = figures_dir + \
    '/source_data/category_decoding.mat'
           
dt = loadmat(datafile, struct_as_record=False)

accuracy = np.array([dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].evc[0][0].mean[0][2], dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].vtc[0][0].mean[0][2]])
ste = np.array([dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].evc[0][0].stderr[0][2], dt['category_decoding'][0][0].evc_vtc_controlnumvoxels[0][0].vtc[0][0].stderr[0][2]])
sig_diff = np.array([1, 1])
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

fig, ax = plt.subplots(1, 1, figsize = (2.4, 3.5))

plt.errorbar(xa, accuracy[sb], ste[sb], 
             fmt='.', ecolor=scr_edge_color, mfc = scr_fill_color, mec = scr_edge_color,
             capsize=4, ms = 14, zorder = 1)

plt.hlines(25, 1, n_roi, ls = '--', zorder = 0)
plt.xlim([0, n_roi+2]); plt.ylim([20., 45.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)   
plt.plot(xa[sig_roi], accuracy[sb[sig_roi]],
         'o', mec = scr_edge_color, mfc = 'none', ms = 11, mew = 1, zorder = 2)
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
ax.tick_params(bottom = False)
xx = plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('accuracy (%)')
plt.tight_layout()

fig.savefig(figures_dir + '/EVC_VTC_MVPA_scr', 
            dpi=800, transparent=True)


######## FIGURE S3A ##########################
datafile = figures_dir + \
    '/source_data/glm_percent_change.mat'
          
dt = loadmat(datafile, struct_as_record=False)

betas = np.array([dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].nolr_merged_mR[0], dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].nolr_merged_mU[0], dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].nolr_merged_mR[0], dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].nolr_merged_mU[0], dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].merged_mR[0], dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].merged_mU[0], dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].merged_mR[0], dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].merged_mU[0]])
ste = np.array([dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].nolr_merged_sR[0], dt['glm_percent_change'][0][0].retinotopy[0][0].real[0][0].nolr_merged_sU[0], dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].nolr_merged_sR[0], dt['glm_percent_change'][0][0].retinotopy[0][0].scr[0][0].nolr_merged_sU[0], dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].merged_sR[0], dt['glm_percent_change'][0][0].localizer[0][0].real[0][0].merged_sU[0], dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].merged_sR[0], dt['glm_percent_change'][0][0].localizer[0][0].scr[0][0].merged_sU[0]])

sb = np.array([0, 1, 2, 3, 4, 5, 6, 7])
sig_diff = np.array([1, 0, 0, 0, 0, 0, 0, 0]) # real only: nothing sig in scr. FDR corrected across 8 ROIs.
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

roi_names = np.array(['V1', 'V2', 'V3', 'V4', 'animal', 'face', 'house', 'object'])
n_roi = len(betas[:, 1])
xa = 1+np.arange(n_roi)
fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa-0.2, betas[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = colors['Rec'], mec = 'none',
             capsize=4, ms = 15)
plt.errorbar(xa-0.2, betas[:, 1][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = colors['Unr'],mec = 'none', 
             capsize=4, ms = 15)
plt.errorbar(xa+0.2, betas[:, 2][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = scr_fill_color, mec = colors['Rec'],
             capsize=4, ms = 14)
plt.errorbar(xa+0.2, betas[:, 3][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = scr_fill_color, mec = colors['Unr'], 
             capsize=4, ms = 14)

plt.xlim([0, n_roi+2]); plt.ylim([-0.5, 2.5]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_roi:
    ax.axvline(n-0.2, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)    
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--', zorder = 0)

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
fig.savefig(figures_dir + '/all_visual_Uni_realscr', 
            dpi=800, transparent=True)


####### FIGURE S3B ###########################
datafile = figures_dir + \
    '/source_data/category_decoding.mat'
           
dt = loadmat(datafile, struct_as_record=False)

accuracy = np.array([dt['category_decoding'][0][0].retinotopy[0][0].nolr_mean, dt['category_decoding'][0][0].localizer[0][0].mean])
accuracy = accuracy.reshape(8, 3)
ste = np.array([dt['category_decoding'][0][0].retinotopy[0][0].nolr_stderr, dt['category_decoding'][0][0].localizer[0][0].stderr])
ste = ste.reshape(8, 3)
sig_diff = np.array([0, 0, 0, 1, 1, 1, 1, 1])
sig_to_plot = np.array([sig_diff[s] for s in sb])
sig_roi = np.where(sig_to_plot)[0]

fig, ax = plt.subplots(1, 1, figsize = (6.4, 3.5))

plt.errorbar(xa-0.2, accuracy[:, 0][sb], ste[:, 0][sb], 
             fmt='.', ecolor=colors['Rec'], mfc = colors['Rec'], mec = 'none',
             capsize=4, ms = 15)
plt.errorbar(xa-0.2, accuracy[:, 2][sb], ste[:, 1][sb], 
             fmt='.', ecolor=colors['Unr'], mfc = colors['Unr'],mec = 'none', 
             capsize=4, ms = 15)
plt.errorbar(xa+0.2, accuracy[:, 1][sb], ste[:, 0][sb],
              fmt='.', ecolor=scr_edge_color, mfc = scr_fill_color, mec = scr_edge_color,
              capsize=4, ms = 14)

plt.hlines(25, 1, n_roi, ls = '--', zorder = 0)
plt.xlim([0, n_roi+2]); plt.ylim([20., 45.]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
for n in 1 + sig_roi:
    ax.axvline(n-0.2, -1, n_roi, ls = '-', color = np.array([255., 251., 0.])/255, lw = 10, alpha = .3, zorder = 0)    
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
ax.tick_params(bottom = False)
xx = plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('accuracy (%)')
plt.tight_layout()

fig.savefig(figures_dir + '/all_visual_MVPA_realscr', 
            dpi=800, transparent=True)



####### FIGURE 6 #############################
datafile = figures_dir + \
    '/source_data/glm_percent_change.mat'
          
dt = loadmat(datafile, struct_as_record=False)
roi_select = np.array([3, 6, 8, 10, 12, 13, 14])

betas = np.array([dt['glm_percent_change'][0][0].realscr_rois[0][0].real[0][0].merged_norec_m[0], dt['glm_percent_change'][0][0].realscr_rois[0][0].scr[0][0].merged_norec_m[0]])
betas = betas.T[roi_select, :]
ste = np.array([dt['glm_percent_change'][0][0].realscr_rois[0][0].real[0][0].merged_norec_s[0], dt['glm_percent_change'][0][0].realscr_rois[0][0].scr[0][0].merged_norec_s[0]])
ste = ste.T[roi_select, :]

roi_names = dt['glm_percent_change'][0][0].realscr_rois[0][0].roi_names[0]
roi_names = np.array([r[0] for r in roi_names[roi_select]])
n_roi = len(betas[:, 1])
sb = np.argsort(betas[:, 0])

xa = 1+np.arange(n_roi)
fig, ax = plt.subplots(1, 1, figsize = (5.4, 3.5))

plt.errorbar(xa, betas[:, 0][sb], ste[:, 0][sb], 
              fmt='.', ecolor=scr_edge_color, mfc = scr_edge_color, mec = scr_edge_color,
              capsize=4, ms = 13)
plt.errorbar(xa, betas[:, 1][sb], ste[:, 1][sb], 
              fmt='.', ecolor=scr_edge_color, mfc = scr_fill_color, mec = scr_edge_color, 
              capsize=4, ms = 13)

plt.xlim([0, n_roi+2]); plt.ylim([-2., 3]);
for n in range(1, n_roi+1):
    ax.axvline(n, -1, n_roi, ls = ':', color = 'k', alpha = .5, zorder = 0)
ax.spines['left'].set_position(('outward', 10))
ax.yaxis.set_ticks_position('left')
ax.spines['bottom'].set_visible( False)
plt.hlines(0, 1, n_roi, ls = '--', zorder = 0)

ax.tick_params(bottom = False)
plt.xticks(1+np.arange(n_roi), roi_names[sb], rotation = 'vertical')
plt.ylabel('% signal change')
plt.tight_layout()
for i, tic in enumerate(plt.gca().get_xticklabels()):
    if i < 5: tic.set_color(np.array([204., 102., 0.])/255) 
    else: tic.set_color(np.array([0., 26., 204.])/255) 
fig.savefig(figures_dir + '/realscr_ROI_Uni', 
            dpi=800, transparent=True)

