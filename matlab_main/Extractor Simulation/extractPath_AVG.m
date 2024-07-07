function [DelayList, GainList, ThetaList] = extractPath_AVG(y, sub_loc, ant_loc, N_fft, N_ant, f_ind, ant_ind, OSR_fft, OSR_ant, R_s, R_c, tau, pathNumRange, NOMPtable)

if ~exist('pathNumRange','var'), pathNumRange = [1 10];
elseif isempty(pathNumRange), pathNumRange = [1 10]; end 

MinPathNum = pathNumRange(1);
MaxPathNum = pathNumRange(2);

[Delay_manifold, Theta_manifold] = preProcessMeasMat(y, N_fft, f_ind, ant_ind, OSR_fft, OSR_ant, NOMPtable);

DelayList = [];
GainList  = [];
ThetaList = [];
GroupList = [];
y_r = y;
pathNum = 1;

while true
    
    % Coarse Detection State
    [delay_new, gain_new, theta_new, group_new, y_r, res_inf_normSq_rot] = CoarseDetect(y_r, sub_loc, ant_loc, Delay_manifold, Theta_manifold);
    
    % Stopping criterion:
    if pathNum <= MaxPathNum
        if (res_inf_normSq_rot > tau) || (pathNum <= MinPathNum)
            delay = delay_new;
            gain = gain_new;
            theta = theta_new;
            group = group_new;
        else
            break;
        end
    else
        %disp('Warning! The number of path is large than the predefined number. Please check extractPath.m.');
        break;
    end
    
    % Refinement State
    for i = 1:R_s
        [delay_new, gain_new, theta_new, y_r] = NewtonRefine(y_r, delay, gain, theta, group, Delay_manifold, Theta_manifold);
    end
    DelayList(pathNum,1) = delay_new;
    GainList(pathNum,1)  = gain_new;
    ThetaList(pathNum,1) = theta_new;
    GroupList(pathNum,:) = group;

    [DelayList, GainList, ThetaList, y_r] = refineAll(y_r, R_s, R_c, DelayList, GainList, ThetaList, GroupList, Delay_manifold, Theta_manifold);
    [DelayList, GainList, ThetaList, y_r] = solveLeastSquares(y, DelayList, GainList, ThetaList, GroupList, Delay_manifold, Theta_manifold);
    
    pathNum = pathNum + 1 ;
    
end

DelayList = DelayList(1:pathNum-1) ;
GainList = GainList(1:pathNum-1) ;
ThetaList = ThetaList(1:pathNum-1) ;

end

function [Delay_manifold, Theta_manifold] = preProcessMeasMat(y, N_fft, f_ind, ant_ind, OSR_fft, OSR_ant, NOMPtable)

%% Gird point of delay 
N_sub = size(y,1);
R_fft = OSR_fft*N_fft;
coarseDelay = 2*pi*(0:(R_fft-1))/R_fft*N_fft;  %2*pi*2048切成16384等份

Delay_manifold.N_sub  = N_sub;
Delay_manifold.N_fft  = N_fft;
Delay_manifold.R      = R_fft;
Delay_manifold.coarse = coarseDelay;
Delay_manifold.ind    = f_ind;

%%  Gird point of AOA 
N_ant = size(y,2);
R_ant = size(NOMPtable,1);  
coarseTheta = R_ant*(0:R_ant-1)/R_ant;  %以角度為單位作切割

Theta_manifold.N          = N_ant;
Theta_manifold.R          = R_ant;
Theta_manifold.coarse     = coarseTheta;
Theta_manifold.NOMPtable  = NOMPtable;
Theta_manifold.ind        = ant_ind;

end

function  [delay_new, gain_new, theta_new, group_new, y_r, res_inf_normSq_rot] = CoarseDetect(y, sub_loc, ant_loc, Delay_manifold, Theta_manifold, pathNum)

N_sub       = Delay_manifold.N_sub;
N_fft       = Delay_manifold.N_fft;
R_fft       = Delay_manifold.R;
coarseDelay = Delay_manifold.coarse;
f_ind       = Delay_manifold.ind;

N_ant       = Theta_manifold.N;
R_ant       = Theta_manifold.R;
coarseTheta = Theta_manifold.coarse;
NOMPtable = Theta_manifold.NOMPtable;
ant_ind     = Theta_manifold.ind;

%%%%%%%%%%%%%%%%%%% find the strongest AoA and ToA (match with gain) %%%%%%%%%%%%%%%%%%%%
Y = zeros(R_fft,N_ant);
Y((R_fft-N_fft)/2 + sub_loc, ant_loc) = y;
gains = ifft(ifftshift(Y,1), R_fft)*R_fft;
gains = gains(1:N_fft,:)*NOMPtable';
gains = gains/N_sub/N_ant;
prob  = abs(gains).^2;

[~,IDX]   = max(prob(:));
theta_ind = ceil(IDX/N_fft);
delay_ind = IDX-(theta_ind-1)*N_fft;
delay_new = coarseDelay(delay_ind);
theta_new = coarseTheta(theta_ind);
group_new = NOMPtable(theta_ind,:);

ant_ind_theta = repmat(group_new,N_sub,1);
x = exp(-1j*f_ind*delay_new).*ant_ind_theta(:);
gain_new = (x'*y(:))/(x'*x);
y_r = y(:) - gain_new * x;

%%
OSR_fft = floor(R_fft/N_fft);
OSR_ant = floor(R_ant/N_ant);
prob_grid = prob(1:OSR_fft:end, 1:OSR_ant:end);
res_inf_normSq_rot = max(prob_grid(:)*N_sub*N_ant);

end

function [delay,gain,theta,y_r] = NewtonRefine(y_r,delay,gain,theta,group, Delay_manifold,Theta_manifold)

N_sub = Delay_manifold.N_sub;
f_ind = Delay_manifold.ind;

N_ant = Theta_manifold.N;
ant_ind = Theta_manifold.ind;
coarseTheta = Theta_manifold.coarse;
NOMPtable = Theta_manifold.NOMPtable;

%% origin signal
ant_ind_theta = repmat(group,N_sub,1);
x = exp(-1j*f_ind*delay).*ant_ind_theta(:);
y = y_r + gain*x;

%% delay refine
dx_delay = (-j*f_ind).*x;
dx2_delay = (- j*f_ind).^2.*x;

der1 = -2*real(gain * y_r'*dx_delay);
der2 = -2*real(gain * y_r'*dx2_delay) +2* abs(gain)^2*(dx_delay'*dx_delay);
           
if der2 > 0
    delay_new = delay - der1/der2;
else
    delay_new = delay - sign(der1)*(1/4)*(2*pi/2048)*rand(1);
end

%% theta refine
X = reshape(exp(-1j*f_ind*delay_new), N_sub, N_ant);
y_ = reshape(y, N_sub, N_ant);
gains = mean((X' *y_),1);
gains = gains*NOMPtable';
gains = gains/N_sub/N_ant;
prob  = abs(gains).^2;

[~,theta_ind] = max(prob(:));
theta_new = coarseTheta(theta_ind);
group_new = NOMPtable(theta_ind,:);
ant_ind_theta = repmat(group_new,N_sub,1);

x = exp(-1j*f_ind*delay_new).*ant_ind_theta(:);
gain_new = (x'*y)/(x'*x);
y_r_next = y - gain_new*x;

if (y_r_next'*y_r_next) <= (y_r'*y_r)
    delay = delay_new;
    gain = gain_new;
    y_r = y_r_next;
end

end

function [DelayList, GainList, ThetaList, y_r] = refineAll(y_r, R_s, R_c, DelayList, GainList, ThetaList, GroupList, Delay_manifold, Theta_manifold)
 
K = length(DelayList);

for i = 1:R_c
    order = 1:K;
    
    for j = 1:K
        l = order(j);
        delay = DelayList(l);
        gain = GainList(l);
        theta = ThetaList(l);
        group = GroupList(l,:);   
        
        for kk = 1:R_s
            [delay_new,gain_new,theta_new,y_r] = NewtonRefine(y_r,delay,gain,theta,group,Delay_manifold,Theta_manifold);
        end
        
        DelayList(l) = delay_new;
        GainList(l) = gain_new;
        ThetaList(l) = theta_new; 
    end
    
end

end

function [DelayList, GainList, ThetaList, y_r] = solveLeastSquares(y, DelayList, GainList, ThetaList, GroupList, Delay_manifold, Theta_manifold)

N_sub = Delay_manifold.N_sub;
f_ind = Delay_manifold.ind;
N_ant = Theta_manifold.N;
ant_ind = Theta_manifold.ind;

for ii = 1:size(ThetaList,1)
    group =  GroupList(ii,:);
    ant_ind_theta = repmat(group,N_sub,1);
    T(:,ii) = ant_ind_theta(:);
end

A =  bsxfun(@times, exp(bsxfun(@times, -1j*f_ind , DelayList.')) , T);
GainList = ((A'*A)\(A'*y(:)));
y_r = y(:) - A*GainList;
y_r = reshape(y_r,N_sub,N_ant);

end

