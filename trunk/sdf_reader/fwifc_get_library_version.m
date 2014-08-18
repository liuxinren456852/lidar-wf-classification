% Getting library version
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function [res, lib_ver] = fwifc_get_library_version

    api_major = libpointer('uint16Ptr',uint16(0));  %/* major version number */
    api_minor = libpointer('uint16Ptr',uint16(0));  %/* minor version number */
    build_version = libpointer('cstring');          %/* build information string */ 
    build_tag = libpointer('cstring');              %/* build tag information */
    
    [res, api_major, api_minor, build_version, build_tag] = calllib('sdfifc', 'fwifc_get_library_version', api_major, api_minor, build_version, build_tag);
    
    lib_ver.api_major = api_major;
    lib_ver.api_minor = api_minor;
    lib_ver.build_version = build_version;
    lib_ver.build_tag = build_tag;

end