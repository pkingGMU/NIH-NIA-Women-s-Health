function [data] = zero_func(data, zero_frames)
%ZERO data using inactivity.
    

    accel_data = data(:, 1:3);
    gyro_data = data(:, 4:6);
    
    zero_accel_data = accel_data(zero_frames, :);
    zero_gyro_data = gyro_data(zero_frames, :);

    mean_accel = mean(zero_accel_data); 
    mean_gyro = mean(zero_gyro_data); 

    accel_zeroed = accel_data - mean_accel;  
    gyro_zeroed = gyro_data - mean_gyro; 

    data(:,1) = accel_zeroed(:, 1);  % Replace 'Ax' with the first column of accel_zeroed
    data(:,2) = accel_zeroed(:, 2);  % Replace 'Ay' with the second column of accel_zeroed
    data(:,3) = accel_zeroed(:, 3);  % Replace 'Az' with the third column of accel_zeroed
    
    data(:,4) = gyro_zeroed(:, 1);   % Replace 'Gx' with the first column of gyro_zeroed
    data(:,5) = gyro_zeroed(:, 2);   % Replace 'Gy' with the second column of gyro_zeroed
    data(:,6) = gyro_zeroed(:, 3);   % Replace 'Gz' with the third column of gyro_zeroed

end

