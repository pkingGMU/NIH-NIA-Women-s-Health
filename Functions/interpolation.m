function [resampled_frames_interpolate] = interpolation(time, data)
%INTERPOLATION Summary of this function goes here
%   Detailed explanation goes here
    %% Interpolation
    
    % Create the original time vector based on the variable sample rate (50.2224 frames/sec)
    time_original = linspace(0, time, length(data));
    
    total_desired_frames = 50 * time;
    
    % Define the desired time vector for 5 frames per second (i.e., 5 * 5 = 25 frames)
    time_resampled = linspace(0, time, total_desired_frames); % 25 frames
    
    % Resample using linear interpolation (or another method if desired)
    resampled_frames_interpolate = interp1(time_original, data, time_resampled, 'linear');
end

