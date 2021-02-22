function [bouts] = ml_ephys_scores_get_bouts(scores)
    numScores = length(scores);

    bouts = struct('state_code', [], 'count', [], 'epoch_start', [], 'epoch_end', []);

    processing_state = -1;
    processing_count = -1;
    processing_epoch_start = -1;

    for iScore = 1:numScores
        state = scores(iScore);
        if state ~= processing_state
            k = length(bouts) + 1;
            bouts(k).epoch_start = processing_epoch_start;
            bouts(k).epoch_end = iScore-1;
            
            bouts(k).state_code = processing_state;
            bouts(k).count = processing_count;

            processing_epoch_start = iScore;
            processing_state = state;
            processing_count = 1;
        else
            processing_count = processing_count + 1;
        end
    end
    bouts(1:2) = []; % first is [],[], and second is -1,-1
end % function
