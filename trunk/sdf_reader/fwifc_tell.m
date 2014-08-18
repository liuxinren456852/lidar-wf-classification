% Returning number of current record
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function [res, rec_num] = fwifc_tell( fileptr )

    record_num = libpointer('uint32Ptr',uint32(0));
    
    [res, ~] = calllib('sdfifc', 'fwifc_tell', fileptr, record_num);
    
    rec_num = record_num.Value;
    
end