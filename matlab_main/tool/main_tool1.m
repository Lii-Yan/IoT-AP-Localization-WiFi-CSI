% Data Generation
for tx = 1:10
    for rx_i = 1:6890
        rx_pos = Agent_set(:, rx_i);
        AOA_all(rx_i, tx) = AOA_generation(rx_pos, Anchor_set(:, tx));
    end
end

% Decision Matrix Generation: Final 6890*2*10 matrix
los_power = [];
load('feature_all.mat');
for tx = 1:10
    AOA_evaluate = feature(:, end-4:end, tx) / (2 * pi) * 360;
    temp = abs(AOA_evaluate - AOA_all(:, tx));
    [AOA_chazhi, AOA_index] = min(temp, [], 2);
    los_power(:, :, tx) = [AOA_chazhi, AOA_index == 1];
end

power = abs(feature(:, 1:5, :) + feature(:, 6:10, :) * 1j);

for tx = 1:10
    power(:, :, tx) = sort(power(:, :, tx), 2, 'descend');
end
power_max = reshape(power(:, 1, :), length(power), []);

feature_temp1 = [];
for tx = 1:10
    feature_temp = [];
    for i = 1:size(feature, 1)
        temp1 = [];
        temp = feature(i, :, tx);
        temp = reshape(temp, 5, 4);
        temp1(:, 1) = sqrt(temp(:, 1) .* temp(:, 1) + temp(:, 2) .* temp(:, 2));
        temp1(:, 2:3) = temp(:, 3:4);
        feature_temp(i, :) = reshape(temp1, 1, []);
    end
    feature_temp1(:, :, tx) = feature_temp;
end
feature_merge = feature_temp1;
clear feature feature_temp feature_temp1 tx

power_max_all = power_max;
los_power_all = los_power;