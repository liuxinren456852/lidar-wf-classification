% Getting calibration table (additional license necessary)
%
% (not tested)
%
% Written by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

function [res, calib_table] = fwifc_get_calib ( fileptr, tk )

    table_kind = uint16(tk);                        %/* one of the FWIFC_CALIB_xxx constants */
    count = libpointer('uint32Ptr',uint32(0));      %/* length of returned table */
    abscissa = libpointer('doublePtr', double(0));  %/* table values, valid until next call into*/
    ordinate = libpointer('doublePtr', double(0));  %/* library. */
    
    % #define FWIFC_CALIB_AMPL_CH0 0
    % #define FWIFC_CALIB_AMPL_CH1 1
    % #define FWIFC_CALIB_RNG_CH0 2
    % #define FWIFC_CALIB_RNG_CH1 3

    [res, ~, ~, ~, ~] = ...
        calllib('sdfifc', 'fwifc_get_calib', fileptr, table_kind, count, abscissa, ordinate);
    
    calib_table.table_kind = table_kind;
    calib_table.count = count.Value;
    calib_table.abscissa = abscissa.Value;
    calib_table.ordinate = ordinate.Value;

end