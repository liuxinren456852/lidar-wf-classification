% Script for extraction waveform data from SDF Riegl file based on ID rang
% Prepared based on the Zoltan Koppanyi example

% Written by Grzegorz Jozkow
% The Ohio State University
% July 7, 2014

% clear all; clc; 

%% Inputs
% First waveform ID
id1=8391935;%id1=12357000;
% Last waveform ID
% id2=9179762;%id2=12358000;
id2=8399935;

% Maximal number of considered low power blocks
max_blocks=2;

% Look also on the beginning of last section for putting break points
% Number of nanoseconds for time dependent waveform cube
ns_count=1000;
% Start time of beginning of waveform cube after reference time (in
% nanoseconds)
ns_start=1000;

% Use time_sorg or reference channel time_sosbl as reference time
reftime=1; % 1 - time_sorg, 0 - time_sosbl
%% Preloading
% Load DLL
load_fwifc;
%Getting library info
[~, lib_ver] = fwifc_get_library_version();
disp('Library version:');disp(lib_ver);
% Opening file
[File,Path,~] = uigetfile('*.sdf','Slect SDF file',...
    'C:\Users\jozkow.1\Desktop\waveform\waveforms-example\130617_192721_1.sdf');
sdffile=fullfile(Path,File);
[~, fileptr] = fwifc_open (sdffile);
% Getting file info
[~, finfo] = fwifc_get_info( fileptr );
disp('File info:');disp(finfo);
% Relative or not time
fwifc_set_sosbl_relative( fileptr, reftime);

%% Other
% Getting last error
[~, cs] = fwifc_get_last_error();
disp(['Message: ' cs]);

%% Extracting data
% Jump by the record ID
fwifc_seek( fileptr, id1);
% Number of waveforms
n=id2-id1+1;

% Preallocating variables
metdat=NaN(n,32); % metadata
wfm=NaN(n,120,4); % waveforms

% Reading records
for i = 1 : n
    [~, rec_num]  = fwifc_tell(fileptr);
    rec = fwifc_read( fileptr );
        metdat(i,1)=i+id1-1; % record identifier, auto number
        metdat(i,2)=rec.time_sorg; % time of start of range gate, non empty
        metdat(i,3)=rec.time_ext; % time external, non empty
        metdat(i,4:6)=rec.originptr; % origin vector, NaN for special record*
        metdat(i,7:9)=rec.dirptr; % direction vector, NaN for special record*
        metdat(i,10)=rec.flags; % flag, typically 3, 11 for last waveform in the scanline, 15 for special record*
        metdat(i,11)=rec.facet; % facet number from 0 to 3 (this scanner), ... NaN for special record*
        metdat(i,12)=rec.sbl_count; % number of sample blocks, 1 to 4, 0 for special record*
        metdat(i,13)=rec.sbl_size; % sample block size, always 32 bits
        % * special record means record indicating end of scan line without useful data
        for k=1:rec.sbl_count
            % for special record all variables are NaN
            metdat(i,14+4*(k-1))=rec.sbl{k}.time_sosbl; % time of start of sample block
            metdat(i,15+4*(k-1))=rec.sbl{k}.channel; % channel number: 3-reference, 1-low power, 0-high power
            metdat(i,16+4*(k-1))=rec.sbl{k}.sample_count; % number of samples, 24 for reference, otherwise 60 or 120
            metdat(i,17+4*(k-1))=rec.sbl{k}.sample_size; % sample size, always 2
            wfm(i,1:rec.sbl{k}.sample_count,k)=rec.sbl{k}.sample; % waveform samples, row is record, columns are samples, pages are blocks
        end
end

% Close file
res = fwifc_close( fileptr );

%% Removing high power channel
% Max number of sample blocks
sb_count_max=max(metdat(:,12));

for ii=1:n
    for jj=sb_count_max:-1:2
        if metdat(ii,15+4*(jj-1))==0 % block is high power
            metdat(ii,14+4*(jj-1):17+4*(jj-1))=NaN; % removing metadata block info
            wfm(ii,:,jj)=NaN; % removing waveform samples
            metdat(ii,12)=metdat(ii,12)-1; % reducing number of blocks
            for kk=jj:sb_count_max-1 % rewriting next blocks
                metdat(ii,14+4*(kk-1):17+4*(kk-1))=metdat(ii,14+4*kk:17+4*kk); % rewriting metadata of next to current block
                wfm(ii,:,kk)=wfm(ii,:,kk+1); % rewriting waveform of next to current block
            end
        end
    end
end        

%% Packing together blocks of low power channel
% Number of low power samples
slp_count=metdat(:,20:4:size(metdat,2));slp_count(isnan(slp_count))=0;

% Max number of low power samples
slp_count_max=max(sum(slp_count,2));

% Preallocating low power waveform samples
wfm_lp_pack=zeros(n,slp_count_max);

% Rewriting into new variable
for ii=1:n
    if metdat(ii,12)>1 % means that there is more than reference block
        i1=1; % index of first sample
        i2=0; % index of last sample
        for jj=2:metdat(ii,12)
            i2=i2+slp_count(ii,jj-1); % adding number of current number of samples
            wfm_lp_pack(ii,i1:i2)=wfm(ii,1:slp_count(ii,jj-1),jj); % adding current block
            i1=i1+slp_count(ii,jj-1); % adding number of current number of samples
        end
    end
end

%% Forming cube
% Indexes to special records indicating end of the line and number of pulse
ieol=find(~metdat(:,12));neol=[ieol;n+1]-[0;ieol];neol=neol-1;

% Number of lines and pulses in the scan line
l=size(neol,1);s=max(neol);

% Max number of sample blocks
sb_count_max=max(metdat(:,12));
% Reducing number of sample blocks
if sb_count_max>max_blocks+1;sb_count_max=max_blocks+1;end % assumption than more than 3 are error blocks

% Max number of reference samples
sref_count_max=max(metdat(:,16));

% Preallocating arrays to store metadata
id_record=NaN(l,s); % indexes of records
t_sorg=NaN(l,s); % time of start of the gate range
t_ext=NaN(l,s); % time external
origin=NaN(l,s,3); % origin vector
direction=NaN(l,s,3); % direction vector
facet_no=NaN(l,1); % number of facet mirror
sb_count=NaN(l,s); % number of sample blocks
t_sosbl=NaN(l,s,sb_count_max); % time of start of sample block
s_count=NaN(l,s,sb_count_max); % number of samples in each block
wfm_ref=zeros(l,s,sref_count_max); % reference waveforms
wfm_lp=zeros(l,s,slp_count_max); % low power channel waveforms (no time correlation)

% Writing metadata
ieoli=[0;ieol;n+1]; % new indexes of end line for easier indexing in the loop
for ii=1:l % through all scan lines
    i1=ieoli(ii)+1; % index to first pulse of scan line
    i2=ieoli(ii+1)-1; % index to last pulse in the scan line
    nl=neol(ii); % number of pulses in the scan line
    
    id_record(ii,1:nl)=metdat(i1:i2,1)'; % indexes of records
    t_sorg(ii,1:nl)=metdat(i1:i2,2)'; % time of start of the gate range
    t_ext(ii,1:nl)=metdat(i1:i2,3)'; % time external
    origin(ii,1:nl,:)=reshape(metdat(i1:i2,4:6),1,nl,3); % origin vector
    direction(ii,1:nl,:)=reshape(metdat(i1:i2,7:9),1,nl,3); % direction vector
    facet_no(ii)=metdat(i1,11); % number of facet mirror
    sb_count(ii,1:nl)=metdat(i1:i2,12)'; % number of sample blocks
    for jj=1:sb_count_max
        t_sosbl(ii,1:nl,jj)=metdat(i1:i2,14+4*(jj-1))'; % time of start of sample block
        s_count(ii,1:nl,jj)=metdat(i1:i2,16+4*(jj-1))'; % number of samples in each block
    end
    wfm_ref(ii,1:nl,:)=reshape(wfm(i1:i2,1:sref_count_max,1),1,nl,sref_count_max); % reference waveforms
    wfm_lp(ii,1:nl,:)=reshape(wfm_lp_pack(i1:i2,:),1,nl,slp_count_max); % low power channel waveforms (no time correlation)
end

%% Arranging time related waveform cube

% Calculating relative to 'reference' time start of sample blocks in ns
dt_sb_start=(t_sosbl(:,:,2:end))*1e9;
if reftime==0 % respect time_sosbl for reference channel
        dt_sb_start=dt_sb_start-repmat(t_sosbl(:,:,1),1,1,sb_count_max-1)*1e9;
end 

% Here is code helping visualisating time or time difference decidind of
% two varialbes ns_count and ns_start and might be overwitten setting break
% point - comment if not necessary
colors=['r','g','b','c','m','y']; % colors for 6 blocks, probably there will not be more
dsc=[];
figure();hold on
if reftime==1 % plotting also reference time difference for reference channel
    dt=t_sosbl(:,:,1)'*1e9;
    plot(dt(:),'k');
    dsc=[dsc,{'Reference block'}];tlt='Time difference of sample blocks respect time of start of range gate';
else
    tlt='Time difference of sample blocks respect time of start of reference sample block';
end
for ii=1:sb_count_max-1
    dt=dt_sb_start(:,:,ii)';
    plot(dt(:),colors(ii));
    dsc=[dsc,{[num2str(ii), ' Low Power block']}]; %#ok<AGROW>
end
grid on    
legend(dsc,'Location','NorthEast');
title(tlt);
hold off

% Removing ns_start from time
dt_sb_start=dt_sb_start-ns_start;

% Preallocating arrays (most of the arrays is the same as for previous so
% they are not repeated)
id_sb_start=NaN(l,s,sb_count_max-1);% index to band number where 1st low power sample block starts, it can be minus for short range (time) which is error
wfm_tlp=zeros(l,s,ns_count); % waveform 'time' cube - ns_count bands means ns_count ns range

% Calculating cube
for ii=1:l % through all lines
    for jj=1:s % through all samples
        if sb_count(ii,jj)>1 % at least one low power channel
            id1=1;
            id2=0;
            for kk=1:sb_count(ii,jj)-1
                cur_smp_count=s_count(ii,jj,kk+1); % current number of samples
                cur_bnd_id=round(dt_sb_start(ii,jj,kk)); % current starting band index
                
%                 tst=mod(jj,7);if ~(tst==1 || tst==2 || tst==4);cur_bnd_id=cur_bnd_id-200;end
%                 tst=mod(id_record(ii,jj),7);if ~(tst==0 || tst==2 || tst==6);cur_bnd_id=cur_bnd_id-200;end
                
                id2=id2+cur_smp_count; % adding for the end
                cur_wfm=wfm_lp(ii,jj,id1:id2);cur_wfm=cur_wfm(:); % current waveform
                id1=id1+cur_smp_count; % adding for the beginning
                id_sb_start(ii,jj,kk)=cur_bnd_id; % writing to variable
                if ~(cur_bnd_id>ns_count || cur_bnd_id+cur_smp_count<1) % at least part of waveform is in the range
                    if cur_bnd_id+cur_smp_count>ns_count % last sample is out of the range
                    cur_wfm(end-cur_bnd_id+cur_smp_count+ns_count+1:end)=[]; % cutting end of waveform
                    end
                    if cur_bnd_id<1 % at least part of the waveform is before cube
                        cur_wfm(1:1-cur_bnd_id)=[]; % cutting beginning of the cube
                        cur_bnd_id=1;
                    end
                    wfm_tlp(ii,jj,cur_bnd_id:cur_bnd_id+length(cur_wfm)-1)=cur_wfm; % writing waveform
                end
            end
        end
    end
end