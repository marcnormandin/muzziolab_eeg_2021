% Get distribution of sigma power at NREM-REM transitions
function [sigmaMatch, sigmaMatch_mean, sigmaMatch_std, sigmaMatch_times, matchesi] = get_sigma_transition_match(sigmaMatch_t_before_and_after, epoch_length_s, sample_times, band_timeseries, y_score, a, b)
    % There is 1 score every 'epoch_length' seconds
    % Find all matching transitions
    numScores = length(y_score);
    matchesi = [];
    for i=1:numScores-1
        if y_score(i) == a && y_score(i+1) == b
            matchesi(end+1) = i;
        end
    end

    figure
    % We have the transition point in epochs, but we need it in seconds
    matches = matchesi * epoch_length_s;
    numMatches = length(matches);
    k = 1;
    M = sigmaMatch_t_before_and_after;
    sigmaMatch = zeros(1, 2*M+1);
    for iMatch = 1:numMatches
        ps = matches(iMatch) - M;
        qs = matches(iMatch) + M;
        
        fprintf('iMatch: %d, matchi: %d, ps: %f, qs: %f\n', iMatch, matchesi(iMatch), ps, qs);
        % Skip any that we dont have a full 2M seconds worth of data for
        if ps < 1 || qs > length(sample_times)
            continue;
        end
        %indices = intersect(find(sample_times >= ps), find(sample_times <= qs));
        
        sigmaMatch(k,:) = band_timeseries(ps:qs);
        plot(sigmaMatch(k,:))
        hold on
        k = k + 1;
    end

    sigmaMatch_mean = mean(sigmaMatch, 1);
    sigmaMatch_std = std(sigmaMatch, 1);
    
    sigmaMatch_times = -M:M;
end