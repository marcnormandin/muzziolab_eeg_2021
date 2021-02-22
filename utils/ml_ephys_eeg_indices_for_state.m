function [eegIndices] = ml_ephys_eeg_indices_for_state(scores, epoch_size_s, iState, fs)
% This function returns indices into the EEG time series that are for the
% given state, where the sampling rate of the EEG is 'fs' Hz (typically 400
% Hz).

    record = ml_ephys_bayesclassifier_scores_to_epoch_records(scores);
    reci = find([record.state] == iState);
    r = record(reci);
    epochs = [r.epochs]; % These are all indices of valid epochs for the state

    % Convert from epochs to time indices into the wavelet matrix
    eegIndices = [];
    for j = 1:length(epochs)
       k = epochs(j);
       k1 = (k-1)*fs*epoch_size_s + 1;
       k2 = k*fs*epoch_size_s;

       eegIndices = [eegIndices, k1:k2];
    end
end