function [Agent_set, p] = agent_pos(Agent_set, initial, len, inter)
% agent_pos: Generates agent positions in a grid pattern.
% Generates agent positions spaced uniformly in a grid pattern within a specified range.

% Calculate the number of subdivisions based on the interval
inter2 = round(1 / inter);

% Generate column 1 and column 2 coordinates for the grid
col_1 = repmat([0:len(1) * inter2]', floor(len(2) * inter2) + 1, 1) * inter + initial(1);
col_2 = repmat([0:len(2) * inter2], floor(len(1) * inter2) + 1, 1) * inter + initial(2);

% Concatenate the grid coordinates to Agent_set
Agent_set = [Agent_set; [col_1 col_2(:)]];

% Compute the number of points generated
p = size(col_1, 1);

% Example usage scenario:
% Agent_set = [];
% inter = 0.2;
% [Agent_set, p] = agent_pos(Agent_set, [4.2, -22.6], [2.4, 3.8], inter); % Example 1
% [Agent_set, p] = agent_pos(Agent_set, [-5.7, -19.4], [9.5, 0.5], inter); % Example 2
end
