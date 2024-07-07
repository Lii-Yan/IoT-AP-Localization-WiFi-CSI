% Function: Generate a trajectory based on the initial point, direction, and steps
function [Trajectory_group, traj_idx_group, flag_wall] = angle_traj(angle, Agent_set, trueTrajectory_last, steps, step_size, distance_min)
%% Inputs:
% Agent_set: Valid points for correcting the trajectory
% trueTrajectory_last: Starting point of the trajectory
% angle: Direction in degrees
% steps: Number of steps to take
% step_size: Default is 0.2, the length of each step
% distance_min: Threshold distance for wall crossing

    angle_rad = angle * pi / 180;
    track_delta = step_size * (1:steps)';
    delta_x = track_delta .* cos(angle_rad);
    delta_y = track_delta .* sin(angle_rad);
    track = repmat(trueTrajectory_last, steps, 1);

    track(:, 2) = track(:, 2) + delta_y;
    track(:, 1) = track(:, 1) + delta_x;

    Min = [];
    Trajectory_group = [];
    traj_idx_group = [];
    for stepind = 1:steps
        [Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - track(stepind, 1)).^2 + (Agent_set(2, :) - track(stepind, 2)).^2));
        Min = [Min, Min_temp];
        Trajectory_group = [Trajectory_group; Agent_set(:, traj_idx_temp)'];
        traj_idx_group = [traj_idx_group, traj_idx_temp];
    end
    
    dis_all = [];
    for traj_i = 1:length(traj_idx_group)
        if traj_i == 1
            dis_temp = norm(Trajectory_group(traj_i, :) - trueTrajectory_last);
        else
            dis_temp = norm(Trajectory_group(traj_i, :) - Trajectory_group(traj_i - 1, :));
        end 
        dis_all = [dis_all, dis_temp];
    end
    
    flag_wall = 1;
    if max(dis_all) < distance_min
        flag_wall = 0;
    end
end
