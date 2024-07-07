function [AOA_estimate, traj_index, AOA_estimate_no] = AOA_pre_1(ad, rand_flag, traj_idx, tx, AOA_all, feature_merge, power_max_all, los_power_all)
    % For normalization
    feature_python = [];
    traj_idx_all = traj_idx;
    for step = 1:(length(traj_idx_all) - 5 + 1)
        traj_idx = traj_idx_all(step:(step + 4)); 
        AOA = AOA_all(traj_idx(3), tx);
        feature = guiyihua_1(feature_merge, traj_idx, rand_flag, tx); % Normalize each group
        feature_python(:,:,:,step) = feature;
    end

    feature = feature_python;
    file_path = fullfile('..', 'traj/traj_flag.json');
    if exist(file_path, 'file') > 0
        delete(file_path)
    end
    AOA_estimate = [];
    AOA_estimate_no = [];
    traj_index = [];

    AOA = AOA_all(traj_idx_all, tx);
    save(fullfile('..', 'traj','traj_temp.mat'), 'feature', 'traj_idx', 'AOA', 'tx');
    
    bat_file = fullfile('..', 'run_main1.bat');
    if exist(bat_file, 'file') == 0
        error('The batch file does not exist: %s', bat_file);
    end
    
    system(bat_file);

    % Important check to see if the process has finished
    while true
        if exist(file_path, 'file') > 0 
            AOA_result_all = jsondecode(fileread(fullfile('..', 'traj/traj.json')));
            while true
                delete(file_path)
                if exist(file_path, 'file') == 0 
                    break
                end
            end
            break
        end
    end

    % MATLAB
    if (length(traj_idx_all) - 5 + 1) ~= size(AOA_result_all, 1)
        disp('There may be an error, the number of predictions and inputs are not equal')
        disp(length(AOA_result_all))
    end

    for step = 1:(length(traj_idx_all) - 5 + 1)
        traj_idx = traj_idx_all(step:(step + 4)); 
        AOA_result = AOA_result_all(step, 1);
        if ad == 1
            if AOA_result.ad == 1
                AOA_estimate = [AOA_estimate, AOA_result];
                traj_index = [traj_index, traj_idx_all(step + 2)];
            else
                AOA_estimate_no = [AOA_estimate_no, AOA_result];
            end
        else
            AOA_estimate = [AOA_estimate, AOA_result];
            traj_index = [traj_index, traj_idx_all(step + 2)];
        end
    end
end
