function [feature] = guiyihua_1(feature_merge, traj_idx, rand_flag, tx) 
feature = zeros(length(traj_idx), 15, 10);
for tx_temp = 1:10
    feature_temp = feature_merge(traj_idx, :, tx_temp);
    % Maximum energy
    power_max = []; 
    power_max_chazhi = [];
    for power_i = 1:length(traj_idx)
        feature_power = feature_temp(power_i, :);
        tt = sortrows(reshape(feature_power, [5, 3]), 1);
        power_max = [power_max, tt(end, 1)];
        power_max_chazhi = [power_max_chazhi, tt(end, 3)];
    end

    % Energy normalization
    feature(:, 1:5, tx_temp) = (feature_temp(:, 1:5) - min(min(feature_temp(:, 1:5)))) / (max(max(feature_temp(:, 1:5))) - min(min(feature_temp(:, 1:5))));
    % Time normalization
    feature(:, 6:10, tx_temp) = (feature_temp(:, 6:10) - min(min(feature_temp(:, 6:10)))) / (max(max(feature_temp(:, 6:10))) - min(min(feature_temp(:, 6:10)))); 
    feature(:, 11:15, tx_temp) = feature_temp(:, 11:15);
end

if rand_flag == 1
    environment = 'Indoor office'; 
    addpath(['../Extractor Simulation'])
    fileNames_cir_case = ['..\Wireless Insite\', environment];
    SetAntenna
    rx_i = 0;
    feature_temp = [];
    for rx = traj_idx
        rx_i = rx_i + 1;
        load([fileNames_cir_case, '\Results_for_Mat\TX', num2str(tx), '\Pt_t', num2str(tx), '_r', num2str(rx), '_cir_doa.mat']);
        path_gain = sim.path_gain; % gain (linear)
        path_phase = sim.path_phase; % phase (rad)
        path_delay = sim.path_delay; % delay (sec)
        path_AOA_hor = sim.path_AOA_hor; % azimuth (rad)
        path_AOA_ver = sim.path_AOA_ver; % elevation (rad)
        path_AOA = [path_AOA_ver path_AOA_hor];
        exp_gain = path_gain .* exp(1j*path_phase);
        exp_delay = exp(-1j*2*pi*f_sample*n_sample*path_delay.');
        exp_omega = Steering(set_triangular_3D.antPosition, path_AOA); % use 3D AOA to generate channel

        H = exp_delay * bsxfun(@times, exp_gain, exp_omega);
        N = sqrt(noise_level) * (randn(N_fft, 4) + 1j*randn(N_fft, 4)) / sqrt(2); % maximum antenna number is 4
        % 3D ideal triangular antenna estimation
        Nr = set_triangular_3D.Nr;
        [est_triangular_3D] = CSI_Extraction(N_fft, Nr, sub_loc, H, N, noise_level, set_triangular_3D, 1, f_sample, n_sample, []);

        feature_temp_1 = [abs(est_triangular_3D.Gain), est_triangular_3D.Delay, est_triangular_3D.AOA_hor];
        feature_temp_1 = reshape(feature_temp_1, 1, []);
        feature_temp(rx_i, :) = feature_temp_1;
    end
    %% Normalization
    % Maximum energy
    power_max = []; 
    power_max_chazhi = [];
    for power_i = 1:length(traj_idx)
        feature_power = feature_temp(power_i, :);
        tt = sortrows(reshape(feature_power, [5, 3]), 1);
        power_max = [power_max, tt(end, 1)];
        power_max_chazhi = [power_max_chazhi, tt(end, 3)];
    end
    % Energy normalization
    feature(:, 1:5, tx) = (feature_temp(:, 1:5) - min(min(feature_temp(:, 1:5)))) / (max(max(feature_temp(:, 1:5))) - min(min(feature_temp(:, 1:5))));
    % Time normalization
    feature(:, 6:10, tx) = (feature_temp(:, 6:10) - min(min(feature_temp(:, 6:10)))) / (max(max(feature_temp(:, 6:10))) - min(min(feature_temp(:, 6:10)))); 
    feature(:, 11:15, tx) = feature_temp(:, 11:15);
end
end