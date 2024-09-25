function [] = ENMO(data_table)
%ENMO Summary of this function goes here
%   Detailed explanation goes here
    ax = data_table{:, {'Ax'}};
    ay = data_table{:, {'Ay'}};
    az = data_table{:, {'Az'}};

    % Step 1: Calculate the magnitude for each frame
    magnitude = sqrt(ax.^2 + ay.^2 + az.^2);

    % Step 2: Subtract 1g to account for gravity and clip negative values to zero
    ENMO = max(magnitude - 1, 0);

    disp(ENMO(1:10));

    % Assuming you have a corresponding time vector `time` for your data
    time = linspace(0, length(ENMO) * (1/50), length(ENMO));  % Example, adjust based on your sample rate
    
    % Plot ENMO over time
    figure;
    plot(time, ENMO);
    xlabel('Time (s)');
    ylabel('ENMO (g)');
    title('ENMO over Time');

end

