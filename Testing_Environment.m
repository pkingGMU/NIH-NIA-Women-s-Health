%% Analysis
% Filter Axes data

pre_filter_rot = table2array(subjects.Hope.Tables.AXES(:,{'Ax','Ay','Az'}));

%%
pre_filter_AXES = table2array(subjects.subHope.Tables.AXES(:,{'Ax', 'Ay', 'Az'}));
pre_filter_AXESnoprocessing = table2array(subjects.subHope.Tablesnoprocessing.AXES(:,{'Ax', 'Ay', 'Az'}));


%% Filtering
Fs = 100;

[b, a] = butter(3,5/(Fs/2));
post_filter_AXES = filtfilt(b,a,pre_filter_AXES);
post_filter_AXESnoprocessing = filtfilt(b,a,pre_filter_AXESnoprocessing);








%% Testing filter difference

frame_end = 30000000;

processed_subset = post_filter_AXES(1:frame_end, :); % Adjust to your data structure
subset = post_filter_AXESnoprocessing(1:frame_end, :); % Adjust to your data structure

% Plot the original data
figure;
subplot(2,1,1); % Split the plot into 2 rows
plot(subset); % Plot the original subset
title('Original Data (Not-Processed)');
legend('X', 'Y', 'Z');

% Plot the filtered data
subplot(2,1,2);
plot(processed_subset); % Plot the filtered subset
title('Processed Data');
legend('X', 'Y', 'Z');




%% Find peaks
lumbar_rotVD1 = vecnorm(post_filter_rot(1:end,:)');

[peak,loc] = findpeaks(lumbar_rotVD1,'MinPeakHeight',40,'MinPeakWidth',30,'MaxPeakWidth',100);%lumbar

%%
lumbar_rotVD1 = lumbar_rotVD1';


%% ENMO (Intensity of movement)
zero_frames = ENMO(subjects.subTest_Subject.Tables.AXES);

%% Zero the data
test_zero = zero(subjects.subTest_Subject.Tables.AXES, zero_frames);

%% Get metrics
allmetrics = apply_metrics(subjects.subTest_Subject.Tables.AXES(:, {'Ax','Ay','Az'}), 50, 5);

%% Find Zero point
