function [nrem_bouts_final] = ml_ephys_get_bouts_nrem_filtered(scores, epoch_length_s, state_code_nrem)
    % compute the bouts
    bouts = ml_ephys_scores_get_bouts(scores);

    % get the nrem bouts
    nrem_bouts = bouts([bouts.state_code] == state_code_nrem);

    % now get the ones that are of sufficient duration
    duration_min_epochs = 24;
    nrem_bouts_long_duration = nrem_bouts([nrem_bouts.count] >= duration_min_epochs);

    % use only those within the first 100 mins
    max_epoch_end = 100 * 60 / epoch_length_s;

    nrem_bouts_final = nrem_bouts_long_duration([nrem_bouts_long_duration.epoch_start] <= max_epoch_end);
end % function
