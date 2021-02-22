% Get distribution of sigma power at NREM-REM transitions
function [sigmaMatch, sigmaMatch_mean, sigmaMatch_std, sigmaMatch_times, matchesi] = get_sigma_transition_match_v4(sigmaMatch_s_before_and_after, epoch_length_s, sample_times, band_timeseries, y_score, a, b)
    % Expand the scores to 1 per second since the band time series has that
    % sampling rate (1 value per second)
    y_score_per_sec = repelem(y_score, epoch_length_s);
    
    % Find all matching transitions
    numScores = length(y_score_per_sec);
    matchesi = []; % store the indices of the point a
    for i=1:numScores-1
        if y_score_per_sec(i) == a && y_score_per_sec(i+1) == b
            matchesi(end+1) = i;
        end
    end
    numMatches = length(matchesi);

    %figure
    k = 1;
    M = sigmaMatch_s_before_and_after; % maximum seconds before, and same value after to use if it meets the correct epoch type
    sigmaMatch = nan(1, 2*M+2); % maximum size
    for iMatch = 1:numMatches
        % should all be state a
        ps = matchesi(iMatch); % state a
        np = 0;
        qs = matchesi(iMatch)+1; % state b
        nq = 0;
        
        for i = 1:M
            if ps-i >= 1
                % if it matches
                if y_score_per_sec(ps-i) == a
                    np = np + 1;
                    continue;
                else
                    % not a match
                    break;
                end
            else
                break;
            end
        end
        
        for i = 1:M
            if qs+i <= length(y_score_per_sec)
                % if it matches
                %if y_score_per_sec(qs+i) == b
                % We already know a transition was found, so now include
                % any state after the transition
                    nq = nq + 1;
                %    continue;
                %else
                    % not a match
                %    break;
                %end
            else
                break;
            end
        end
        
%         % Only keep data that contains a minimum epoch length of each state
%         minEpochs = 3;
%         if np < minEpochs*epoch_length_s %|| nq < minEpochs*epoch_length_s
%             continue;
%         end
        if np < M-4
            continue;
        end
        
        % fill the array only with values that are valid
        x = nan(1, size(sigmaMatch,2));
        x((M-np+1):(M+1)) = band_timeseries((ps-np):ps); % state a
        x((M+1):(M+1+nq)) = band_timeseries(qs:(qs+nq)); % state b
        
        sigmaMatch(k,:) = x;
        %plot(sigmaMatch(k,:))
        %hold on
        k = k + 1;
    end

    sigmaMatch_mean = mean(sigmaMatch, 1, 'omitnan');
    sigmaMatch_std = std(sigmaMatch, 1, 'omitnan');
    
    sigmaMatch_times = -M:(M+1);
end