function [data,] = arrange_tables(folder)
    %%%
    % Looking at the directory 'folder'. 
    % 
    % 1. Looking at every file in 'folder'.
    %
    % 2. For every file we read the cwa data
    %
    % 3. TODO: ADD More comments
    %
    %
    % 3. 
    
    %%% Make an array of the file names. Normally it is one file but this
    %%% ensure we capture any extra files.
    

    folder = fullfile(folder.folder, folder.name);
    
    % File pattern is equal to our folder directory + a csv file 
    filePattern = fullfile(folder, '*.cwa');
    % files is an array of all the files in our chosen directory with the csv extension
    files = dir(filePattern);
    
    %%% Loop through all file names in the files array
    
    % We loop through the amount of times there are files and set the
    % variable file = to which loop we'er on.
    % The first pass file = 1
    % The second pass file = 2
    % Etc.....
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
     
    end
end
