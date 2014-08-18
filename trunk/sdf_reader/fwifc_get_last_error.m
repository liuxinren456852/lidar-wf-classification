% Getting last error message
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function [res, message] = fwifc_get_last_error

    message = libpointer('cstring');
    
    [res, message] = calllib('sdfifc','fwifc_get_last_error', message);
    
end