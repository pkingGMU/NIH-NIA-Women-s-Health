function [subjects] = process(subjects_list)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    % Each subject folder
    for i = 1:length(subjects_list)
        subject = subjects_list(i);

        % Get subject data for subject folder
        [cwa_data, cwa_info, cwa_data_tables, total_time, sample_rate] = arrange_tables(subject);
    
        % Easy naming convention
        subject =  'sub' + string(subject.name);

        % Struct setup data
        subjects.(subject).cwa_data = cwa_data;

        % Struct setup info
        subjects.(subject).info = cwa_info;

        % Struct setup for total time
        subjects.(subject).time = total_time;

        %%% Struct setup for tables

        % Struct setup for Axes
        subjects.(subject).Tables.AXES = cwa_data_tables.AXES;

        subjects.(subject).Tablesnoprocessing.AXES = cwa_data_tables.AXESnoprocessing;

        % Struct setup for ACC
        %subjects.(subject).Tables.ACC = cwa_data_tables.ACC;

        % Struct setup for TEMP
        %subjects.(subject).Tables.TEMP = cwa_data_tables.TEMP;

        % Struct setup for sample rate
        subjects.(subject).sample_rate = sample_rate;

        
    end
end