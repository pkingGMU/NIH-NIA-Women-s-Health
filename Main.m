%%% MAIN SCRIPT %%%
% Main program allows you select a subject with a CWA.

%%% Local Imports
% Add function folder to search path
addpath(genpath('Functions'))

% Select directory
folder = uigetdir();

%%
% Return a list of subjects to import into process
subjects_list = arrange_subjects(folder);

%%


% This function will return cwa_data under subjects

subjects = process(subjects_list);



%% Get axes data

axes = subjects.subTest_Subject.cwa_data.AXES;

