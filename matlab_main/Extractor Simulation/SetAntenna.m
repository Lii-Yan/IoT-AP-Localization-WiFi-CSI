
%% setting for WiFi channel wifichannel
for_save = '''sim''';
for_plot = cellstr('sim'); 

noise_level = 1e-8;
for_save    = [for_save, ',''noise_level''']; 

N_fft    = 64;                                              % FFT point
f_subcar = 312.5e3;                                         % subcarrier spacing载波间隔
f_sample = f_subcar*N_fft;                                  % bandwidth
n_sample = [-N_fft/2:N_fft/2-1].'/N_fft;                    % n/N = [-32:-1 0:31] / 64

sub_num = 52;                                               % number of subcarrier
sub_loc = [N_fft/2-ceil(sub_num/2)+1 : N_fft/2 ...          % subcarrier index
               N_fft/2+2 : N_fft/2+floor(sub_num/2)+1];   

clear f_subcar sub_num


%% 2D ideal triangular antenna estimation
antPosition = [ [       0        ;        0       ], ...
                [ cos(60/180*pi) ; -sin(60/180*pi)], ...
                [-cos(60/180*pi) ; -sin(60/180*pi)] ];      % antenna position (unit: half-wavelength)
            
AZ_Table = [0:1:360-1];                                     % azimuth 
EL_Table = 0;                                               % elevation

a = repmat(EL_Table,length(AZ_Table),1);                    % all AOA = [elevation azimuth]
AOATable = [];
AOATable(:,1) = a(:);
AOATable(:,2) = repmat(AZ_Table',length(EL_Table),1);
phase_table = Steering(antPosition, AOATable/180*pi);

set_triangular_2D.Nr          = size(antPosition,2);        % number of antenna
set_triangular_2D.antPosition = antPosition;                % for generating channel
set_triangular_2D.AOATable    = AOATable;                   % for estimation
set_triangular_2D.phase_table = phase_table;                % for estimation

for_save = [for_save, ',''est_triangular_2D'''];            % for save
for_plot = cellstr([for_plot 'est_triangular_2D']);

%% 3D ideal triangular antenna  estimation
antPosition = [ [       0        ;        0       ], ...
                [ cos(60/180*pi) ; -sin(60/180*pi)], ...
                [-cos(60/180*pi) ; -sin(60/180*pi)] ];      % antenna position (unit: half-wavelength)

AZ_Table = [0:1:360-1];                                     % azimuth 
EL_Table = [0:5:90];                                        % elevation

a = repmat(EL_Table,length(AZ_Table),1);                    % all AOA = [elevation azimuth]
AOATable = [];
AOATable(:,1) = a(:);
AOATable(:,2) = repmat(AZ_Table',length(EL_Table),1);
phase_table = Steering(antPosition, AOATable/180*pi);

set_triangular_3D.Nr          = size(antPosition,2);        % number of antenna
set_triangular_3D.antPosition = antPosition;                % for generating channel
set_triangular_3D.AOATable    = AOATable;                   % for estimation
set_triangular_3D.phase_table = phase_table;                % for estimation

for_save   = [for_save, ',''est_triangular_3D'''];          % for save
for_plot   = cellstr([for_plot 'est_triangular_3D']);

%%
clear a antPosition AOATable AZ_Table EL_Table phase_table

