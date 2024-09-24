function [cwa_data, cwa_info, cwa_data_tables] = arrange_tables(folder)
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
        cwa_info = read_CWA(file_name,'info', 1);
        
        % Get raw data
        cwa_data = read_CWA(file_name, ...
            'packetInfo', cwa_info.packetInfo, ...
            'verbose', 1);

        %%% New table for AXES
        cwa_data_tables.AXES = array2table(cwa_data.AXES, 'VariableNames', {'TIME (UNIX)', 'Ax', 'Ay', 'Az', 'Gx', 'Gy', 'Gz'});

        % Convert column 1 timestamps to datetime
        converted_time_stamps = datetime(cwa_data.AXES(:,1), 'ConvertFrom', 'datenum');

        % Add the converted timestamps to the table as a new colum
        cwa_data_tables.AXES.CovertedTime = converted_time_stamps;
        
        %%% New table for ACC
        cwa_data_tables.ACC = array2table(cwa_data.ACC, 'VariableNames', {'TIME (UNIX)', 'Var1', 'Var2', 'Var3'});

        % Convert column 1 timestamps to datetime
        converted_time_stamps = datetime(cwa_data.ACC(:,1), 'ConvertFrom', 'datenum');

        % Add the converted timestamps to the table as a new colum
        cwa_data_tables.ACC.CovertedTime = converted_time_stamps;

        %%% New table for TEMP
        cwa_data_tables.TEMP = array2table(cwa_data.TEMP, 'VariableNames', {'TIME (UNIX)', 'TEMP'});

        % Add the converted timestamps to the table as a new colum

        % TODO: Implement later as the sizes don't match right now
        % Convert column 1 timestamps to datetime
        converted_time_stamps = datetime(cwa_data.TEMP(:,1), 'ConvertFrom', 'datenum');
        cwa_data_tables.TEMP.CovertedTime = converted_time_stamps;
        

        %%% Get total time for file

        % Define start and end time
        %start_time = datetime(cwa_info.start.str, "InputFormat", 'dd-MMM-yyyy HH:mm:ss');
        %end_time = datetime(cwa_info.stop.str, "InputFormat", 'dd-MMM-yyyy HH:mm:ss');
        %total_time = seconds(end_time-start_time);

        %CHANGE THIS
        

        
     
    end
end
