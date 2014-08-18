% Jumping to the specific record number
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function res = fwifc_seek( fileptr, record_num)

    [res, ~] = calllib('sdfifc', 'fwifc_seek', fileptr, uint32(record_num));

end