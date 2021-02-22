function [waveletIndices] = ml_ephys_wavelet_indices_for_state(scores, epoch_size_s, iState, waveletFs)
    record = ml_ephys_bayesclassifier_scores_to_epoch_records(scores);
    reci = find([record.state] == iState);
    r = record(reci);
    epochs = [r.epochs]; % These are all indices of valid epochs for the state

    % Convert from epochs to time indices into the wavelet matrix
    waveletIndices = [];
    for j = 1:length(epochs)
       k = epochs(j);
       k1 = (k-1)*waveletFs*epoch_size_s + 1;
       k2 = k*waveletFs*epoch_size_s;

       waveletIndices = [waveletIndices, k1:k2];
    end
end