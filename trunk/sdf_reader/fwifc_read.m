% Reading record data
%
% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26
% Based on: http://www.mathworks.com/matlabcentral/answers/17448-advancing-a-structure-pointer-in-calllib-shared-library

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function rec = fwifc_read ( fileptr )

    time_sorg = libpointer('doublePtr',double(0));          %/* start of range gate in s */
    time_external = libpointer('doublePtr',double(0));      %/* external time in s relative to epoch*/
    origin = libpointer('doublePtr', double([0 0 0]));      %/* origin vector in m */
    direction = libpointer('doublePtr', double([0 0 0]));   %/* direction vector (dimensionless) */
    flags = libpointer('uint16Ptr',uint16(0));              %/* GPS synchronized, ...*/
    facet = libpointer('uint16Ptr',uint16(0));              %/* scan mirror facet number */
    sbl_count = libpointer('uint32Ptr',uint32(0));          %/* number of sample blocks */
    sbl_size = libpointer('uint32Ptr',uint32(0));           %/* size of sample block in bytes */
    sbl = libpointer('fwifc_sbl_struct');

    % FWIFC_FLAGS_SYNCHRONIZED = 0x01; /* GPS synchronized */
    % FWIFC_FLAGS_SYNC_LASTSEC = 0x02; /* synchronized within last second */
    % FWIFC_FLAGS_HOUSEKEEPING = 0x04; /* this is a housekeeping block */

    [res, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = calllib('sdfifc','fwifc_read',fileptr,...
        time_sorg,time_external,origin,direction,flags,facet,sbl_count,sbl_size,sbl);

    for k = 1 : sbl_count.Value % through all sample blocks
        if ~isempty(sbl.Value.sample) % just in case for non empty blocks
            sbl_block{k} = sbl.Value; %#ok<*AGROW>
            setdatatype(sbl.Value.sample,'uint16Ptr',1,sbl.Value.sample_count); % defining samples type and size
            sbl_block{k}.sample = sbl.Value.sample; % assigning waveform samples
            sbl = sbl + 1; % proceeding to the next block
        end;
    end;
    
    rec.res = res;
    rec.time_sorg = time_sorg.Value;
    rec.time_ext = time_external.Value;
    rec.originptr = origin.Value;
    rec.dirptr = direction.value;
	rec.flags = flags.Value;
    rec.facet = facet.Value;
    rec.sbl_count = sbl_count.Value;
    rec.sbl_size = sbl_size.Value;
    if exist('sbl_block','var')
        rec.sbl = sbl_block;
    else
        rec.sbl=[];
    end
        
end

