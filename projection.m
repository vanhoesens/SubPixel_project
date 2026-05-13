function proj = projection(image,theta,body_size,collimator_res)

% General function (3D):
    % Read in the image
    % Add up the columns in the x-y plane
    % 2D blur the added values with a gaussian (use Collimation Eqns)
    % Store the added and blurred image as a slice of the sinogram
    % Rotate the image about the z axis by the angle increment in theta
    % Repeat these steps for all the angles
% Updates Needed:
    % different values for x and y directions

% Pad the image so that nothing in the corner is cut off when rotating
max_cutoff = ceil(body_size(1)*0.42); % max number of pixels that would be cut off [diameter = body length, 0.42 = sqrt(2)-1]
half_cutoff = ceil(max_cutoff*0.5);
cutoff = 2*half_cutoff;
rotate_size = [body_size(1)+cutoff body_size(2)+cutoff body_size(3)+cutoff];
image = padarray(image,[half_cutoff half_cutoff half_cutoff],0,'both');

sinogram = zeros([body_size(1),body_size(2),length(theta)]);

for i = 1:length(theta)
    angle = theta(i);
    rotatedImage = imrotate3(image,angle,[0 0 1],"crop");
    blurredImage = zeros(rotate_size);

    for j = 1:body_size(2)
        sigma = collimator_res(j);
        blurredImage(:,j,:) = imgaussfilt(squeeze(rotatedImage(:,j,:)), sigma);
    end

    addedColumns = sum(blurredImage, 2);
    addedColumns = trimdata(addedColumns,body_size(1),'Side','both','Dimension',1:3);
    sinogram(:,:,i) = addedColumns;

end

proj = sinogram;

end

