%%
%rx的位置
Agent_set = [];

inter = 0.2;
[Agent_set,Agent_area(1)] = agent_pos(Agent_set, [4.2, -22.6], [2.4, 3.8], inter);%1
[Agent_set,Agent_area(2)] = agent_pos(Agent_set, [-5.7, -19.4], [9.5, 0.5], inter);%2
[Agent_set,Agent_area(3)] = agent_pos(Agent_set, [-3.75, -18.4], [0.5, 5.5], inter);%3
[Agent_set,Agent_area(4)] = agent_pos(Agent_set, [0.15, -18.7], [0.6, 4.8], inter);%4
[Agent_set,Agent_area(5)] = agent_pos(Agent_set, [4.1, -18.4], [1, 6], inter);%5
[Agent_set,Agent_area(6)] = agent_pos(Agent_set, [-2.97, -13.55], [3.8, 4.2], inter);%6
[Agent_set,Agent_area(7)] = agent_pos(Agent_set, [1, -12], [2.2, 3.4], inter);%7
[Agent_set,Agent_area(8)] = agent_pos(Agent_set, [-2.3, -9], [2.5, 8.2], inter);%8
[Agent_set,Agent_area(9)] = agent_pos(Agent_set, [0.6, -2.7], [2.5, 2.7], inter);%9
[Agent_set,Agent_area(10)] = agent_pos(Agent_set, [3.45, -10.2], [1, 8.5], inter);%10

[Agent_set,Agent_area(11)] = agent_pos(Agent_set, [4.7, -2.35], [2, 2.2], inter);%11
[Agent_set,Agent_area(12)] = agent_pos(Agent_set, [7.2, -2.35], [4, 0.5], inter);%12
[Agent_set,Agent_area(13)] = agent_pos(Agent_set, [11.7, -3.1], [6, 2], inter);%13
[Agent_set,Agent_area(14)] = agent_pos(Agent_set, [14.1, -0.6], [5.6, 0.4], inter);%14
[Agent_set,Agent_area(15)] = agent_pos(Agent_set, [18.4, -6.7], [1, 4.5], inter);%15
[Agent_set,Agent_area(16)] = agent_pos(Agent_set, [21.4, -6.7], [1, 6.5], inter);%16
[Agent_set,Agent_area(17)] = agent_pos(Agent_set, [19.9, -3.4], [1, 1], inter);%17
[Agent_set,Agent_area(18)] = agent_pos(Agent_set, [15.66, -11.1], [1, 7.5], inter);%18
[Agent_set,Agent_area(19)] = agent_pos(Agent_set, [17.2, -7.95], [2.5, 1], inter);%19
[Agent_set,Agent_area(20)] = agent_pos(Agent_set, [20.1, -11.1], [1.5, 4], inter);%20

[Agent_set,Agent_area(21)] = agent_pos(Agent_set, [11.7, -11.2], [3.5, 1.5],inter);%21
[Agent_set,Agent_area(22)] = agent_pos(Agent_set, [11.3, -9.35], [4, 1], inter);%22
[Agent_set,Agent_area(23)] = agent_pos(Agent_set, [11.3, -4.47], [4, 1], inter);%23
[Agent_set,Agent_area(24)] = agent_pos(Agent_set, [14.2, -7.9], [1, 3], inter);%24
[Agent_set,Agent_area(25)] = agent_pos(Agent_set, [11.4, -7.9], [1, 3], inter);%25
[Agent_set,Agent_area(26)] = agent_pos(Agent_set, [4.8, -11.1], [5.5, 2], inter);%26
[Agent_set,Agent_area(27)] = agent_pos(Agent_set, [-5.8, -22.5], [1.5, 2.5], inter);%27
[Agent_set,Agent_area(28)] = agent_pos(Agent_set, [-3, -22.5], [3.5, 2.5], inter);%28
[Agent_set,Agent_area(29)] = agent_pos(Agent_set, [1, -22.5], [2, 2.5], inter);%29
[Agent_set,Agent_area(30)] = agent_pos(Agent_set, [1, -5.1], [2, 2], inter);%30

[Agent_set,Agent_area(31)] = agent_pos(Agent_set, [4.8, -4.4], [6,1], inter);%31
[Agent_set,Agent_area(32)] = agent_pos(Agent_set, [4.8, -6.8], [6,1], inter);%32
[Agent_set,Agent_area(33)] = agent_pos(Agent_set, [9.4, -5.35], [1.5, 0.5], inter);%33
[Agent_set,Agent_area(34)] = agent_pos(Agent_set, [4.8, -5.35], [1.5, 0.5], inter);%34
[Agent_set,Agent_area(35)] = agent_pos(Agent_set, [4.8, -8.75], [3,1.5], inter);%35
[Agent_set,Agent_area(36)] = agent_pos(Agent_set, [22.8, -3.6], [1,3.5], inter);%36
[Agent_set,Agent_area(37)] = agent_pos(Agent_set, [23.5, -6.2], [2.5, 2], inter);%37
[Agent_set,Agent_area(38)] = agent_pos(Agent_set, [21.9, -11.25], [4,4], inter);%38
[Agent_set,Agent_area(39)] = agent_pos(Agent_set, [7, -0.5], [4, 0.5], inter);%39
[Agent_set,Agent_area(40)] = agent_pos(Agent_set, [8, -7.8], [2.5, 0.6], inter);%40

[Agent_set,Agent_area(41)] = agent_pos(Agent_set, [0.29, -6.18], [2, 0.8], inter);%41
[Agent_set,Agent_area(42)] = agent_pos(Agent_set, [0.29, -7.5], [1, 1.2], inter);%42
[Agent_set,Agent_area(43)] = agent_pos(Agent_set, [0.29, -8.45], [2, 0.8], inter);%43

Agent_set(:,3) = 1.2;
Agent_set = Agent_set.';
agentNum = size(Agent_set,2);

%% 

%place=input("输入：");
if plot_all==1
% figure(1)
place=0;
if place==0
    plot(Agent_set(1,:), Agent_set(2,:), 's', 'MarkerSize', 5, 'Color', color_agent, 'MarkerFaceColor', color_agent); hold on
else
    plot(Agent_set(1,place), Agent_set(2,place), 's', 'MarkerSize', 5, 'Color', color_agent, 'MarkerFaceColor', color_agent); hold on
end
showlegend = cellstr(['Agent'  showlegend]);
fig = get(gca,'Children');
index = sort(find(~cellfun(@isempty,showlegend)),'descend');
legend(fig(index),cellstr(showlegend(index)),'Location','northeastoutside')


end
clear fig index inter 

