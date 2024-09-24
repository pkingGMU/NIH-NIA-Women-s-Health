function [cwa_data, cwa_info] = arrange_tables(folder)
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

        cwa_data = read_CWA(file_name);
        cwa_info = read_CWA(file_name,'info', 1);
        
     
    end
end
