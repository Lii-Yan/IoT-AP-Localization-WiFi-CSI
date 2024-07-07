%
% Function to calculate the Angle of Arrival (AOA)
function [AOA] = AOA_generation(Rx_pos, Tx_pos)
% atan2(Y,X) returns angle in the range (-pi, pi)
% Plane angle calculation
rx = Rx_pos(1:2)'; 
tx = Tx_pos(1:2)';
AOA = atan2(tx(2) - rx(2), tx(1) - rx(1));
AOA = rad2deg(AOA);

if (AOA < 0)
    AOA = 360 + AOA;
end
end
