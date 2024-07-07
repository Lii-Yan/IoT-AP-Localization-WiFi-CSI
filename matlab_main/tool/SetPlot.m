




 
PLOT = 1; % plot environment and result or not
if PLOT==1
%     d = figure(1); clf; set(d,'WindowStyle','docked')
end

color_anchor = [155 187 89]/256; % green
color_agent = [184 136 136]/256; % red
color_ideal = [247 150 70]/256;  % orange
color_tri = [79 129 189]/256;    % blue
color_phone = [111 183 183]/256; % light blue

color_1 = [247 150 70]/256;  % orange
color_2 = [0 102 204]/256;  % blue
color_3 = [206 0  0]/256; % light blue
color_4 = [ 0  145  0 ]/256; % green


showlegend = [];

% figure(99)
% err_all = (0:180)'/180;
% color_error = [err_all 1-err_all  1-err_all];
% for ii = 0:180
%     plot(ii,1, 's', 'MarkerSize', 6, 'Color', color_error(ii+1,:),'MarkerFaceColor', color_error(ii+1,:)); hold on;
% end


color_error_all = [];
color_error_all = [color_error_all ; [255*ones(91,1) (235:-2:55)' (235:-2:55)']];
color_error_all = [color_error_all ; [(254:-2:75)' 55*ones(90,1) 55*ones(90,1)]]/256;
% figure
% for e = 0:180
%     plot(0,e,'s', 'color', color_error_all(e+1,:), 'markerfacecolor', color_error_all(e+1,:)); hold on
% end
% hold off

