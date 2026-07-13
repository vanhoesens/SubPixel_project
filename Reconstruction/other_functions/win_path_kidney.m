function [path] = win_path_kidney(append_path)

% This function should be set for each user. It allows for the functions
% that call it to remain path-independent.

[~,name] = system('hostname');

name = erase(name,newline);

if strcmpi(name,'mccarthylab-1')
    path_hold = 'C:\Users\svanhoesen\OneDrive - UMass Chan Medical School\';

elseif strcmpi(name,'mccarthylab-7')
    path_hold = 'C:\Users\svanhoesen\OneDrive - UMass Chan Medical School\';

elseif strcmpi(name,'')
    path_hold = 'C:\Users\sgvanhoesen\OneDrive - UMass Chan Medical School\';

end

% disp(path_hold)

if exist('append_path','var')
    path = append(path_hold,append_path);

else
    path = path_hold;

end

end


