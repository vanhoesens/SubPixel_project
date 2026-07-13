function image = backprojection(proj,angles,image_size)

% Initialize the output image
max_cutoff = ceil(image_size*0.42); % max number that will be cut off when rotating [diameter = body length, 0.42 = sqrt(2)-1]
half_cutoff = round(max_cutoff*0.5);
cutoff = 2*half_cutoff;
rotate_size = [image_size+cutoff image_size+cutoff image_size+cutoff];
outputImage = zeros(rotate_size);
diff_angles = angles(1) - angles(2);

% drawnow
% fig=figure(100);
% ax1 = axes(fig,"Position",[.0 .0 .45 1]);
% ax2 = axes(fig,"Position",[0.55 .0 0.4 1]);
% ax3 = axes(fig,"Position",[.0 .0 .2 1]);

% back_projections_hold = zeros(body_size(1),body_size(2),body_size(3),120);

% Backprojection
for k = 1:length(angles)
    outputImage = imrotate3(outputImage,diff_angles,[0 0 1],"linear","crop"); 

        angled_projection = zeros([image_size image_size image_size]);
        for ind = 1:image_size
            angled_projection(ind,:,:) = proj(:,:,k);

        end

    angled_padded = padarray(angled_projection,[half_cutoff half_cutoff half_cutoff],0,'both');

    % back_projections_hold(:,:,:,k) = angled_projection;
    outputImage = outputImage + angled_padded;

    % figure(100)
    % montage(angled_projection,'BorderSize',1,'DisplayRange',[min(min(min(angled_projection))) max(max(max(angled_projection)))+1],'Parent',ax1)
    % montage(outputImage,'BorderSize',1,'DisplayRange',[min(min(min(outputImage))) max(max(max(outputImage)))+1],'Parent',ax2)
    % imagesc(proj(:,:,k),'Parent',ax3)
    % axis equal
    % drawnow
    % pause(.01)

end

outputImage = imrotate3(outputImage,diff_angles,[0 0 1],"linear","crop");
outputImage = permute(outputImage,[1 2 3]); % the last value here needs to correspond to the 1 in the rotation axis
outputImage = rescale(outputImage,0,255);
outputImage = imrotate3(outputImage,90,[0 0 1],"linear","crop");
outputImage = flip(outputImage,1);
outputImage = trimdata(outputImage,image_size,'Side','both','Dimension',1:3);

image = outputImage; % Assign the output image to backproj for further processing

end



