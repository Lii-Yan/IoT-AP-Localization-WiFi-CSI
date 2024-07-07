function [AP_location] = LS(traj_index, AOA_temp, Agent_set)
% LS: Least Squares method for estimating Access Point (AP) location.
% Computes the AP location based on trajectory indices, estimated AOA, and
% agent positions using least squares optimization.

% Convert AOA to radians
AOA = AOA_temp;
agent = Agent_set(1:2, traj_index)';
A = zeros(length(agent), 2);
A(:, 1) = tan(AOA / 180 * pi);  % Compute tangent of AOA converted to radians
b = agent(:, 1)' .* tan(AOA / 180 * pi) - agent(:, 2)';  % Compute b vector

Singular = 0;
if (rank(A) < min(size(A)))
    Singular = 1;  % Indicates singularity if rank is less than minimum size
    AP_location = 1;  % Placeholder for singular case
else
    AP_location = inv(A' * A) * (A' * b);  % Compute AP location using LS method
end
