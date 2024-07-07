function [DelayList, GainList] = extractPath_DelayMMV(y, sub_loc, N_fft, f_ind, OSR_fft, R_s, R_c, pathNumRange)

if ~exist('pathNumRange','var'), pathNumRange = [1 10];
elseif isempty(pathNumRange), pathNumRange = [1 10]; end 

MinPathNum = pathNumRange(1);
MaxPathNum = pathNumRange(2);

[Delay_manifold] = preProcessMeasMat(y, N_fft, f_ind, OSR_fft);

DelayList = [];
GainList  = [];
y_r = y;
pathNum = 1;

while true
    
    % Coarse Detection State
    [delay_new, gain_new, y_r] = CoarseDetect(y_r, sub_loc, Delay_manifold);
    
    % Stopping criterion:
    if pathNum <= MaxPathNum
        if pathNum <= MinPathNum
            delay = delay_new;
            gain = gain_new;
        else
            break;
        end
    else
        break;
    end
    
    % Refinement State
    for i = 1:R_s
        [delay_new, gain_new, y_r] = NewtonRefine(y_r, delay, gain, Delay_manifold);
    end
    DelayList(pathNum,1) = delay_new;
    GainList(pathNum,:)  = gain_new;
    
    [DelayList, GainList, y_r] = refineAll(y_r, R_s, R_c, DelayList, GainList, Delay_manifold);
    [DelayList, GainList, y_r] = solveLeastSquares(y, DelayList, GainList, Delay_manifold);
    
    pathNum = pathNum + 1 ;
    
end

DelayList = DelayList(1:pathNum-1) ;
GainList = GainList(1:pathNum-1,:) ;

end

function [Delay_manifold] = preProcessMeasMat(y, N_fft, f_ind, OSR_fft)

%% Gird point of delay 
N_sub = size(y,1);
N_ant = size(y,2);
R_fft = OSR_fft*N_fft;
coarseDelay = 2*pi*(0:(R_fft-1))/R_fft*N_fft;  %2*pi*2048¤Á¦¨16384µ¥¥÷

Delay_manifold.N_sub  = N_sub;
Delay_manifold.N_fft  = N_fft;
Delay_manifold.N_ant  = N_ant;
Delay_manifold.R      = R_fft;
Delay_manifold.coarse = coarseDelay;
Delay_manifold.ind    = f_ind;

end

function  [delay_new, gain_new, y_r] = CoarseDetect(y, sub_loc, Delay_manifold, pathNum)

N_sub       = Delay_manifold.N_sub;
N_fft       = Delay_manifold.N_fft;
N_ant       = Delay_manifold.N_ant;
R_fft       = Delay_manifold.R;
coarseDelay = Delay_manifold.coarse;
f_ind       = Delay_manifold.ind;

%%%%%%%%%%%%%%%%%%% find the strongest AoA and ToA (match with gain) %%%%%%%%%%%%%%%%%%%%
Y = zeros(R_fft,N_ant);
Y((R_fft-N_fft)/2 + sub_loc,:) = y;
gains = ifft(ifftshift(Y,1), R_fft)*R_fft;
gains = gains(1:N_fft,:)/N_sub;
prob  = abs(gains).^2;

[~,delay_ind]   = max(sum(prob,2));
delay_new = coarseDelay(delay_ind);
gain_new = gains(delay_ind,:);

x = exp(-1j*f_ind*delay_new);
y_r = y - bsxfun(@times, gain_new, x);

%%
% OSR_fft = floor(R_fft/N_fft);
% prob_grid = prob(1:OSR_fft:end);
% res_inf_normSq_rot = max(prob_grid*N_sub);

end

function [delay, gain, y_r] = NewtonRefine(y_r, delay, gain, Delay_manifold)

N_sub = Delay_manifold.N_sub;
N_ant = Delay_manifold.N_ant;
f_ind = Delay_manifold.ind;

%% origin signal
x = exp(-1j*f_ind*delay);
y = y_r + bsxfun(@times, gain, x);

%% delay refine
% dx_delay  = (-j*f_ind).*x;
% dx2_delay = (-j*f_ind).^2.*x;
% der1 = -2*real(gain * y_r(:)'*dx_delay);
% der2 = -2*real(gain * y_r(:)'*dx2_delay) +2* abs(gain)^2*(dx_delay'*dx_delay);

dx_delay  = repmat((-j*f_ind).*x,    1, N_ant);
dx2_delay = repmat((-j*f_ind).^2.*x, 1, N_ant);
yy = bsxfun(@times,  gain,  conj(y_r));
gg = bsxfun(@times,abs(gain),dx_delay);

der1 = -2*real(yy(:).'*dx_delay(:));
der2 = -2*real(yy(:).'*dx2_delay(:)) + 2*(gg(:)'*gg(:));
           
if der2 > 0
    delay_new = delay - der1/der2;
else
    delay_new = delay - sign(der1)*(1/4)*(2*pi/2048)*rand(1);
end

x = exp(-1j*f_ind*delay_new);
gain_new = (x'*y)/(x'*x);
y_r_next = y - bsxfun(@times, gain_new, x);

if (y_r_next(:)'*y_r_next(:)) <= (y_r(:)'*y_r(:))
    delay = delay_new;
    gain = gain_new;
    y_r = y_r_next;
end

end

function [DelayList, GainList, y_r] = refineAll(y_r, R_s, R_c, DelayList, GainList, Delay_manifold)
 
K = length(DelayList);

for i = 1:R_c
    order = 1:K;
    
    for j = 1:K
        l = order(j);
        delay = DelayList(l);
        gain = GainList(l,:);
        
        for kk = 1:R_s
            [delay_new, gain_new, y_r] = NewtonRefine(y_r, delay, gain, Delay_manifold);
        end
        
        DelayList(l) = delay_new;
        GainList(l,:) = gain_new;
    end
    
end

end

function [DelayList, GainList, y_r] = solveLeastSquares(y, DelayList, GainList, Delay_manifold)

f_ind = Delay_manifold.ind;

A = exp(bsxfun(@times, -1j*f_ind , DelayList.'));
GainList = (A'*A)\(A'*y);
y_r = y - A*GainList;

end
