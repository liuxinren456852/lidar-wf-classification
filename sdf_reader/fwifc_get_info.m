% Getting SDF file info
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function [res, sdf_info] = fwifc_get_info( fileptr )

    instrument = libpointer('cstring');                 %/* instrument type */
    serial = libpointer('cstring');                     %/* serial number of the instrument */
    epoch =libpointer('cstring');                       %/* type of time_external, e.g., date/time */
                                                        %/* "2010-11-16T00:00:00" if known */
                                                        %/* or "DAYSEC" or "WEEKSEC" */
                                                        %/* "UNKNOWN" if unknown */
    v_group = libpointer('doublePtr', double(0));       %/* group velocity */
    sampling_time = libpointer('doublePtr', double(0)); %/* sampling interval in seconds */
    flags = libpointer('uint16Ptr', uint16(0));         %/* GPS synchronized, ... */
    num_facets = libpointer('uint16Ptr', uint16(0));    %/* number of scan mirror facets */

    [res, ~, instrument, serial, epoch, v_group, sampling_time, flags, num_facets] = ...
        calllib('sdfifc','fwifc_get_info', fileptr, instrument, serial, epoch, v_group, sampling_time, flags, num_facets);
    
    sdf_info.instrument = instrument;
    sdf_info.serial = serial;
    sdf_info.epoch = epoch;
    sdf_info.v_group = v_group;
    sdf_info.sampling_time = sampling_time;
    sdf_info.flags = flags;
    sdf_info.num_facets = num_facets;
    
end