%%% MAIN SCRIPT %%%
clc
clear

%%% Local Imports
% Add function folder to search path
addpath(genpath('Functions'))

% Select directory
folder = uigetdir();

sub_folder = arrange_subjects(folder);

for i = 1:length(sub_folder)
    folder = sub_folder(i);
    %%
    folder = fullfile(folder.folder, folder.name);
    
    % File pattern is equal to our folder directory + a cwa file 
    filePattern = fullfile(folder, '*.cwa');
    % files is an array of all the files in our chosen directory with the cwa extension
    files = dir(filePattern);
    
    %%% Loop through all file names in the files array
    for file = 1:numel(files)
        
        
        
        % Set temp variable to the nth file in our list of files
        file_name = fullfile(folder, files(file).name);
        % A shorted file name without the csv extension
        file_name_short = strrep(erase(files(file).name, ".cwa"), ' ', '_'); 
    
        % Debugging
        disp(file_name_short)
    
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
        
        %%% CHANGEABLE USER VARIABLES %%%
        epochSize = 60;
        posture_window_size = 20000;
        
        % Load CWA file re-sampled at 100Hz
        fprintf('Loading and resampling data...\n');
        Fs = 100;
        data = resampleCWA(file_name, Fs);

        

        %% Angle adjaceent to gravity 
        med_data = medfilt1(data(:, [2,3,4]), 3);

        % Step 2: Design the third-order elliptical IIR filter (discrete-time)
        fs = 100; % Sampling frequency (adjust to your data)
        cutoff = 0.25; % Cutoff frequency in Hz
        rp = 0.01; % Passband ripple in dB
        rs = 100; % Stopband attenuation in dB
        order = 3; % Filter order
        
        % Normalize the cutoff frequency
        nyquist = fs / 2;
        normalized_cutoff = cutoff / nyquist;
        
        % Filter using the corrected syntax
        [b, a] = ellip(order, rp, rs, normalized_cutoff);
        
        % Low-pass filter
        gravity_vector = filter(b, a, med_data);
        
        data_grav = gravity_vector(:, 2);
        data_grav(data_grav < 0) = 0;
        

        theta_gravity = rad2deg(real(acos(data_grav)));

        

        %% POSTURAL CLASSIFICATION %%
        
        
        % Number of windows
        posture_num_windows = floor(length(theta_gravity) / posture_window_size);
        
        % Calculate the mean of each window and compare to RMS
        for i = 1:posture_num_windows
            startIdx = (i - 1) * posture_window_size + 1;
            endIdx = i * posture_window_size;
           
            % Count how many values exceed the RMS in the current window
            stand_sum = sum(theta_gravity(startIdx:endIdx) <= 20 & theta_gravity(startIdx:endIdx) > 0 );
            sit_sum = sum(theta_gravity(startIdx:endIdx) > 20 & theta_gravity(startIdx:endIdx) <= 60);
            lying_sum = sum(theta_gravity(startIdx:endIdx) > 60);
            
            % If the mean is above the RMS, color the window red, otherwise blue
            if stand_sum >= sit_sum && stand_sum >= lying_sum
                posture_color(i) = 2;  
                rms_idx(startIdx:endIdx) = 1;
            elseif sit_sum > stand_sum && sit_sum >= lying_sum
                posture_color(i) = 1;  
                rms_idx(startIdx:endIdx) = 0;
            elseif lying_sum > sit_sum && lying_sum > stand_sum
                posture_color(i) = 0;  
                rms_idx(startIdx:endIdx) = 0;
            end
        end
        

        %% ACTIVITY CLASSIFICATION BINARY %%
        
        % BP-Filtered SVM-1
        fprintf('Calculating bandpass-filtered SVM(data)...\n');
        svm_all = nan(size(rms_idx));

        svm = SVM(data(rms_idx == 1, :), Fs, 0.5, 25);

        svm_all(rms_idx == 1) = svm;

        % Convert to 60 second epochs (sum of absolute SVM-1 values)
        epochSVM = epochs(abs(svm_all), epochSize * Fs);

        
        %% RMS
        rms_num = sqrt(nanmean(epochSVM.^2)) / 1.5;

        
        %% Window Size 
        windowSize = 10;
        
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
            if numAboveRMS >= 3
                windowColors(i) = 1;  % Red
            else
                windowColors(i) = 0;  % None
            end
        end

        %% Plot raw data %%
        figure;
        plot(data(: ,[2,3,4]))
        xlim([0, length(data)])
        title('Raw 3 Axis');
        xlabel('Time (samples)');
        ylabel('Accelerations');
        legend('Medial/Lateral', 'Vertical', 'Anterior/Posterior')
        
        %% Plotting the Data with Windowed Coloring

        % colors

        green = '#006633';
        sage = '#949b78';
        white = '#d2e4d6';
        
        stand_color = hex2rgb('#53b276');
        sit_color = hex2rgb('#752933');
        lying_color = hex2rgb('#0A0E29');
        


        windowColorRGB = hex2rgb(green);
        activeRGB = hex2rgb(green);
        inactiveRGB = hex2rgb(sage);
        
        figure;
        subplot(2, 1,1);
        hold on

        theta_time = (1:length(theta_gravity)) * 1;  % Create time labels for each epoch (in seconds)


         % Plot the windows with different colors based on mean comparison to RMS
        for i = 1:posture_num_windows
            startIdx = (i - 1) * posture_window_size + 1;
            endIdx = i * posture_window_size;
            
            % Define the time range for the window
            posture_window_time = theta_time(startIdx:endIdx);
            
            % If window mean > RMS, plot in red, else blue
            if posture_color(i) == 2
                plot(posture_window_time, theta_gravity(startIdx:endIdx), 'k-', 'LineWidth', 2, Color=stand_color);  % Red line
                fill([posture_window_time(1), posture_window_time(end), posture_window_time(end), posture_window_time(1)], ...
                     [0, 0, max(theta_gravity), max(theta_gravity)], stand_color, 'FaceAlpha', .2, 'EdgeColor', 'none');
            elseif posture_color(i) == 1
                plot(posture_window_time, theta_gravity(startIdx:endIdx), 'k-', 'LineWidth', 2, Color=sit_color);  % Red line
                fill([posture_window_time(1), posture_window_time(end), posture_window_time(end), posture_window_time(1)], ...
                     [0, 0, max(theta_gravity), max(theta_gravity)], sit_color, 'FaceAlpha', .2, 'EdgeColor', 'none');
            else
                plot(posture_window_time, theta_gravity(startIdx:endIdx), 'k-', 'LineWidth', 2, Color=lying_color);  % Blue line
                fill([posture_window_time(1), posture_window_time(end), posture_window_time(end), posture_window_time(1)], ...
                     [0, 0, max(theta_gravity), max(theta_gravity)], lying_color, 'FaceAlpha', .2, 'EdgeColor', 'none');
            end
        end
        
        

        
        % plot(theta_gravity, 'LineWidth', 1.5);
        title('Theta Gravity');
        xlabel('Time (samples)');
        ylabel('Theta (degrees)');
        grid off;
        hold off
        start = 800;
        trial_end = 28000;

        % Label a point at x = 2
        % text(start, 4000, 'Stand Still (Calibrate)');
        % xline(start);
        % text(start + 3000, 40, 'Jumping Jacks');
        % xline(start + 3000);
        % text(start + 6000, 40, 'Sitting');
        % xline(start + 6000);
        % text(start + 9000, 40, 'Sit Active');
        % xline(start + 9000);
        % text(start + 12000, 40, 'Stand Upright');
        % xline(start + 12000)
        % text(start + 15000, 40, 'Walking');
        % xline(start + 15000)
        % text(start + 18000, 40, 'Running');
        % xline(start + 18000)
        % text(start + 21000, 40, 'Lying');
        % xline(start + 21000)
        % text(start + 24000, 40, 'Stand Still (Calibrate)');
        % xline(start + 24000)
        % % 
        % xlim([start, trial_end]);
         % Subplot 2: Plot SVM with windowed coloring

         xlim([0 11580000])
        subplot(2, 1, 2);
        hold on

        
        

        epochTime = (1:length(epochSVM)) * epochSize;  % Create time labels for each epoch (in seconds)
        
        % Plot the windows with different colors based on mean comparison to RMS
        for i = 1:numWindows
            startIdx = (i - 1) * windowSize + 1;
            endIdx = i * windowSize;
            
            % Define the time range for the window
            windowTime = epochTime(startIdx:endIdx);
            
            % If window mean > RMS, plot in red, else blue
            if windowColors(i) == 1
                plot(windowTime, epochSVM(startIdx:endIdx), 'k-', 'LineWidth', 2, Color=activeRGB);  % Red line
                fill([windowTime(1), windowTime(end), windowTime(end), windowTime(1)], ...
                     [0, 0, max(epochSVM), max(epochSVM)], windowColorRGB, 'FaceAlpha', .2, 'EdgeColor', 'none');
            else
                plot(windowTime, epochSVM(startIdx:endIdx), 'k-', 'LineWidth', 2);  % Blue line
                
            end
        end
        
        % Add labels and title
        xlabel('Time (seconds)');
        ylabel('Sum of SVM');
        
        xlim([0 115800])
        
        start = 8;
        trial_end = 280;

        % Label a point at x = 2
        % text(start, 20, 'Stand Still (Calibrate)');
        % xline(start);
        % text(start + 30, 20, 'Jumping Jacks');
        % xline(start + 30);
        % text(start + 60, 20, 'Sitting');
        % xline(start + 60);
        % text(start + 90, 20, 'Sit Active');
        % xline(start + 90);
        % text(start + 120, 42, 'Stand Upright');
        % xline(start + 120)
        % text(start + 150, 20, 'Walking');
        % xline(start + 150)
        % text(start + 180, 20, 'Running');
        % xline(start + 180)
        % text(start + 210, 20, 'Lying');
        % xline(start + 210)
        % text(start + 240, 20, 'Stand Still (Calibrate)');
        % xline(start + 240)
        % % 
        % xlim([start, trial_end]);

        % title('Sum of Absolute SVM in 240-second Epochs (Windowed Coloring)');
        grid off;
        
        % Plot the RMS line
        % yline(rms_num, 'r--', 'RMS', 'LineWidth', 2);
        hold off
        
     
    end


end