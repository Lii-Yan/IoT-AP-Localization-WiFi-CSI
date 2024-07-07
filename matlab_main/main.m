clear; close all; clc

%% Add Sub-function Paths
environment = 'Indoor office'; 
addpath(['Wireless Insite/', environment]) % Path to indoor office environment
addpath(['CSI process']) % Path to CSI parameter extraction functions
addpath('tool'); % Path to various utility functions

plot_all = 0; plot_tool_flag = 1; % Plotting settings for debugging
SetPlot
AgentPositions
AnchorPositions
main_tool1; % Generate some required data

step_size = 0.2;
distance_min = 0.25;
direction = 0;
flag_wall = 1;

%% Scenario 1: Clear LOS Path
% Trajectory A1
index_plot = 0;
rand_flag = 0; % 0: Use original data; 1: Use other data
name_list = {'RSS', 'time', 'baseline', 'near', 'network', 'network'};
tx = 9;
start = [-1.17, -11.55, 1.2]';
[Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - start(1)).^2 + (Agent_set(2, :) - start(2)).^2));
trueTrajectory_start = Agent_set(:, traj_idx_temp)';
AOA_angle = 0; steps = 20;
[Trajectory_group_temp, traj_idx_group_temp, flag_wall] = angle_traj(AOA_angle, Agent_set, trueTrajectory_start, steps, step_size, distance_min);
ad = 0; output_temp; old_traj = length(traj_index); saveas(gcf, 'png_pdf/Scenes_A1.pdf', 'pdf');
ad = 1; output_temp; new_traj = length(traj_index);
disp([num2str(new_traj / old_traj * 100), '%']);

% Trajectory A2
rand_flag = 0; % Retrack trajectory
name_list = {'RSS', 'time', 'baseline', 'near', 'network', 'network'};
tx = 9;
start = [1.89, -7.65, 1.2]';
[Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - start(1)).^2 + (Agent_set(2, :) - start(2)).^2));
trueTrajectory_start = Agent_set(:, traj_idx_temp)';
AOA_angle = -90; steps = 20;
[Trajectory_group_temp, traj_idx_group_temp, flag_wall] = angle_traj(AOA_angle, Agent_set, trueTrajectory_start, steps, step_size, distance_min);
ad = 0; output_temp; old_traj = length(traj_index); saveas(gcf, 'png_pdf/Scenes_A2.pdf', 'pdf');
ad = 1; output_temp; new_traj = length(traj_index);
disp([num2str(new_traj / old_traj * 100), '%']);

%% Scenario 2: Clear LOS Path with Some Distance
% Trajectory B1
rand_flag = 0; % Retrack trajectory
name_list = {'RSS', 'time', 'baseline', 'near', 'network', 'network'};
tx = 9;
start = [-1.5, -19.2, 1.2]'; AOA_angle = 0; steps = 20;
[Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - start(1)).^2 + (Agent_set(2, :) - start(2)).^2));
trueTrajectory_start = Agent_set(:, traj_idx_temp)';
[Trajectory_group_temp, traj_idx_group_temp, flag_wall] = angle_traj(AOA_angle, Agent_set, trueTrajectory_start, steps, step_size, distance_min);
ad = 0; output_temp; old_traj = length(traj_index); saveas(gcf, 'png_pdf/Scenes_B1.pdf', 'pdf');
ad = 1; output_temp; new_traj = length(traj_index);
disp([num2str(new_traj / old_traj * 100), '%']);

% Trajectory B2
rand_flag = 0; % Retrack trajectory
name_list = {'RSS', 'time', 'baseline', 'near', 'network', 'network'};
tx = 9;
start = [3.85, -2.8, 1.2]'; AOA_angle = -90; steps = 20;
[Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - start(1)).^2 + (Agent_set(2, :) - start(2)).^2));
trueTrajectory_start = Agent_set(:, traj_idx_temp)';
[Trajectory_group_temp, traj_idx_group_temp, flag_wall] = angle_traj(AOA_angle, Agent_set, trueTrajectory_start, steps, step_size, distance_min);
ad = 0; output_temp; old_traj = length(traj_index); saveas(gcf, 'png_pdf/Scenes_B2.pdf', 'pdf');
ad = 1; output_temp; new_traj = length(traj_index);
disp([num2str(new_traj / old_traj * 100), '%']);

%% Scenario 3: LOS Path Blocked by Obstacles
% Glass Door Blocking C1
rand_flag = 0; % Retrack trajectory
name_list = {'RSS', 'time', 'baseline', 'near', 'network', 'network'};
tx = 9;
start = [6.2, -3.8, 1.2]'; AOA_angle = 0; steps = 20;
[Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - start(1)).^2 + (Agent_set(2, :) - start(2)).^2));
trueTrajectory_start = Agent_set(:, traj_idx_temp)';
[Trajectory_group_temp, traj_idx_group_temp, flag_wall] = angle_traj(AOA_angle, Agent_set, trueTrajectory_start, steps, step_size, distance_min);
old_traj = length(traj_idx_group_temp);
ad = 0; output_temp; old_traj = length(traj_index); saveas(gcf, 'png_pdf/Scenes_C1.pdf', 'pdf');
ad = 1; output_temp; new_traj = length(traj_index);
disp([num2str(new_traj / old_traj * 100), '%']);

% Glass Door Blocking C2
rand_flag = 0; % Retrack trajectory
name_list = {'RSS', 'time', 'baseline', 'near', 'network', 'network'};
tx = 9;
start = [5, -10.9 - 0.2, 1.2]'; AOA_angle = 0; steps = 20;
[Min_temp, traj_idx_temp] = min(sqrt((Agent_set(1, :) - start(1)).^2 + (Agent_set(2, :) - start(2)).^2));
trueTrajectory_start = Agent_set(:, traj_idx_temp)';
[Trajectory_group_temp, traj_idx_group_temp, flag_wall] = angle_traj(AOA_angle, Agent_set, trueTrajectory_start, steps, step_size, distance_min);
old_traj = length(traj_idx_group_temp);
ad = 0; output_temp; old_traj = length(traj_index); saveas(gcf, 'png_pdf/Scenes_C2.pdf', 'pdf');
ad = 1; output_temp; new_traj = length(traj_index);
disp([num2str(new_traj / old_traj * 100), '%']);
