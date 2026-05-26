function collimator = collimator_equations(type,diameter,body_distance,septal_length,mu,varargin)
% Possible geometries:
%   - Parallel Hole
%   - Pinhole
%
% Parallel Hole Equations
%   Rc = d(le+b)/le
%   g = K^2(d/le)^2(d^2/(d+t)^2)
%   le (effective length) = l-(2/mu)
% 
% Pinhole Equations
%   Rc = de(l+b)/l
%   g = (de cos^3(theta))/16b^2
%   de (effective diameter) = sqrt(d(d+(2/mu)tan(alpha/2)))
%
%   where:
%       d = hole diameter
%       l = collimator length (length of the holes)
%       b = distance from the source to the collimator
%           (this needs to be an array representing the distance values)
%       K = constant based on the hole shape and geometry
%           (~ 0.24 (round holes in hex array), 0.26 (hex holes in hex array, 0.28 (square holes in square array))
%       t = septal thickness
%       mu = linear attenuation coefficient of the collimator material
%       theta = angle the source is "off" from being directly in front of the pinhole
%       alpha = angle of the septa at the pinhole
%

%% Parse the inputs and name them accordingly
p = inputParser;
addRequired(p,'type');
% addRequired(p,'num_pixels');
addRequired(p,'diameter');
addRequired(p,'body_distance');
addRequired(p,'septal_length');
addRequired(p,'mu');
addOptional(p,'K_value',0.28); % for parallel
addOptional(p,'septal_thickness',1); % for parallel
addOptional(p,'septal_angle',90); % for pinhole
parse(p,type,diameter,body_distance,septal_length,mu,varargin{:});

type = p.Results.type;
% pixels = p.Results.num_pixels;
diameter = p.Results.diameter;
b_dist = p.Results.body_distance;
septal_len = p.Results.septal_length;
mu = p.Results.mu;
K = p.Results.K_value;
thickness = p.Results.septal_thickness;
septal_angle = p.Results.septal_angle;

%% Calculate the collimator resolution and efficiency

if strcmp(type,'parallel')
    % Implement the collimator equations for parallel hole collimation
    eff_length = septal_len-(2/mu);
    coll_res = zeros(1,length(b_dist));

    for i = 1:length(b_dist)
        dist = b_dist(i);
        coll_res(i) = diameter*(eff_length+dist)/eff_length; % collimator resolution
    end

    coll_eff = K^2*(diameter/eff_length)^2*(diameter^2/(diameter+thickness)^2); % collimator efficiency


elseif strcmp(type,'pinhole')
    % Still working to make efficiency correct with the off angle stuff

    off_angle = zeros(length(b_dist),length(b_dist),length(b_dist));
    for x = 1:length(b_dist)
        for y = 1:length(b_dist)
            for z = 1:length(b_dist)
                x_dist = abs(length(b_dist)/2 - x);
                y_dist = abs(length(b_dist)/2 - y);
                x_y_dist = sqrt(x_dist^2 + y_dist^2);
                off_angle(x,y,z) = atand(x_y_dist/z);

            end
        end
    end

    tan_part = tand(septal_angle/2);
    eff_diam = sqrt(diameter*(diameter + (2/mu)*tan_part)); % effective diameter

    coll_res = zeros(length(b_dist)); % initialize resolution array

    for i = 1:length(b_dist)
        dist = b_dist(i);
        coll_res(i) = eff_diam*(septal_length+dist)/septal_length; % collimator resolution
    end

    % Collimator Efficiency currently in progress
    % off_angle_unwind = off_angle(:);
    % coll_eff = zeros(size(off_angle_unwind));
    % b_dist_long = repmat(b_dist,length(b_dist),1,length(b_dist));
    % b_dist_long = b_dist_long(:);
    % 
    % for j = 1:length(off_angle_unwind)
    %     angle_use = off_angle_unwind(j);
    %     coll_eff(j) = (eff_diam * cosd(angle_use)^3)/(16 * b_dist_long(j));
    % end
    % 
    % coll_eff = reshape(coll_eff,length(b_dist),length(b_dist),[]);
    coll_eff = off_angle;

end

%% Assign the results to the output structure
collimator.resolution = coll_res;
collimator.efficiency = coll_eff;
collimator.type = type;


