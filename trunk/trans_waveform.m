function wsamp = trans_waveform(wsamp, fignum)

    if fignum>0,
        figure(fignum); clf; hold on;
    end;
    
    center = round(size(wsamp , 2)/2);
    for i = 1 : size(wsamp , 1),
        [val mind] = max(wsamp (i,:));
        offs = center - mind;
        if offs > 0,
            wsamp(i,:) = [repmat(wsamp(i,1), 1, offs), wsamp(i,1:(end-offs))];
        end;
        if offs < 0,
            wsamp(i,:) = [wsamp(i,abs(offs):end) repmat(wsamp(i,end), 1, abs(offs)-1)];
        end;

        if fignum > 0,
            plot(1:length(wsamp), wsamp(i,:), 'r-');
        end;
        
        %wsamp(i,:) = wsamp(i,:) ./ sum(wsamp(i,:));
        
        [val ind] = max(wsamp(i,:));
        if ind~=center,
            % disp('Error!');
            % offs
            %return;
        end;
    end;