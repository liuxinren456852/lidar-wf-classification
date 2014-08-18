% Setting time relative or absolute
%
% Written by Grzegorz Jozkow
% Ohio State University
% 2014.07.16
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

function res = fwifc_set_sosbl_relative( fileptr, relative )

    [res, ~] = calllib('sdfifc','fwifc_set_sosbl_relative', fileptr, int32(relative));

end

