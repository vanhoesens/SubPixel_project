function reconstruction = mlem_iteration(og_image,theta,body_size,collimator,num_iter,varargin)

% MLEM Equation:
% new = old * update factor
%       update factor = sum over the detector elements(
%                   (n[star](d) * probability(b,d)) /
%                   (sum[body prime](old(b[prime]) * probability(b[prime],d))))
%
% n[star] is the projection sinogram
% the denominator sum is the back projection
% probability(b,d) is the probability that an interaction in detector element d was from an event in body element b

p = inputParser;
addRequired(p,'og_image');
addRequired(p,'theta');
addRequired(p,'body_size');
addRequired(p,'collimator');
addRequired(p,'num_iter');
addOptional(p,'plot_robust',false);
parse(p,og_image,theta,body_size,collimator,num_iter,varargin{:});

% Run the initial projection of our phantom
sinogram = projection(og_image,theta,body_size,collimator.resolution);

% Perform direct backprojection for comparison to MLEM result
direct_backproj = backprojection(sinogram,theta,body_size);

% % Initialize the sinogram of ones to create our sensitivity matrix
% sino_ones = ones(size(sinogram));
% sens_img = backprojection(sino_ones,theta,body_size);

% Initialize old and new images for data storage
newImage = ones(body_size);

for ind = 1:num_iter
    disp('MLEM Iteration '+string(ind))
    proj = projection(newImage,theta,body_size,collimator.resolution);

    % compare the oldImage's projection to the known sinogram
    ratio = sinogram ./ (proj+0.001);
    backproj_ratio = backprojection(ratio,theta,body_size);
    % correction = backproj_ratio ./ (sens_img+0.001);

    % Update the old and new images
    oldImage = newImage;
    % newImage = newImage .* correction;
    newImage = newImage .* backproj_ratio;
    newImage = rescale(newImage,0,255);

    % View the current iteration of the estimate projections and image
    % figure()
    % montage(uint16(permute(proj,[1 3 2])),DisplayRange=[])
    % title(append('Projection Iteration ',num2str(ind)))
    % 
    % figure()
    % montage(uint16(newImage),DisplayRange=[])
    % title(append('Iteration ',num2str(ind)))


end

% View the final iteration
figure()
montage(uint16(newImage),DisplayRange=[])
title(['Recon Image Final: ',num2str(length(theta)),' Angles'])

% Original Image
figure()
montage(uint16(og_image),DisplayRange=[])
title('Original Image')

drawnow

reconstruction = newImage;


if p.Results.plot_robust
    % Original Image
    figure()
    montage(uint16(og_image),DisplayRange=[])
    title('Original Image')
    
    % Original Sinogram for the input Image
    figure()
    montage(uint16(permute(sinogram,[1 3 2])),DisplayRange=[])
    title('Original Sinogram')

    figure()
    montage(uint16(sinogram),DisplayRange=[])
    title('Original Sinogram')

    % Direct Backprojection for comparison
    figure()
    montage(uint16(direct_backproj),DisplayRange=[])
    title('Direct Backprojection')

    % % Sensitivity image (if used)
    % figure()
    % montage(uint16(sens_img),DisplayRange=[])
    % title('Sensitivity Sinogram')

end

end

