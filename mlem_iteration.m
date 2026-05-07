function reconstruction = mlem_iteration(og_image,theta,body_size,collimator,num_iter)

% MLEM Equation:
% new = old * update factor
%       update factor = sum over the detector elements(
%                   (n[star](d) * probability(b,d)) /
%                   (sum[body prime](old(b[prime]) * probability(b[prime],d))))
%
% n[star] is the projection sinogram
% the denominator sum is the back projection
% probability(b,d) is the probability that an interaction in detector element d was from an event in body element b

% Run the initial projection of our phantom
sinogram = projection(og_image,theta,body_size,collimator.resolution);

% View the original image and the sinogram to make sure everything is working
figure()
montage(uint16(og_image),DisplayRange=[])
title('Original Image')
% 
% figure()
% montage(uint16(permute(sinogram,[1 3 2])),DisplayRange=[])
% title('Original Sinogram')
% 
% figure()
% montage(uint16(sinogram),DisplayRange=[])
% title('Original Sinogram')

% Perform direct backprojection for comparison to MLEM result
direct_backproj = backprojection(sinogram,theta,body_size);

figure()
montage(uint16(direct_backproj),DisplayRange=[])
title('Direct Backprojection')

% return

% % Initialize the sinogram of ones to create our sensitivity matrix
% sino_ones = ones(size(sinogram));
% sens_img = backprojection(sino_ones,theta,body_size);

% % View the sensitivity image for checking
% figure()
% montage(uint16(sens_img),DisplayRange=[])
% title('Sensitivity Sinogram')

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
% figure()
% montage(uint16(permute(proj,[1 3 2])),DisplayRange=[])
% title('Projection Final')

figure()
montage(uint16(newImage),DisplayRange=[])
title('Recon Image Final')

% figure()
% vol3d('CData',newImage);
% title(append('Iteration ',num2str(ind)))
% xlabel('x body axis')
% ylabel('y body axis')
% zlabel('z body axis')


reconstruction = newImage;

end

