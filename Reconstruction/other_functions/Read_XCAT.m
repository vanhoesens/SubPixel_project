function [act_atn] = Read_XCAT(file_name,dim)
%READ_XCAT [act_atn] = Read_XCAT(file_name,dim)
%   Detailed explanation goes here
if ~isfile(file_name)
error(['YOU MISPELLED THE FILE NAME: ',file_name])
end
fileID = fopen(file_name);
A = fread(fileID,inf,'float');
act_atn = reshape(A,dim,dim,[]);
fclose(fileID);
%act_atn = Rotate_XCAT(act_atn);
end

