%% Basic Input Parameters:
phantom_type = 'simple';
phantom_size = 32;
iteration_num = 3; % Number of MLEM iterations to process
sample_points = 30; % Number of angles to use in (back)projection
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
body_length = phantom_size;
% length_total = phantom_size^3;
% Create an array with the angles that are being imaged
steps = 360/(sample_points);
theta = 0:steps:360;
theta(end) = []; % this keeps to the number of sample points (no repeat at 360=0)
clear('steps')

%% Create the collimator
dist_array = 1:body_length;
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

elseif strcmp(phantom_type,'simple')
    image_space = ones(body_size);
    [sag,cor,tra] = findND(image_space);
    center = [10 10 10];
    radius = 2;
    og_image = insert_3d_phantom(sag,cor,tra,center,radius);
    og_image = reshape(og_image,body_length,body_length,body_length);
    og_image = rescale(og_image,0,255);
    clear('sag','cor','tra','image_space')

    projections = projection(og_image,theta,body_size,collimator.resolution);

end

%% Call the MLEM_iteration script
recon_final = mlem_iteration(projections,theta,body_size,collimator,iteration_num);







