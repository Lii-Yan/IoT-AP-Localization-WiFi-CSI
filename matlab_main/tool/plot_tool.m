set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultTextFontName', 'Times New Roman');
%plot 轨迹图
if plot_tool_flag==1
plot_all=1;
subplot(2,2,[1,2])

SetPlot
AgentPositions
AnchorPositions
hold on

scatter(Trajectory_group_plot(:, 1),Trajectory_group_plot(:, 2),10,'filled') 
hold on 
if exist('AP_location_cu')
    scatter(AP_location_cu(1),AP_location_cu(2),20,'filled')
end

axis([-10,30,-30,10])
subplot(2,2,[3,4])
close all;figure(3)
% 获取当前子图的句柄
subplot_handle = gca;

% 清除子图上的图像
cla(subplot_handle);
if (plot_flag==1)&(~isempty(traj_index))
    
    % 真实AOA图
      AOA_traj=AOA_all(traj_index,tx);
      scatter(1:length(AOA_traj),AOA_traj,30,[255 192 0]/255,'filled');
    hold on 
    % 预测AOA
        AOA_network=[AOA_estimate.network];
        scatter(1:length(AOA_network),AOA_network ,30,[128 0 128]/255,'filled');
        grid on 
        hold on 
        set(gca,'YLim',[0 360])
        set(gca,'XLim',[0,length(AOA_traj)])
      
        
        
   % 散点图
        real_AOA=feature_merge(traj_index,end-4:end,tx)/pi*180;
%         color_map=[149 77 0;195 0 0;255 81 81;254 81 81;254 170 170]/255;
%         % color_map=[0.70 0.03 0.03;0.77 0.35 0.35;0.81 0.52 0.52;0.79 0.61 0.61;0.80 0.71 0.71];
%         % color_map=[0.70 0.03 0.03;0.77 0.35 0.35;0.81 0.52 0.52;0.79 0.61 0.61;0.80 0.71 0.71];
%         for i_real=1:5
%             hold on
%         scatter(1:size(real_AOA,1),real_AOA(:,i_real),15,color_map(i_real,:));
%         end
        
        % 生成灰阶色图
        num_colors = 5; % 颜色数量
        color_map = zeros(num_colors, 3); % 颜色映射矩阵
        for i_real = 1:num_colors
            gray_value = (i_real - 1) / (num_colors - 1); % 灰度值范围从 0 到 1
            color_map(i_real, :) = [gray_value, gray_value, gray_value]; % 灰阶颜色
        end
        
        % 绘制散点图
        for i_real = 1:num_colors
            hold on
            scatter(1:size(real_AOA,1), real_AOA(:,i_real), 15, color_map(i_real,:));
        end


        
        if ad==0
            % 添加方框标注
            AOA_estimate_ad = [AOA_estimate.ad];
            AOA_estimate_true = [AOA_estimate.true];
            for i = 1:length(AOA_estimate)
                hold on
                if AOA_estimate_ad(i) == 1
                    plot(i, AOA_estimate_true(i), 'Square', 'LineWidth', 1, 'MarkerSize', 15, 'Color', 'r');
                end
            end
        end
        xlabel('steps','Position', [7.5, -15, 0]),ylabel('AOA (deg)')
%         if  ismember(index_plot+1, [1,4,6])
        legend('Groudtruth', 'Predict');
        set(gca, 'Box', 'on'); % 设置边框为黑色
        set(findall(gcf, '-property', 'FontSize'), 'FontSize', 20); % 修改字体大小为 8 磅
%         xlabel('Your X Label', 'FontSize', 20);
%         end
end
end
% if ad == 0 
% index_plot=index_plot+1;
% saveas(gcf,['C:\Users\dell\Desktop\IOT\img\matfig\',num2str(index_plot),'.png']);  
% end
% close all 
plot_flag=0;
% 
% AOA_estimate_selected= eval(['vertcat(', variableName, ')']);
% if ~isempty(AOA_estimate)
% AOA_true=[AOA_estimate.true]';
% chazhi=min(360-abs(AOA_estimate_selected-AOA_true),abs(AOA_estimate_selected-AOA_true));
% disp([name_list{name_i},'AOA估计角度误差为',sprintf('%.2f', mean(chazhi)),'°']);
% x=input('按回车继续代码');
% end

