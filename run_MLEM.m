%% Basic Input Parameters:
phantom_type = 'shepp-logan';
phantom_size = 64;
iteration_num = 5; % Number of MLEM iterations to process
sample_points = 60; % Number of angles to use in (back)projection
collimator_type = 'parallel';

% Initialize collimator parameters
hole_diameter = 0.25; % BOTH Collimator hole diameter in cm
septal_length = 5; % BOTH Collimator septa length in cm
septal_thickness = 2; % PARALLEL septa thickness in cm
mu = 20.8; % BOTH Attenuation coefficient of the collimator material (20.8cm^-1 for lead at 150 keV)
K = 0.28; % PARALLEL Constant based on hole shape & geometry (0.24 for round holes in hex array)
septal_angle = 60; % PINHOLE Angle in degrees of the pinhole

% Initialize the detector parameters
detector_elements = 60; % readjust when uncoupled from the body size
pixel_size = 0.22; % Absolute length of detector pixel in cm
body_size = [phantom_size phantom_size phantom_size];
body_length = phantom_size;
lenth_total = phantom_size^3;
% Create an array with the angles that are being imaged
steps = 360/(sample_points);
theta = 0:steps:360;
theta(end) = []; % this keeps to the number of sample points (no repeat at 360=0)

%% Read in the phantom/geometry we are going to image
if strcmp(phantom_type,'shepp-logan')
    og_image = phantom3d('Modified Shepp-Logan',phantom_size); 
    og_image = rescale(og_image,0,255);
    
elseif strcmp(phantom_type,'kidney-xcat')
    location = 'C:\Users\svanhoesen\OneDrive - UMass Chan Medical School\Pt_folders\pt333\prepared_7\';
    right = Read_XCAT(append(location,'rkid_act_av.bin'),256);
    left = Read_XCAT(append(location,'lkid_act_av.bin'),256);
    og_image = right + left;
    og_image = trimdata(og_image,phantom_size,'Side','both','Dimension',1:3);
    
elseif strcmp(phantom_type,'simple')
    image_space = ones(body_size);
    [sag,cor,tra] = findND(image_space);
    center = [30 30 30];
    radius = 3;
    og_image = insert_3d_phantom(sag,cor,tra,center,radius);
    og_image = reshape(og_image,body_length,body_length,body_length);
    og_image = rescale(og_image,0,255);

end

%% Create the collimator
dist_array = 1:body_length;
dist_array = dist_array*pixel_size; % currently assumes there is no space between the pixels (NOT physical)

if strcmp(collimator_type,'pinhole')
    collimator = collimator_equations(collimator_type,hole_diameter,dist_array,septal_length,mu,'septal_angle',septal_angle);

elseif strcmp(collimator_type,'parallel')
    collimator = collimator_equations(collimator_type,hole_diameter,dist_array,septal_length,mu,'septal_thickness',septal_thickness,'K_value',K);

end

%% Call the MLEM_iteration script
recon_final = mlem_iteration(og_image,theta,body_size,collimator,iteration_num);





