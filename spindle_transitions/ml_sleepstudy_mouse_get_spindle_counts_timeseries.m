function [spindleCounts, fs] = ml_sleepstudy_mouse_get_spindle_counts_timeseries(mouse, spindleFolder)
    prefix = sprintf('SpindleResults_NREMall_%s', mouse.codename{1});
    files = dir(fullfile(spindleFolder, sprintf('%s*.mat', prefix)));
    numFiles = length(files);
    hours = zeros(numFiles, 3);
    % Hack, since this should be dynamic. We expect 5 files since we have 5
    % hours of data and use blocks of 1 hour giving 5 blocks/files.
    if numFiles ~= 5
        warning('Invalid number of spindle files (%d) for (%s).', numFiles, mouse.codename{1});
    end

    for iFile = 1:numFiles
        f = files(iFile);
        fn = f.name;


        s = fn(length(prefix)+1:end);

        a = split(s, '-');
        a1 = split(a{1}, '_');
        a2 = split(a{2}, 'h');

        low = str2double(a1{2});
        high = str2double(a2{1});

        hours(iFile, :) = [ iFile, low, high ] ;
    end
    hours = sortrows(hours, 2);

    spindleStartBlock = [];
    spindleStopBlock = [];
    for iFile = 1:numFiles
        ifn = hours(iFile,1);

        tmp = load(fullfile(files(ifn).folder, files(ifn).name));
        Results = tmp.Results;
        startTime_s = Results.Parameters.StartTime; % starts at "0" seconds
        startTime_i = startTime_s * Results.Parameters.EEG_freq + 1;

        spindleStartBlock = [spindleStartBlock, Results.SpindleStart_All + startTime_i];
        spindleStopBlock = [spindleStopBlock, Results.SpindleEnd_All + startTime_i];
    end

    [eeg, fs] = ml_sleepstudy_mouse_load_eeg(mouse);
    nsamples = length(eeg);

    spindleCounts = zeros(1, nsamples);
    for i = 1:length(spindleStartBlock)
       prevCount = spindleCounts(spindleStartBlock(i):spindleStopBlock(i));
       newCount = prevCount + 1;
       spindleCounts(spindleStartBlock(i):spindleStopBlock(i)) = newCount;
    end
end % function