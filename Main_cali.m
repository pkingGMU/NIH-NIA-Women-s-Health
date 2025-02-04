file_name = fullfile(pwd, 'Data', 'Hope', 'CWA-DATA.CWA');
%%
% Get raw data info. This gives us start and stop times so it can
% accuratly give us our time
cwa_info = CWA_readFile(file_name,'info', 1);

% Define start and end time
start_time = datetime(cwa_info.start.str, "InputFormat", 'dd-MMM-yyyy HH:mm:ss');
end_time = datetime(cwa_info.stop.str, "InputFormat", 'dd-MMM-yyyy HH:mm:ss');
total_time = seconds(end_time-start_time);

%% SVM computation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic sum(SVM-1) computation with the AX3.
%
% You will need the following four files:
%
%   - https://raw.githubusercontent.com/digitalinteraction/openmovement/master/Software/Analysis/Matlab/CWA_readFile.m
%   - https://raw.githubusercontent.com/digitalinteraction/openmovement/master/Software/Analysis/Matlab/resampleCWA.m
%   - https://raw.githubusercontent.com/digitalinteraction/openmovement/master/Software/Analysis/Matlab/SVM.m
%   - https://raw.githubusercontent.com/digitalinteraction/openmovement/master/Software/Analysis/Matlab/epochs.m
%

% Load CWA file re-sampled at 100Hz
fprintf('Loading and resampling data...\n');
Fs = 100;
data = resampleCWA(file_name, Fs);

% BP-Filtered SVM-1
fprintf('Calculating bandpass-filtered SVM(data)...\n');
svm = SVM(data, Fs, 0.5, 25);
%%
% Convert to 240 second epochs (sum of absolute SVM-1 values)
epochSVM = epochs(abs(svm), 60 * Fs);

%% RMS
rms_num = rms(epochSVM);

%% Plotting SVM
% Plot the raw bandpass-filtered SVM data
% figure;
% plot(svm);  % Plot the filtered SVM signal over time
% xlabel('Time (samples)');
% ylabel('Filtered SVM');
% title('Bandpass-Filtered SVM Signal');
% grid on;

%% Window Size 
windowSize = 50;

% Number of windows
numWindows = floor(length(epochSVM) / windowSize);

% Initialize array to store the window colors (1 = red, 0 = blue)
windowColors = zeros(numWindows, 1);  % 0 = blue, 1 = red

% Calculate the mean of each window and compare to RMS
for i = 1:numWindows
    startIdx = (i - 1) * windowSize + 1;
    endIdx = i * windowSize;
    
    % Count how many values exceed the RMS in the current window
    numAboveRMS = sum(epochSVM(startIdx:endIdx) > rms_num);
    
    % If the mean is above the RMS, color the window red, otherwise blue
    if numAboveRMS >= 2
        windowColors(i) = 1;  % Red
    else
        windowColors(i) = 0;  % Blue
    end
end

%% Plotting the Data with Windowed Coloring
figure;
hold on;

epochTime = (1:length(epochSVM)) * 60;  % Create time labels for each epoch (in seconds)

% Plot the windows with different colors based on mean comparison to RMS
for i = 1:numWindows
    startIdx = (i - 1) * windowSize + 1;
    endIdx = i * windowSize;
    
    % Define the time range for the window
    windowTime = epochTime(startIdx:endIdx);
    
    % If window mean > RMS, plot in red, else blue
    if windowColors(i) == 1
        plot(windowTime, epochSVM(startIdx:endIdx), 'r-', 'LineWidth', 2);  % Red line
    else
        plot(windowTime, epochSVM(startIdx:endIdx), 'b-', 'LineWidth', 2);  % Blue line
    end
end

% Add labels and title
xlabel('Time (seconds)');
ylabel('Sum of SVM (240s epochs)');
title('Sum of Absolute SVM in 240-second Epochs (Windowed Coloring)');
grid on;

% Plot the RMS line
yline(rms_num, 'r--', 'RMS', 'LineWidth', 2);

hold off;


%% Plotting epochs

% Plot the epoch-based SVM data (summed over 60 seconds)
figure;
epochTime = (1:length(epochSVM)) * 240;  % Create time labels for each epoch (in seconds)
plot(epochTime, epochSVM, '-o');  % Plot epoch data with a line and markers
xlabel('Time (seconds)');
ylabel('Sum of SVM (60s epochs)');
title('Sum of Absolute SVM in 60-second Epochs');
grid on;
yline(rms, 'r--', 'RMS', 'LineWidth', 2);

%%
% Read in raw data
rawData = AX3_readFile(file_name);
rawData.ACC(:,2) = rawData.ACC(:,2) * -1; %Hopes trial her sensor was upside down in the ML direction

% SAMPLE RATE
sample_rate = length(rawData.ACC)/total_time;

% get samples from stationary periods (at most first 7 days of file)
S = getStationaryPeriods(rawData, 'stopTime', rawData.ACC(1,1)+168/24, 'progress', 1);

% estimate the calibration parameters (scale, offset, temp-offset)
e = estimateCalibration(S, 'verbose', 1);

% re-scale data
data = rescaleData(rawData, e);

%%
% COMPARISON RAW TABLES
AXESprocessed = array2table(data.ACC, 'VariableNames', {'UNIX TIME', 'Ax', 'Ay', 'Az'});
AXES_processed = table2array(AXESprocessed);

%% Analysis

%% Filtering
Fs = 100;

[b, a] = butter(4,25/(Fs/2), 'low');
post_filter_processed = filtfilt(b,a,AXES_processed);
post_filter_raw = filtfilt(b,a, data.AXES);




%% Plotting
frame_start = 1;

processed_subset = post_filter_processed(frame_start:end, [2,4]); 
raw_subset = post_filter_raw(frame_start:end, [2,4]);



% Plot the original data
figure;

% Plot the filtered data
subplot(3,1,1);
plot(raw_subset); % Plot the filtered subset
title('Raw Data');
legend('X', 'Z');



% Plot the filtered data
subplot(2,1,3);
plot(processed_subset); % Plot the filtered subset
title('Processed Data');
legend('X', 'Z');



