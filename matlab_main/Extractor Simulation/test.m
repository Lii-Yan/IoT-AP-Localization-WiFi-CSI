clear
clc
%% AOA状态估计
%% setting
Tx_index = 1:10;                % Choose the TX for simulation
environment = 'Indoor office';  % Choose the environment for simulation
fileNames_cir_case = ['..\Wireless Insite\',environment];
%%此两个代码只是在图中标注位置，可以不进行理会

tx=1;rx=1;
load([fileNames_cir_case,'\Results_for_Mat\TX', num2str(tx), '\Pt_t',num2str(tx), '_r',num2str(rx),'_cir_doa.mat']);
SetPlot
SetAntenna    
fileFolder_TX = fullfile([fileNames_cir_case,'\Results_for_Mat\TX',num2str(tx)]);
    dirOutput = dir(fullfile(fileFolder_TX,'*cir*'));
    Rx_num = length(fullfile({dirOutput.name}','/'));
    [~,~] = mkdir(['Results_',environment,'\TX',num2str(tx)]);
    
    fprintf('TX = %d, RX = %d, ', tx, rx);
    load([fileNames_cir_case,'\Results_for_Mat\TX', num2str(tx), '\Pt_t',num2str(tx), '_r',num2str(rx),'_cir_doa.mat']);
    
    %多径信道参数 
    path_gain    = sim.path_gain;      % gain (linear)增益
    path_phase   = sim.path_phase;     % phase (rad)相位
    path_delay   = sim.path_delay;     % delay (sec)延迟时间
    path_AOA_hor = sim.path_AOA_hor;   % azimuth (rad)方位角
    path_AOA_ver = sim.path_AOA_ver;   % elevation (rad)高度
    path_AOA     = [path_AOA_ver path_AOA_hor];

       % 3D ideal triangular antenna 三维理想三角形线
       %channel + noise
    exp_gain = path_gain .* exp(1j*path_phase);
    exp_delay = exp(-1j*2*pi*f_sample*n_sample*path_delay.');
    exp_omega = Steering(set_triangular_3D.antPosition, path_AOA);       % use 3D AOA to generate channel
    H = exp_delay * bsxfun(@times, exp_gain, exp_omega);
    N = sqrt(noise_level)*(randn(N_fft,4) + 1j*randn(N_fft,4))/sqrt(2);  % maximum antenna number is 4

    % 2D ideal triangular antenna estimation
    Nr = set_triangular_2D.Nr;
    [est_triangular_2D] = CSI_Extraction(N_fft, Nr, sub_loc, H, N, noise_level, set_triangular_2D, 1, f_sample, n_sample, []);

    % 3D ideal triangular antenna estimation
    Nr = set_triangular_3D.Nr;
    [est_triangular_3D] = CSI_Extraction(N_fft, Nr, sub_loc, H, N, noise_level, set_triangular_3D, 1, f_sample, n_sample, []);
       
                for ii = 2:length(for_plot)
                    figure(ii)
                    eval(['model = ',char(for_plot(ii)),';']);
                    
                    subplot(1,3,1) % horizontal AoA
                    pp = polar(path_AOA_hor, path_gain, 'o');%极坐标
                    set(pp, 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 10); hold on
                    pp = polar(model.AOA_hor, abs(model.Gain), 'x');
                    set(pp, 'Color', color_ideal, 'LineWidth', 2, 'MarkerSize', 10); hold off
                    axis image;
                    
                    subplot(1,3,2) % vertical AoA
                    pp = polar(path_AOA_ver, path_gain, 'o');
                    set(pp, 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 10); hold on
                    pp = polar(model.AOA_ver, abs(model.Gain), 'x');
                    set(pp, 'Color', color_ideal, 'LineWidth', 2, 'MarkerSize', 10); hold off
                    axis image;
                    
                    subplot(1,3,3) % delay
                    stem(path_delay, path_gain, 'o', 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 10); hold on
                    stem(model.Delay, abs(model.Gain), 'x', 'Color', color_ideal, 'LineWidth', 2, 'MarkerSize', 10); hold off
                    xlabel('Delay (second)','fontsize',12,'fontweight','bold');
                    ylabel('Magnitude','fontsize',12,'fontweight','bold')
                    
                    title_temp = char(for_plot(ii));
                    title_ind = find(title_temp=='_');
                    title_temp(title_ind) = ' ';
                    suptitle(title_temp);
                    
                    legend('ground truth','estimation')    
                end
            