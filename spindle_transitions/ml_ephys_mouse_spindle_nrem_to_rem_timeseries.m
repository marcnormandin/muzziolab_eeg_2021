function [sigmaTransitionTimes, sigmaTransitionsAverage, numSigmaTransitions] =  ml_ephys_mouse_spindle_nrem_to_rem_timeseries(settings, mouse)
    scores = mouse.scores{1};

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

    sigmaTransitionTimes = (-nSamples:nSamples) / waveletFs;
    numSigmaTransitions = size(transitionIndices,1);
    
    sigmaTransitionsAverage = zeros(1, length(sigmaTransitionTimes));
    for i = 1:numSigmaTransitions
        sigmaTransitionsAverage = sigmaTransitionsAverage + powerSeriesNormedTrimmed(1,transitionIndices(i,:));
    end
    sigmaTransitionsAverage = sigmaTransitionsAverage / numSigmaTransitions;

end % function