function [zero_frames] = ENMO(data)
%ENMO 


    frame_end = 30000;

    ax = data(1:frame_end, 1);
    ay = data(1:frame_end, 2);
    az = data(1:frame_end, 3);

    % Calculate the magnitude for each frame
    magnitude = sqrt(ax.^2 + ay.^2 + az.^2);

    % Subtract 1g to account for gravity and clip negative values to zero
    ENMO_j = max(magnitude - 1, 0);

    % Plot ENMO over time
    figure;
    plot(ENMO_j);
    xlabel('Frames');
    ylabel('ENMO (g)');
    title('ENMO over Time');
    
    % Ask the user for a start frame

    start_frame = input('Please Enter Start of Inactivity: ');

    % Ask the user for an end frame

    end_frame = input('Please Enter End of Inactivity: ');

    %Debug 
    % start_frame = 26000;
    % end_frame = 28000;

    %%% Find 'Zero frames' or frames with no activity
    % Indicies
    zero_indices = find(ENMO_j(start_frame:end_frame) == 0);
    sub_indicies = zero_indices + start_frame -1;

    % Set zeroes where user specified
    zero_frames = sub_indicies;
    



end

