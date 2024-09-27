function [zero_frames] = ENMO(data)
%ENMO 


    frame_end = 30000;
    
   
    ax = data(1:frame_end, 2);
    ay = data(1:frame_end, 3);
    az = data(1:frame_end, 4);

    % Calculate the magnitude for each frame
    magnitude = sqrt(ax.^2 + ay.^2 + az.^2);

    % Subtract 1g to account for gravity and clip negative values to zero
    ENMO = max(magnitude - 1, 0);

    disp(ENMO(1:10));

    % Assuming you have a corresponding time vector `time` for your data
    time = linspace(0, length(ENMO) * (1/50), length(ENMO));  % Example, adjust based on your sample rate
    
    % Plot ENMO over time
    figure;
    plot(ENMO);
    xlabel('Frames');
    ylabel('ENMO (g)');
    title('ENMO over Time');
    
    % Ask the user for a start frame
    
    start_frame = input('Please Enter Start of Inactivity: ');

    % Ask the user for an end frame
    
    end_frame = input('Please Enter End of Inactivity: ');

    %%% Find 'Zero frames' or frames with no activity
    % Indicies
    zero_indices = find(ENMO(start_frame:end_frame) == 0);

    % Set zeroes where user specified
    zero_frames = zero_indices;
    



end

