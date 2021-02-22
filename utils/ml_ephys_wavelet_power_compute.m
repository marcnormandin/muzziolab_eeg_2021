function [pwt, f, waveletFs, dsample] = ml_ephys_wavelet_power_compute(timeseries, fs, downsampleFactor)
    dsample = decimate(timeseries, downsampleFactor); % downsampled data
    waveletFs = fs / downsampleFactor;
    [wt, f, coi, fb, scalingcfs] = cwt(dsample, 'morse', waveletFs);
    awt = abs(wt);
    pwt = awt.^2;
end
