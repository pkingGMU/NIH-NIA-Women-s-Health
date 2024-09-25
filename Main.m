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


%% Analysis
% Filter Axes data

pre_filter_rot = table2array(subjects.subAmanda_Pilot.Tables.AXES(:,{'Gx','Gy','Gz'}));


%% Filtering
Fs = 100;

[b, a] = butter(2,1/(Fs/2))
post_filter_rot = filtfilt(b,a,pre_filter_rot);

%% Testing filter difference
subset = pre_filter_rot(1:10000, :); % Adjust to your data structure
filtered_subset = post_filter_rot(1:10000, :); % Adjust to your data structure
% Plot the original data
figure;
subplot(2,1,1); % Split the plot into 2 rows
plot(subset); % Plot the original subset
title('Original Data (Subset)');
legend('X', 'Y', 'Z');

% Plot the filtered data
subplot(2,1,2);
plot(filtered_subset); % Plot the filtered subset
title('Filtered Data (Subset)');
legend('X', 'Y', 'Z');


%% Find peaks
lumbar_rotVD1 = vecnorm(post_filter_rot(1:end,:)');

[peak,loc] = findpeaks(lumbar_rotVD1,'MinPeakHeight',40,'MinPeakWidth',30,'MaxPeakWidth',100);%lumbar

%%
lumbar_rotVD1 = lumbar_rotVD1';


