%% Analysis
% Filter Axes data

pre_filter_rot = table2array(subjects.subTest_Subject.Tables.AXES(:,{'Gx','Gy','Gz'}));


%% Filtering
Fs = 50;

[b, a] = butter(2,3/(Fs/2))
post_filter_rot = filtfilt(b,a,pre_filter_rot);







%% Testing filter difference

frame_end = 30000;

subset = pre_filter_rot(1:frame_end, :); % Adjust to your data structure
filtered_subset = post_filter_rot(1:frame_end, :); % Adjust to your data structure

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


%% ENMO (Intensity of movement)
ENMO(subjects.subTest_Subject.Tables.AXES)


%% Get metrics
allmetrics = apply_metrics(subjects.subTest_Subject.Tables.AXES(:, {'Ax','Ay','Az'}), 50, 5);

%% Find Zero point
