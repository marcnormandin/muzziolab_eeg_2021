function [awt, f, waveletFs, dsample] = ml_ephys_wavelet_compute(eeg, fs, downsampleFactor)
    dsample = downsample(eeg, downsampleFactor); % downsampled data
    waveletFs = fs / downsampleFactor;
    [wt, f, coi, fb, scalingcfs] = cwt(dsample, 'morse', waveletFs);
    awt = abs(wt);
end
