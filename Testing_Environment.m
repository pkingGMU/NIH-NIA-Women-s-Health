%% Analysis
% Filter Axes data

pre_filter_rot = table2array(subjects.subTest_Subject.Tables.AXES(:,{'Gx','Gy','Gz'}));


%% Interpolation with resampling
original_sample_rate = round(subjects.subTest_Subject.sample_rate);
desired_sample_rate = 50;

resampled_frames_resample = resample(pre_filter_rot, desired_sample_rate, original_sample_rate);



%% Filtering
Fs = 50;

[b, a] = butter(2,3/(Fs/2))
post_filter_rot = filtfilt(b,a,pre_filter_rot);
post_inter= filtfilt(b,a,resampled_frames_interpolate);






%% Testing filter difference
subset = pre_filter_rot(1:10000, :); % Adjust to your data structure
filtered_subset = post_filter_rot(1:10000, :); % Adjust to your data structure
inter_filtered_subset = resampled_frames_interpolate(1:10000, :);
post_inter_subset = post_inter(1:10000, :);
% Plot the original data
figure;
subplot(4,1,1); % Split the plot into 2 rows
plot(subset); % Plot the original subset
title('Original Data (Subset)');
legend('X', 'Y', 'Z');

% Plot the filtered data
subplot(4,1,2);
plot(filtered_subset); % Plot the filtered subset
title('Filtered Data (Subset)');
legend('X', 'Y', 'Z');

% Plot the filtered data
subplot(4,1,3);
plot(inter_filtered_subset); % Plot the filtered subset
title('Interpolated (Subset)');
legend('X', 'Y', 'Z');

% Plot the filtered data
subplot(4,1,4);
plot(post_inter_subset); % Plot the filtered subset
title('Interpolated filtered(Subset)');
legend('X', 'Y', 'Z');



%% Find peaks
lumbar_rotVD1 = vecnorm(post_filter_rot(1:end,:)');

[peak,loc] = findpeaks(lumbar_rotVD1,'MinPeakHeight',40,'MinPeakWidth',30,'MaxPeakWidth',100);%lumbar

%%
lumbar_rotVD1 = lumbar_rotVD1';


%% ENMO (Intensity of movement)
ENMO(subjects.subTest_Subject.Tables.AXES)


%% Get metrics
allmetrics = apply_metrics(subjects.subTest_Subject.Tables.AXES, 50, 5);