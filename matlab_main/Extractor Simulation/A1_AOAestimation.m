clear
clc
%% AOA状态估计
%% setting
%A1_AOAestimation
Tx_index = 1;                % Choose the TX for simulation
environment = 'Indoor office';  % Choose the environment for simulation
fileNames_cir_case = ['..\Wireless Insite\',environment];

SetPlot
SetAntenna

for tx = Tx_index
    
    fileFolder_TX = fullfile([fileNames_cir_case,'\Results_for_Mat\TX',num2str(tx)]);
    dirOutput = dir(fullfile(fileFolder_TX,'*cir*'));
    Rx_num = length(fullfile({dirOutput.name}','/'));
    [~,~] = mkdir(['Results_',environment,'\TX',num2str(tx)]);
    
    %% For every Rx point
    Rx_num=2;
    for rx = 2
        fprintf('TX = %d, RX = %d, ', tx, rx);
        load([fileNames_cir_case,'\Results_for_Mat\TX', num2str(tx), '\Pt_t',num2str(tx), '_r',num2str(rx),'_cir_doa.mat']);
        
        if isempty(sim.path_gain)
            fprintf([' is empty, ']);
        else
                  %% Multipath channel parameter
         
            path_gain    = sim.path_gain;      % gain (linear)
            path_phase   = sim.path_phase;     % phase (rad)
            path_delay   = sim.path_delay;     % delay (sec)
            path_AOA_hor = sim.path_AOA_hor;   % azimuth (rad)
            path_AOA_ver = sim.path_AOA_ver;   % elevation (rad)
            path_AOA     = [path_AOA_ver path_AOA_hor];
            
                   %% 3D ideal triangular antenna  channel + noise
            %添加噪声       
            exp_gain = path_gain .* exp(1j*path_phase);
            exp_delay = exp(-1j*2*pi*f_sample*n_sample*path_delay.');
            exp_omega = Steering(set_triangular_3D.antPosition, path_AOA);       % use 3D AOA to generate channel
            
            H = exp_delay * bsxfun(@times, exp_gain, exp_omega);
            N = sqrt(noise_level)*(randn(N_fft,4) + 1j*randn(N_fft,4))/sqrt(2);  % maximum antenna number is 4
            
            % 2D ideal triangular antenna estimation 二维理想三角形天线。
            Nr = set_triangular_2D.Nr;
            noise_level=0;
            [est_triangular_2D] = CSI_Extraction(N_fft, Nr, sub_loc, H, N, noise_level, set_triangular_2D, 1, f_sample, n_sample, []);
            
            % 3D ideal triangular antenna estimation
            Nr = set_triangular_3D.Nr;
            [est_triangular_3D] = CSI_Extraction(N_fft, Nr, sub_loc, H, N, noise_level, set_triangular_3D, 1, f_sample, n_sample, []);
            PLOT=1;
            
            if PLOT
                figure(2)
                
                for ii = 2:length(for_plot)
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
                end % for_save
                
            end % PLOT
                        
        end %isempty(sim.path_gain)
        
        file_name = ['Results_',environment,'\TX',num2str(tx), '\Pt_t',num2str(tx), '_r',num2str(rx),'_nomp.mat'];
        eval(['save(file_name,',for_save,')'])
        fprintf('\n');
        
    end % rx
    
end % tx

% name = fieldnames(est_triangular_3D);
% for k = 1:length(name)
% eval([name{k},'=est_triangular_3D.',name{k}]);
% end




