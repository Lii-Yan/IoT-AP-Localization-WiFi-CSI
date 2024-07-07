Trajectory_group = Trajectory_group_temp; traj_idx_group = traj_idx_group_temp;

%% Overall Prediction
[AOA_estimate, traj_index, AOA_estimate_no] = AOA_pre_1(ad, rand_flag, traj_idx_group, tx, AOA_all, feature_merge, power_max_all, los_power_all);
Trajectory_group_plot = Trajectory_group; plot_flag = 1; plot_tool;

for name_i = 1:5
    if isempty(AOA_estimate)
        disp([name_list{name_i}, ' has no available points']);
        continue;
    end
    variableName = ['AOA_estimate', '.', name_list{name_i}];
    AOA_estimate_selected = eval(['vertcat(', variableName, ')']);
    AOA_true = [AOA_estimate.true]';
    chazhi = min(360 - abs(AOA_estimate_selected - AOA_true), abs(AOA_estimate_selected - AOA_true));
    
    if ad == 1
        disp(['ad_', name_list{name_i}, ' AOA estimation angle error is ', sprintf('%.2f', mean(chazhi)), '°']);
    else
        disp([name_list{name_i}, ' AOA estimation angle error is ', sprintf('%.2f', mean(chazhi)), '°']);
    end
end

cmdWinSize = get(0, 'CommandWindowSize'); disp(repmat('-', 1, cmdWinSize(1) - 1));