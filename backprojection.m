function image = backprojection(proj,angles,body_size)

% Initialize the output image
outputImage = zeros(body_size);
diff_angles = angles(1) - angles(2);

drawnow
fig=figure(100);
ax1 = axes(fig,"Position",[.2 .0 .4 1]);
ax2 = axes(fig,"Position",[.6 .0 .4 1]);
ax3 = axes(fig,"Position",[.0 .0 .2 1]);

% Backprojection
for k = 1:length(angles)
    outputImage = imrotate3(outputImage,diff_angles,[0 0 1],"linear","crop"); 

        angled_projection = zeros(body_size);
        for ind = 1:body_size(3)
            angled_projection(ind,:,:) = proj(:,:,k);
        end

    outputImage = outputImage + angled_projection;

    figure(100)
    montage(angled_projection,'BorderSize',1,'DisplayRange',[min(min(min(angled_projection))) max(max(max(angled_projection)))+1],'Parent',ax1)
    montage(outputImage,'BorderSize',1,'DisplayRange',[min(min(min(outputImage))) max(max(max(outputImage)))+1],'Parent',ax2)
    imagesc(proj(:,:,k),'Parent',ax3)
    axis equal
    drawnow
    pause(.01)

end

outputImage = imrotate3(outputImage,diff_angles,[0 0 1],"linear","crop");
outputImage = permute(outputImage,[1 2 3]); % the last value here needs to correspond to the 1 in the rotation axis
outputImage = rescale(outputImage,0,255);
outputImage = imrotate3(outputImage,90,[0 0 1],"linear","crop");
outputImage = flip(outputImage,1);

image = outputImage; % Assign the output image to backproj for further processing

end



