function [band_power_timeseries] = compute_band_power_timeseries(spectrogram, spectrogram_freq, f_low, f_high)
	ind = intersect(find(spectrogram_freq >= f_low), find(spectrogram_freq <= f_high));

    numSamples = size(spectrogram,2);
    band_power_timeseries = zeros(1, numSamples);
    for i = 1:numSamples
        band_power_timeseries(i) = trapz(spectrogram_freq(ind), spectrogram(ind,i));
    end
end % function