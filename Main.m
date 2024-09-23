%%% MAIN SCRIPT %%%


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



%%

