function [Activity] = insert_3d_phantom(sag,cor,tra,ball_center,ball_radius)
% Insert_Phantom(...) will insert a ball phantom of specified actvity into
% an exisiting activity map or simulation domain.
% Inputs:
%     sag - an Nx1 matrix with the row coordinates of each point (saggital direction)
%     cor - an Nx1 matrix with the column coordinates of each point (coronal direction)
%     tra - an Nx1 matrix with the depth coordinates of each point (transverse direction)
%     ball_center - an 1x3 or 3x1 matrix the center of the ball phantom to
%                   be inserted with [sag cor tra] format
%     ball_radius - the radius of the ball
%     Activity - an Nx1 activity map that will be aquired during the
%                projection process you want the activity inserted into

Activity = zeros(size(sag));

diff_cor = cor - ball_center(2);
diff_sag = sag - ball_center(1);
diff_tra = tra - ball_center(3);
dist_from_center = sqrt(diff_cor.^2+diff_sag.^2+diff_tra.^2);
a = dist_from_center < ball_radius;
Activity(a) = 1;
% disp(size(Activity))
end

