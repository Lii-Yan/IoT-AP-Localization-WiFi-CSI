function [A] = Steering(antPosition, aoa)

% generate steering vector ---
% input: antenna position [(x1, y1); (x2,y2); (x3,y3); (x4,y4) ... ]
% outpot: steering vector

X = antPosition(1,:);
Y = antPosition(2,:);

%% method 1
phi = aoa(:,1);   % vertical
theta = aoa(:,2); % horizontal

Delay = (sin(theta).*cos(phi))*(Y(1)-Y) + (cos(theta).*cos(phi))*(X(1)-X); 
A = exp(-1j*pi*Delay);

end

