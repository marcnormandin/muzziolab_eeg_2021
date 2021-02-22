function [fourierIndices] = ml_ephys_fourier_indices_for_state(scores, epoch_size_s, iState, fourierSampleTimes)
    record = ml_ephys_bayesclassifier_scores_to_epoch_records(scores);
    reci = find([record.state] == iState);
    r = record(reci);
    epochs = [r.epochs]; % These are all indices of valid epochs for the state

    % Convert from epochs to time indices into the wavelet matrix
    fourierIndices = [];
    for j = 1:length(epochs)
       k = epochs(j);
       
       % These are indices into the times of the sampled time series, but
       % we need to pair them with times into the Fourier times.
%        k1 = (k-1)*waveletFs*epoch_size_s + 1;
%        k2 = k*waveletFs*epoch_size_s;
       
       t1 = (k-1)*epoch_size_s; % times in seconds
       t2 = k*epoch_size_s;
       
       indices = intersect(find(fourierSampleTimes >= t1), find(fourierSampleTimes<=t2));

       fourierIndices = [fourierIndices, indices];
    end
    fourierIndices = unique(fourierIndices);
end