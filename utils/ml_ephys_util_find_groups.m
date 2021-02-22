function [record] = ml_ephys_util_find_groups(x, value)
    record = ml_ephys_bayesclassifier_scores_to_epoch_records(x == value);
    record([record.state] == 0) = [];
end
