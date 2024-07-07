function [est] = CSI_Extraction(N_fft, Nr, sub_loc, H, N, noise_level, set, type, f_sample, n_sample, set2)

N_in = length(sub_loc);
H = H(sub_loc,:);
N = N(sub_loc,1:Nr);
n_sample = n_sample(sub_loc);

est.H = H;
est.RSSI = sum(abs(H).^2);
est.SNR = 10*log10(mean(abs(H).^2)./mean(abs(N).^2));

H = H + N;

%% Algorithm
OSR_fft = 8;                       % overSamplingRate for delay
OSR_ant = 128*(Nr>1) + 1*(Nr==1);  % overSamplingRate for AOA
R_s = 1;                           % update
R_c = 3;                           % refine
MinPathNum = 5;                    % minimum path numbers requred to be return from the algorithm
MaxPathNum = max(5, MinPathNum) ;  % MaxPathNum > MinPathNum; maximum path numbers for the algorithm
pathNumRange = [MinPathNum MaxPathNum];

F_ind = repmat(n_sample,Nr,1);
A_ind = ((0:Nr-1)'*ones(1,N_in))';        
A_ind = A_ind(:);

p_fa = 1e-2;  % false alarm
tau = noise_level * ( log(Nr*N_in) - log( log(1/(1-p_fa)) ) ); % stopping criteria

%% NOMP
if type == 1 % Phase Table
    [DelayList, GainList, ThetaList] = extractPath_AVG(H, sub_loc, [1:Nr], N_fft, Nr, F_ind, A_ind, OSR_fft, OSR_ant, R_s, R_c, tau, pathNumRange, set.phase_table);

    % sorting
    [~, Idx_descend] = sort(abs(GainList), 'descend');
    DelayList = DelayList(Idx_descend);
    ThetaList = ThetaList(Idx_descend);
    GainList  = GainList(Idx_descend);
    
    % horizontal vertical AOA
    ThetaList_ver = set.AOATable(ThetaList+1,1);    % azimuth (degree)
    ThetaList_hor = set.AOATable(ThetaList+1,2);    % elevation (degree)
        
    est.Delay     = DelayList/2/pi/f_sample;        % delay (sec)
    est.Gain      = GainList;                       % gain (complex) 
    est.AOA_hor   = ThetaList_hor/180*pi;           % azimuth (rad)
    est.AOA_ver   = ThetaList_ver/180*pi;           % elevation (rad)

% elseif type == 2 % MMV Table
%     [DelayList, GainList, ThetaList] = extractPath_MMV(H, sub_loc, [1:Nr], N_fft, Nr, n_sample, OSR_fft, OSR_ant, R_s, R_c, tau, pathNumRange, set.first_path, set2.MMV_table);
% 
%     % sorting
%     [~, Idx_descend] = sort(abs(GainList), 'descend');
%     DelayList = DelayList(Idx_descend);
%     ThetaList = ThetaList(Idx_descend);
%     GainList  = GainList(Idx_descend);  
% 
%     % horizontal vertical AOA
%     ThetaList_ver = set.AOATable(ThetaList+1,1);    % 路徑入射角 (degree)
%     ThetaList_hor = set.AOATable(ThetaList+1,2);    % 路徑入射角 (degree)
%             
%     est.Delay     = DelayList/2/pi/f_sample;                                   % 路徑延遲 (sec)
%     est.Gain      = GainList./set2.est_ratio(ThetaList+1);                     % 路徑增益 (complex)    
%     est.AOA_hor   = ThetaList_hor/180*pi;                                      % 路徑水平入射角 (rad)
%     est.AOA_ver   = ThetaList_ver/180*pi;                                      % 路徑垂直入射角 (rad)
%  
% elseif type == 3 % simulation Table
%     [DelayList, GainList, ThetaList] = extractPath_AVG(H, sub_loc, [1:Nr], N_fft, Nr, F_ind, A_ind, OSR_fft, OSR_ant, R_s, R_c, tau, pathNumRange, set.meas_table);
% 
%     % sorting
%     [~, Idx_descend] = sort(abs(GainList), 'descend');
%     DelayList = DelayList(Idx_descend);
%     ThetaList = ThetaList(Idx_descend);
%     GainList  = GainList(Idx_descend);  
%     
%     % horizontal vertical AOA
%     ThetaList_ver = set.AOATable(ThetaList+1,1);    % 路徑入射角 (degree)
%     ThetaList_hor = set.AOATable(ThetaList+1,2);    % 路徑入射角 (degree)
%         
%     est.Delay     = DelayList/2/pi/f_sample;                               % 路徑延遲 (sec)
%     est.Gain      = GainList;                                              % 路徑增益 (complex) 
%     est.AOA_hor   = ThetaList_hor/180*pi;                                  % 路徑水平入射角 (rad)
%     est.AOA_ver   = ThetaList_ver/180*pi;                                  % 路徑垂直入射角 (rad)
    
end

end

