% Closing waveform Riegl SDF file
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function res = fwifc_close( fileptr ) 

    [res,~]=calllib('sdfifc','fwifc_close',fileptr);
    
end