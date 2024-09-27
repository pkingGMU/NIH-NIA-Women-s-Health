function allmetrics = apply_metrics(data, sf, ws3, n, lb, hb, zc_lb, zc_hb, zc_sb, zc_order)
    % Default arguments
    if nargin < 12, zc_order = 2; end
    if nargin < 11, zc_sb = 0.01; end
    if nargin < 10, zc_hb = 3; end
    if nargin < 9, zc_lb = 0.25; end
    if nargin < 8, hb = 15; end
    if nargin < 7, lb = 0.2; end
    if nargin < 6, n = 4; end
    
    % Extract x, y, and z acceleration columns
    data = data{1:10000000, {'Ax', 'Ay', 'Az'}};

    epochsize = ws3; % Epoch size in seconds
    
    % Metrics to do
    do_bfen = true;
    do_enmo = true;
    do_lfenmo = false;
    do_en = false;
    do_hfen = false;
    do_hfenplus = false;
    do_mad = false;
    do_anglex = false;
    do_angley = false;
    do_anglez = false;
    do_roll_med_acc_x = false;
    do_roll_med_acc_y = false;
    do_roll_med_acc_z = false;
    do_dev_roll_med_acc_x = false;
    do_dev_roll_med_acc_y = false;
    do_dev_roll_med_acc_z = false;
    do_enmoa = false;
    do_lfen = false;
    do_hfx = false;
    do_hfy = false;
    do_hfz = false;
    do_lfx = false;
    do_lfy = false;
    do_lfz = false;
    do_bfx = false;
    do_bfy = false;
    do_bfz = false;
    do_zcx = true;
    do_zcy = true;
    do_zcz = true;
    do_brondcounts = false;
    do_neishabouricounts = false;

    % Initialize metrics output structure
    allmetrics = struct();

    % Helper functions
    averagePerEpoch = @(x, sf, epochsize) mean(reshape(x, sf*epochsize, []), 1);
    sumPerEpoch = @(x, sf, epochsize) sum(reshape(x, sf*epochsize, []), 1);

    % Adjust high boundary filter if sampling frequency is too low
    if sf <= (hb * 2)
        hb = round(sf/2) - 1;
    end
    gravity = 1;

    % Band-pass filtering related metrics
    if do_bfen || do_bfx || do_bfy || do_bfz
        data_processed = abs(process_axes(data, 'bandpass', [lb, hb], n, sf));
        if do_bfx
            allmetrics.BFX = averagePerEpoch(data_processed(:, 1), sf, epochsize);
        end
        if do_bfy
            allmetrics.BFY = averagePerEpoch(data_processed(:, 2), sf, epochsize);
        end
        if do_bfz
            allmetrics.BFZ = averagePerEpoch(data_processed(:, 3), sf, epochsize);
        end
        if do_bfen
            allmetrics.BFEN = averagePerEpoch(euclideanNorm(data_processed), sf, epochsize);
        end
    end

    % Zero crossing count
    if do_zcx || do_zcy || do_zcz
        data_processed = process_axes(data, 'bandpass', [zc_lb, zc_hb], zc_order, sf);
        zc_axes = find([do_zcx, do_zcy, do_zcz]);
        Ndat = size(data_processed, 1);
        for zi = zc_axes
            smallvalues = abs(data_processed(:, zi)) < zc_sb;
            data_processed(smallvalues, zi) = 0;
            data_processed(:, zi) = sign(data_processed(:, zi));
            zerocross = @(x) 0.5 * abs(diff(sign(x)));
            if zi == 1
                allmetrics.ZCX = sumPerEpoch(zerocross(data_processed(:, 1)), sf, epochsize);
            elseif zi == 2
                allmetrics.ZCY = sumPerEpoch(zerocross(data_processed(:, 2)), sf, epochsize);
            elseif zi == 3
                allmetrics.ZCZ = sumPerEpoch(zerocross(data_processed(:, 3)), sf, epochsize);
            end
        end
    end

    % Low-pass filtering related metrics
    if do_lfenmo || do_lfx || do_lfy || do_lfz || do_lfen
        data_processed = abs(process_axes(data, 'low', hb, n, sf));
        if do_lfx
            allmetrics.LFX = averagePerEpoch(data_processed(:, 1), sf, epochsize);
        end
        if do_lfy
            allmetrics.LFY = averagePerEpoch(data_processed(:, 2), sf, epochsize);
        end
        if do_lfz
            allmetrics.LFZ = averagePerEpoch(data_processed(:, 3), sf, epochsize);
        end
        if do_lfen
            allmetrics.LFEN = averagePerEpoch(euclideanNorm(data_processed), sf, epochsize);
        end
    end

    % Other metrics (angle, ENMO, MAD, etc.)
    if do_anglex
        allmetrics.AngleX = atan2d(data(:, 1), sqrt(data(:, 2).^2 + data(:, 3).^2));
    end
    if do_angley
        allmetrics.AngleY = atan2d(data(:, 2), sqrt(data(:, 1).^2 + data(:, 3).^2));
    end
    if do_anglez
        allmetrics.AngleZ = atan2d(data(:, 3), sqrt(data(:, 1).^2 + data(:, 2).^2));
    end

    % Euclidean Norm Minus One (ENMO)
    if do_enmo
        allmetrics.ENMO = euclideanNorm(data) - 1;
    end

    % Mean Amplitude Deviation (MAD)
    if do_mad
        allmetrics.MAD = mean(abs(data - mean(data, 1)), 1);
    end
end

function normVal = euclideanNorm(data)
    normVal = sqrt(sum(data.^2, 2));
end

function data_processed = process_axes(data, filtertype, cut_point, n, sf)
    if isempty(sf)
        warning('Sampling frequency (sf) not provided.');
    end

    [b, a] = butter(n, cut_point / (sf / 2), filtertype);
    data_processed = filtfilt(b, a, data);
end
