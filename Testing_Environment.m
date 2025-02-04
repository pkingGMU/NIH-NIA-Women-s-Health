%% Analysis
% Filter Axes data

pre_filter_rot = table2array(subjects.Hope.Tables.AXES(:,{'Ax','Ay','Az'}));

%%
pre_filter_AXES = table2array(subjects.subHope.Tables.AXES(:,{'Ax', 'Ay', 'Az'}));
non_active_frames = subjects.subHope.Tables.Stationary(:,1);

%active_data = pre_filter_AXES(~non_active_frames,:);
active_data = pre_filter_AXES(~ismember(1:size(pre_filter_AXES, 1), non_active_frames), :);

%%
% Parameters
window_size = 100;  % Size of the moving window
windowed_signal = zeros(size(active_data));  % Preallocate the centered signal

% Moving window loop
for i = window_size:length(active_data)  % Start from 'window_size' to avoid index out of bounds
    % Extract the current window of data
    window_data = active_data(i - window_size + 1:i);  
    
    % Calculate the mean of the window
    window_mean = mean(window_data);  
    
    % Subtract the mean from the original signal in the window to center around 0
    active_data_win(i) = active_data(i) - window_mean;  
end

%% Root mean squared
pure_rms = rms(active_data);

%% Filtering
Fs = 100;

[b, a] = butter(4,25/(Fs/2), 'low');
post_filter_AXES = filtfilt(b,a,pre_filter_AXES);
post_filter_active = filtfilt(b,a,active_data_win);


%% Plotting
frame_start = 1;
frame_end = 360000;



processed_subset = post_filter_AXES(frame_start:frame_end, [1,3]); 
active_subset = post_filter_active(frame_start:frame_end, [1,3]); 

% Plot the original data
figure;

% Plot the filtered data
subplot(2,1,1);
plot(processed_subset); % Plot the filtered subset
title('Processed Data');
legend('X', 'Z');





% Plot the filtered data
subplot(2,1,2);
plot(active_subset); % Plot the filtered subset
title('Just active');
%legend('X', 'Z');

yline(pure_rms(1), 'b--', 'RMS_ML','LineWidth', 2);
yline(pure_rms(3), 'r--', 'RMS_AP', 'LineWidth', 2);






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
