
PLOT = 0; % plot environment and result or not, 0:no, 1:yes

%颜色设置，暂时没有考虑
color_anchor = [155 187  89]/256;  % green
color_agent  = [184 136 136]/256;  % red
color_ideal  = [247 150  70]/256;  % orange
showlegend = [];

color_error_all = [];
color_error_all = [color_error_all ; [255*ones(91,1) (235:-2:55)' (235:-2:55)']];
color_error_all = [color_error_all ; [(254:-2:75)' 55*ones(90,1) 55*ones(90,1)]]/256;

%%进入Indoor office文件夹中
cd(fileNames_cir_case)

AgentPositions
AnchorPositions
cd(['..\..\Extractor Simulation'])

