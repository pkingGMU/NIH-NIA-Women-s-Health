function [cwa_info, cwa_data_tables, total_time, sample_rate, S] = arrange_tables(folder)
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
%%
        % Get raw data info. This gives us start and stop times so it can
        % accuratly give us our time
        cwa_info = CWA_readFile(file_name,'info', 1);

        % Define start and end time
        start_time = datetime(cwa_info.start.str, "InputFormat", 'dd-MMM-yyyy HH:mm:ss');
        end_time = datetime(cwa_info.stop.str, "InputFormat", 'dd-MMM-yyyy HH:mm:ss');
        total_time = seconds(end_time-start_time);

        
        %%
        % Read in raw data
        rawData = CWA_readFile(file_name);
        rawData.ACC(:,2) = rawData.ACC(:,2) * -1; %Hopes trial her sensor was upside down in the ML direction

        % SAMPLE RATE
        sample_rate = length(rawData.ACC)/total_time;

      
        
        % get samples from stationary periods (at most first 7 days of file)
        S = getStationaryPeriods(rawData, 'stopTime', rawData.ACC(1,1)+168/24, 'progress', 1);
        
        % estimate the calibration parameters (scale, offset, temp-offset)
        e = estimateCalibration(S, 'verbose', 1);
        
        % re-scale data
        data = rescaleData(rawData, e);

        % COMPARISON RAW TABLES
        cwa_data_tables.AXESnoprocessing = array2table(data.ACC, 'VariableNames', {'UNIX TIME', 'Ax', 'Ay', 'Az'});


        % Create time vector
        time_stamps = start_time + seconds(0:(total_time-1)); % 0, 1, 2, ..., num_rows-1 seconds

        % Repeat time stamps
        %%% TODO
        timestamps_repeated = repelem(time_stamps, 100);

        % %%% ENMO To Find Inactivity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        % zero_frames = ENMO(inter_axes);
        % 
        % %%% Zeroing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        % inter_zero_axes = zero_func(inter_axes, zero_frames);

        %%% Interpolation %%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        inter_axes = interpolation(total_time, data.ACC(:, 2:4), sample_rate);
        

        %%% Tables %%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% New table for AXES
        cwa_data_tables.AXES = array2table(inter_axes, 'VariableNames', {'Ax', 'Ay', 'Az'});

        cwa_data_tables.AXES.Time = timestamps_repeated';

     
        

        

        
        

        
     
    end
end
