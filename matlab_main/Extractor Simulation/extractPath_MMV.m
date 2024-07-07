function [DelayList, GainList, ThetaList] = extractPath_MMV(y, sub_loc, ant_loc, N_fft, N_ant, f_ind, OSR_fft, OSR_ant, R_s, R_c, tau, pathNumRange, first_path, MMV_table)

if ~exist('pathNumRange','var'), pathNumRange = [1 10];
elseif isempty(pathNumRange), pathNumRange = [1 10]; end

MinPathNum = pathNumRange(1);
MaxPathNum = pathNumRange(2);

[Delay_manifold, Theta_manifold] = preProcessMeasMat(y, N_fft, f_ind, OSR_fft, OSR_ant, first_path, MMV_table);

DelayList = [];
GainList  = [];
ThetaList = [];
y_r = y;
pathNum = 1;

while true
    
    % Coarse Detection State
    [delay_new, gain_new, theta_new, y_r, res_inf_normSq_rot] = CoarseDetect(y_r, sub_loc, ant_loc, Delay_manifold, Theta_manifold, pathNum);
    
    % Stopping criterion:
    if pathNum <= MaxPathNum
        if (res_inf_normSq_rot > tau) || (pathNum <= MinPathNum)
            delay = delay_new;
            gain = gain_new;
            theta = theta_new;
        else
            break;
        end
    else
        %disp('Warning! The number of path is large than the predefined number. Please check extractPath.m.');
        break;
    end
    
    % Refinement State
    for i = 1:R_s
        [delay_new, gain_new, theta_new, y_r] = NewtonRefine(y_r, delay, gain, theta, Delay_manifold, Theta_manifold, pathNum);
        % delay = delay_new;
        % gain = gain_new;
        % theta = theta_new;
    end
    DelayList(pathNum,1) = delay_new;
    GainList(pathNum,1)  = gain_new;
    ThetaList(pathNum,1) = theta_new;
    
    [DelayList, GainList, ThetaList, y_r] = refineAll(y_r, R_s, R_c, DelayList, GainList, ThetaList, Delay_manifold, Theta_manifold);
    [DelayList, GainList, ThetaList, y_r] = solveLeastSquares(y, DelayList, GainList, ThetaList, Delay_manifold, Theta_manifold);
    
    pathNum = pathNum + 1 ;
    
end

DelayList = DelayList(1:pathNum-1) ;
GainList = GainList(1:pathNum-1) ;
ThetaList = ThetaList(1:pathNum-1) ;

end

function [Delay_manifold, Theta_manifold] = preProcessMeasMat(y, N_fft, f_ind, OSR_fft, OSR_ant, first_path, MMV_table)

%% Gird point of delay
N_sub = size(y,1);
R_fft = OSR_fft*N_fft;
coarseDelay = 2*pi*(0:(R_fft-1))/R_fft*N_fft;  %2*pi*2048ちΘ16384单

Delay_manifold.N_sub  = N_sub;
Delay_manifold.N_fft  = N_fft;
Delay_manifold.R      = R_fft;
Delay_manifold.coarse = coarseDelay;
Delay_manifold.ind    = f_ind;

%%  Gird point of AOA
N_ant = size(y,2);
R_ant = size(first_path,1);
coarseTheta = R_ant*(0:R_ant-1)/R_ant;  %à虫ち澄

Theta_manifold.N         = N_ant;
Theta_manifold.R         = R_ant;
Theta_manifold.coarse    = coarseTheta;
Theta_manifold.AVG_table = first_path;
Theta_manifold.MMV_table = MMV_table;

end

function  [delay_new, gain_new, theta_new, y_r, res_inf_normSq_rot] = CoarseDetect(y, sub_loc, ant_loc, Delay_manifold, Theta_manifold, pathNum)

N_sub       = Delay_manifold.N_sub;
N_fft       = Delay_manifold.N_fft;
R_fft       = Delay_manifold.R;
coarseDelay = Delay_manifold.coarse;
f_ind       = Delay_manifold.ind;

N_ant       = Theta_manifold.N;
R_ant       = Theta_manifold.R;
coarseTheta = Theta_manifold.coarse;
AVG_table   = Theta_manifold.AVG_table;
MMV_table = Theta_manifold.MMV_table;

% %%%%%%%%%%%%%%%%%%% find the strongest AoA and ToA (match with gain) %%%%%%%%%%%%%%%%%%%%
Y = zeros(R_fft,N_ant);
Y((R_fft-N_fft)/2 + sub_loc, ant_loc) = y;
gains = ifft(ifftshift(Y,1), R_fft)*R_fft;
gains = gains(1:N_fft,:)*AVG_table';
gains = gains/N_sub/N_ant;
prob  = abs(gains).^2;

if pathNum==1
    [~,IDX] = sort(prob(:),'descend');
    IDX = IDX(1:40); % 玡碭程Τ
    theta_ind = ceil(IDX/N_fft);
    delay_ind = IDX-(theta_ind-1)*N_fft;
    delay_new = coarseDelay(delay_ind);
    
    for ii = 1:40    % 玡碭程Τ
        x = reshape(MMV_table(theta_ind(ii),:).', N_sub, N_ant);
        x = bsxfun(@times, x, exp(-1j*f_ind*delay_new(ii)));
        gain_new(ii) = (x(:)'*y(:))/(x(:)'*x(:));
        rp(ii) = sum(sum(abs(y - gain_new(ii) * x)));
    end
    [~,IDX] = min(abs(rp));
    % [~,IDX] = max(abs(gain_new));
    theta_ind = theta_ind(IDX);
    delay_ind = delay_ind(IDX);
    
    gain_new = gain_new(IDX);
    theta_new = coarseTheta(theta_ind);
    delay_new = coarseDelay(delay_ind);
    
    x = reshape(MMV_table(theta_ind,:).', N_sub, N_ant);
    x = bsxfun(@times, x, exp(-1j*f_ind*delay_new));
    y_r = y - gain_new * x;
    
else
    [~,IDX]   = max(prob(:));
    theta_ind = ceil(IDX/N_fft);
    delay_ind = IDX-(theta_ind-1)*N_fft;
    delay_new = coarseDelay(delay_ind);
    theta_new = coarseTheta(theta_ind);
    
    x = reshape(MMV_table(theta_ind,:).', N_sub, N_ant);
    x = bsxfun(@times, x, exp(-1j*f_ind*delay_new));
    gain_new = (x(:)'*y(:))/(x(:)'*x(:));
    y_r = y - gain_new * x;
    
end

%%
OSR_fft = floor(R_fft/N_fft);
OSR_ant = floor(R_ant/N_ant);
prob_grid = prob(1:OSR_fft:end, 1:OSR_ant:end);
res_inf_normSq_rot = max(prob_grid(:)*N_sub*N_ant);

end

function [delay, gain, theta, y_r] = NewtonRefine(y_r, delay, gain, theta, Delay_manifold, Theta_manifold, pathNum)

N_sub = Delay_manifold.N_sub;
f_ind = Delay_manifold.ind;

N_ant       = Theta_manifold.N;
coarseTheta = Theta_manifold.coarse;
AVG_table   = Theta_manifold.AVG_table;
MMV_table = Theta_manifold.MMV_table;

%% origin signal
theta_ind = theta+1;
x = reshape(MMV_table(theta_ind,:).', N_sub, N_ant);
x = bsxfun(@times, x, exp(-1j*f_ind*delay));
y = y_r + gain*x;

%% delay refine
dx_delay = bsxfun(@times, (-j*f_ind), x);
dx2_delay = bsxfun(@times, (-j*f_ind).^2, x);
der1 = -2*real(gain * y_r(:)'*dx_delay(:));
der2 = -2*real(gain * y_r(:)'*dx2_delay(:)) +2* abs(gain)^2*(dx_delay(:)'*dx_delay(:));

if der2 > 0
    delay_new = delay - der1/der2;
else
    delay_new = delay - sign(der1)*(1/4)*(2*pi/2048)*rand(1);
end

%% theta refine
X = repmat(exp(-1j*f_ind*delay_new),1,N_ant);
gains = mean((X' *y),1);
gains = gains*AVG_table';
gains = gains/N_sub/N_ant;
prob  = abs(gains).^2;

if pathNum==1
    [~,IDX] = sort(prob(:),'descend');
    theta_ind = IDX(1:40); % 玡碭程Τ
    
    for ii = 1:40    % 玡碭程Τ
        x = reshape(MMV_table(theta_ind(ii),:).', N_sub, N_ant);
        x = bsxfun(@times, x, exp(-1j*f_ind*delay_new));
        gain_new(ii) = (x(:)'*y(:))/(x(:)'*x(:));
        rp(ii) = sum(sum(abs(y - gain_new(ii) * x)));
    end
    [~,IDX] = max(abs(rp));
    % [~,IDX] = max(abs(gain_new));
    theta_ind = theta_ind(IDX);
    
    gain_new  = gain_new(IDX);
    theta_new = coarseTheta(theta_ind);
    
    x = reshape(MMV_table(theta_ind,:).', N_sub, N_ant);
    x = bsxfun(@times, x, exp(-1j*f_ind*delay_new));
    y_r_next = y - gain_new * x;
    
else
    [~,theta_ind] = max(prob(:));
    theta_new = coarseTheta(theta_ind);
    
    x = reshape(MMV_table(theta_ind,:).', N_sub, N_ant);
    x = bsxfun(@times, x, exp(-1j*f_ind*delay_new));
    gain_new = (x(:)'*y(:))/(x(:)'*x(:));
    y_r_next = y - gain_new * x;
end

if (y_r_next(:)'*y_r_next(:)) <= (y_r(:)'*y_r(:))
    delay = delay_new;
    gain = gain_new;
    theta = theta_new;
    y_r = y_r_next;
end

end

function [DelayList, GainList, ThetaList, y_r] = refineAll(y_r, R_s, R_c, DelayList, GainList, ThetaList, Delay_manifold, Theta_manifold)

K = length(DelayList);

for i = 1:R_c
    order = 1:K;
    
    for j = 1:K
        l = order(j);
        delay = DelayList(l);
        gain = GainList(l);
        theta = ThetaList(l);
        
        for kk = 1:R_s
            [delay_new,gain_new,theta_new,y_r] = NewtonRefine(y_r,delay,gain,theta,Delay_manifold,Theta_manifold, j);
        end
        
        DelayList(l) = delay_new;
        GainList(l) = gain_new;
        ThetaList(l) = theta_new;
    end
    
end

end

function [DelayList, GainList, ThetaList, y_r] = solveLeastSquares(y, DelayList, GainList, ThetaList, Delay_manifold, Theta_manifold)

N_sub = Delay_manifold.N_sub;
f_ind = Delay_manifold.ind;

N_ant = Theta_manifold.N;
MMV_table = Theta_manifold.MMV_table;

for ii = 1:size(ThetaList,1)
    theta_ind = ThetaList(ii)+1;
    x = reshape(MMV_table(theta_ind,:).', N_sub, N_ant);
    x = bsxfun(@times, x, exp(-1j*f_ind*DelayList(ii)));
    A(:,ii) = x(:);
end

GainList = (A'*A)\(A'*y(:));
y_r = y(:) - A*GainList;
y_r = reshape(y_r,N_sub,N_ant);

end
