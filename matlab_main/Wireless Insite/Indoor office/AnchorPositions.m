%%
%十个Tx的位置
Anchor_set = [];             

Anchor_set(:,1) = [0.2,  -1.6]'; 
Anchor_set(:,2) = [3,     -1.6]';
Anchor_set(:,3) = [11.5,  -1.9]';
Anchor_set(:,4) = [19.4,  -0.7]';
Anchor_set(:,5) = [22,    -0.7]';
Anchor_set(:,6) = [11.8,  -8.7]';
Anchor_set(:,7) = [15.8,  -7.8]';
Anchor_set(:,8) = [20.2,    -8]';
Anchor_set(:,9) = [0.5, -9.5]';
Anchor_set(:,10) = [0.6, -14]';

Anchor_set(3,:) = 2.62;

anchorNum = size(Anchor_set,2);
if plot_all==1
% figure(1);
plot(Anchor_set(1,:), Anchor_set(2,:), '.', 'MarkerSize', 36, 'Color', color_anchor);
for aa = 1:anchorNum
    text(Anchor_set(1,aa),Anchor_set(2,aa),num2str(aa), 'HorizontalAlignment', 'center');        
end

showlegend = [cell(1,anchorNum)  'Anchor'  showlegend];
fig = get(gca,'Children');
index = sort(find(~cellfun(@isempty,showlegend)),'descend');
legend(fig(index),cellstr(showlegend(index)),'Location','northeastoutside')

if exist('tx')
plot(Anchor_set(1,tx), Anchor_set(2,tx), 'Squre','LineWidth',4, 'MarkerSize', 25, 'Color', [160	32 240]/255);
else
plot(Anchor_set(1,1), Anchor_set(2,1), 'Squre','LineWidth',4, 'MarkerSize', 25, 'Color', [160	32 240]/255);
end

showlegend = ['select-Anchor',  showlegend];
fig = get(gca,'Children');
index = sort(find(~cellfun(@isempty,showlegend)),'descend');
legend(fig(index),cellstr(showlegend(index)),'Location','northeastoutside')




All_point = [Anchor_set Agent_set];
axis([min(All_point(1,:))-0.6, max(All_point(1,:))+0.6, min(All_point(2,:))-0.6, max(All_point(2,:))+0.6])
axis equal
end 
clear aa fig index All_point 







