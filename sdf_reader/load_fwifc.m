% Loading DLL
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function [names,notfound,warnings]=load_fwifc

% Load library with header file (MEX compiler necessary)
if ~libisloaded('sdfifc')
   [notfound,warnings] = loadlibrary('sdfifc','fwifc.h');
else
    notfound=[];warnings=[];
end

% Names of functions
names=libfunctions('sdfifc');

% For signatures
%libfunctionsview sdfifc
end