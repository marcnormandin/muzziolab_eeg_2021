function [spindleTransitionTimes, spindleTransitionsAverage] = ml_sleeptudy_mouse_get_spindle_transition_average(settings, mouse, spindleFolder, beta)    
% The spindle counts will be the same size as the eeg
    [spindleCounts, fs] = ml_sleepstudy_mouse_get_spindle_counts_timeseries(mouse, spindleFolder);

    % Trim it so that there is a score for each element
    scores = mouse.scores{1};
    numScores = length(scores);
    maxSamples = numScores * fs * settings.EPOCH_LENGTH_S; % fs is the same as eeg fs.
    if length(spindleCounts) > maxSamples
        spindleCounts(maxSamples+1:end) = [];
    end

    % We need to downscale it but we dont want to miss spindle counts
    alpha = settings.waveletsDownsampleFactor;
    spindleCountsReduced = zeros(1, length(spindleCounts)/alpha);
    x = spindleCounts;
    for k = 1:(alpha-1)
        x = x + circshift(spindleCounts,k);
    end
    % Now keep only every alpha-th element (eg. 4)
    for j = 1:length(spindleCountsReduced)
        spindleCountsReduced(j) = x(alpha*j);
    end

    waveletFs = fs / settings.waveletsDownsampleFactor;

    % Now do the transition aspect



    % Expland the scores to one for each time sample
    waveletScores = repelem(scores, settings.EPOCH_LENGTH_S * waveletFs);

    codeBefore = settings.CODE_NREM;
    codeAfter = settings.CODE_REM;

    % Find all matching transitions
    [record] = ml_ephys_bayesclassifier_scores_to_epoch_records(waveletScores);
    recBefore = record(find([record.state] == codeBefore));
    recAfter = record(find([record.state] == codeAfter));

    % This is inefficient, but it doesn't matter
    irecmatches = [];
    transitionIndices = [];
    % How many time samples do we use before and after the transition
    nSamples = settings.sigmaMatch_t_before_and_after * waveletFs;

    for iRecBefore = 1:length(recBefore)
        rb = recBefore(iRecBefore);
        for iRecAfter = 1:length(recAfter)
           ra = recAfter(iRecAfter);

           % Do we have a match
           if rb.epochs(end)+1 == ra.epochs(1)
               % Yes!
               k = size(irecmatches,1)+1;
               irecmatches(k,:) = [iRecBefore, iRecAfter];

               tp = rb.epochs(end);
               indices = (-nSamples:nSamples) + tp;
               if ~any( indices < 1 | indices > length(waveletScores) )
                   % Only include the indices if we have an entire set of them,
                   % meaning that none go off the edges and each has the same
                   % amount.
                   k = size(transitionIndices,1)+1;
                   transitionIndices(k,:) = indices;
               end
           end
        end
    end

    %spindleTransitionTimes = (-nSamples:nSamples) / waveletFs;
    %spindleTransitionTimes = (-nSamples:nSamples) / waveletFs;
    numTransitions = size(transitionIndices,1);
    %beta = 12; % we want values every beta seconds (sum across beta seconds)
    s = waveletFs * beta;
    spindleTransitionsAverage = []; %zeros(1, length(spindleTransitionTimes));
    for i = 1:numTransitions
        x = spindleCountsReduced(1,transitionIndices(i,:));


        k = 1;
        j1 = 1;
        j2 = s;
        y = [];

        while 1
            if j2 <= length(x)
                y(k) = max(x(j1:j2)); % /beta;
                k = k + 1;
                j1 = j2;
                j2 = j2 + s;
            else
                break;
            end
        end

        if ~isempty(spindleTransitionsAverage)
            spindleTransitionsAverage = spindleTransitionsAverage + y;
        else
            spindleTransitionsAverage =   y;
        end
        % Unsmoothed 
        %spindleTransitionsAverage = spindleTransitionsAverage + spindleCountsReduced(1,transitionIndices(i,:));
        % Smoothed
        %spindleTransitionsAverage = spindleTransitionsAverage + movsum(, 5*waveletFs);
    end
    spindleTransitionsAverage = spindleTransitionsAverage / numTransitions;


    spindleTransitionTimes = -settings.sigmaMatch_t_before_and_after:beta:settings.sigmaMatch_t_before_and_after;
    
end % function
