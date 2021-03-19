# HLTP
# Linear mixed model of category decoding accuracy
# Predictors: cortical/subcortical, number of voxels

# Load packages
library(xlsx)
library(lme4)
library(sjPlot)
library(optimx)


# load data
scripts_dir <- "" # PATH TO SCRIPTS DIRECTORY
setwd(scripts_dir)
df <- read.xlsx(paste(scripts_dir, "/Figures/source_data/Source Data.xls", sep=""), sheetIndex=16, header=TRUE)
names(df)[4] <- "Voxel_count"
names(df)[5] <- "Recognized_decoding_accuracy"
names(df)[6] <- "Unrecognized_decoding_accuracy"
df$Recognized_decoding_accuracy <- asin(sqrt(df$Recognized_decoding_accuracy / 100)) # angular transformation to improve model fitting
df$Unrecognized_decoding_accuracy <- asin(sqrt(df$Unrecognized_decoding_accuracy / 100))
df$Voxel_count <- df$Voxel_count / 1000 # scale predictor to similar order of magnitude as predicted data
df$Voxel_count <- df$Voxel_count - mean(df$Voxel_count) # zero-mean

# run maximally-structured linear mixed model
lm0 = lmer(Recognized_decoding_accuracy ~ (1 + factor(Cortical) + Voxel_count + factor(Cortical):Voxel_count | Subject) + 1 + factor(Cortical) + Voxel_count
             + Voxel_count:factor(Cortical), df, control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4)))

# view results
summary(lm0)
tab_model(lm0, show.se = TRUE, show.loglik = TRUE, dv.labels = "", title = "Linear mixed model: Recognized category decoding accuracy")








