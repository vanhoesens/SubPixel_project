%% Basic Input Parameters:
phantom_type = 'simindproj';
phantom_size = 128;
iteration_num = 10; % Number of MLEM iterations to process
sample_points = 120; % Number of angles to use in (back)projection
collimator_type = 'parallel';

% Initialize collimator parameters
hole_diameter = 0.5; % BOTH: Collimator hole diameter in cm
septal_length = 5; % BOTH: Collimator septa length in cm
septal_thickness = 2; % PARALLEL: septa thickness in cm
mu = 20.8; % BOTH: Attenuation coefficient of the collimator material (20.8cm^-1 for lead at 150 keV)
K = 0.28; % PARALLEL: Constant based on hole shape & geometry (0.24 for round holes in hex array)
septal_angle = 90; % PINHOLE: Angle in degrees of the pinhole

% Initialize the detector parameters
detector_elements = 32; % readjust when uncoupled from the body size
pixel_size = 0.22; % Absolute length of detector pixel in cm
body_size = [phantom_size phantom_size phantom_size];
% length_total = phantom_size^3;
% Create an array with the angles that are being imaged
steps = 360/(sample_points);
theta = 0:steps:360;
theta(end) = []; % this keeps to the number of sample points (no repeat at 360=0)
clear('steps')

%% Create the collimator
dist_array = 1:phantom_size;
dist_array = dist_array*pixel_size; % currently assumes there is no space between the pixels (NOT physical)

if strcmp(collimator_type,'pinhole')
    collimator = collimator_equations(collimator_type,hole_diameter,dist_array,septal_length,mu,'septal_angle',septal_angle);
    clear('septal_thickness','K','collimator_type')

elseif strcmp(collimator_type,'parallel')
    collimator = collimator_equations(collimator_type,hole_diameter,dist_array,septal_length,mu,'septal_thickness',septal_thickness,'K_value',K);
    clear('septal_angle','collimator_type')

end

%% Read in the phantom/geometry we are going to image
if strcmp(phantom_type,'shepplogan')
    og_image = phantom3d('Modified Shepp-Logan',phantom_size); 
    og_image = rescale(og_image,0,255);

    projections = projection(og_image,theta,body_size,collimator.resolution);
    
elseif strcmp(phantom_type,'kidneyxcat')
    location = 'C:\Users\svanhoesen\OneDrive - UMass Chan Medical School\Pt_folders\pt532\prepared_7\';
    right = Read_XCAT(append(location,'rkid_act_av.bin'),256);
    left = Read_XCAT(append(location,'lkid_act_av.bin'),256);
    lesion = Read_XCAT(append(location,'lesion1_act_av.bin'),256);
    og_image = right + left - lesion;
    og_image = trimdata(og_image,phantom_size,'Side','both','Dimension',1:3);
    og_image = permute(og_image,[1 3 2]);
    og_image = imrotate3(og_image,-90,[0 0 1],'crop');
    clear('right','left','lesion')

    projections = projection(og_image,theta,body_size,collimator.resolution);

elseif strcmp(phantom_type,'simindproj')
    % Read in projections from simind and process them without the original image available
    location = 'C:\Users\svanhoesen\OneDrive - Worcester Polytechnic Institute (wpi.edu)\matlab_testing\projections\';
    left = Read_XCAT(append(location,'lkd128_ppsc.prj'),128);
    right = Read_XCAT(append(location,'rkd128_ppsc.prj'),128);
    lesion = Read_XCAT(append(location,'ls1128_ppsc.prj'),128);
    projections = right + left - lesion;
    
    clear('right','left','lesion')

elseif strcmp(phantom_type,'simple')
    image_space = ones(body_size);
    [sag,cor,tra] = findND(image_space);
    center = [10 10 10];
    radius = 2;
    og_image = insert_3d_phantom(sag,cor,tra,center,radius);
    og_image = reshape(og_image,phantom_size,phantom_size,phantom_size);
    og_image = rescale(og_image,0,255);
    clear('sag','cor','tra','image_space')

    projections = projection(og_image,theta,body_size,collimator.resolution);

end

%% Call the MLEM_iteration script
recon_final = mlem_iteration(projections,theta,body_size,collimator,iteration_num,'plot_robust',true);





% % % Attempt the FFT method mentioned in Sorenson pg 398 (only for known og image)
% % fft3d_og = fftn(og_image);
% % fft3d_recon = fftn(recon_final);
% % fft3d_ratio = fft3d_og./fft3d_recon;
% % 
% % correction = ifftn(fft3d_ratio);
% % image_test = convn(fft3d_recon,correction,'same');
% % 
% % figure()
% % montage(uint16(og_image),DisplayRange=[])
% % title('OG Image')
% % 
% % figure()
% % montage(uint16(recon_final),DisplayRange=[])
% % title('Recon Image')
% % 
% % figure()
% % montage(uint16(image_test),DisplayRange=[])
% % title('Convolution Filtered Image')
% % 
% % figure()
% % montage(uint16(correction),DisplayRange=[])
% % title('Convolution Filter')

