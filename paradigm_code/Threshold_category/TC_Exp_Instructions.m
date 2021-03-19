% NSTRUCTIONS FOR EXPERIMENTER

% setup the camera and calibrate
cd ExperimentDirectory
addpath(genpath(pwd))

% Day 1
TC_rest % run number 1
TC_localizer
load localizer_parameters
ret(params)
TC_threshold


% Day 2
TC_rest % run number 2
TC_main