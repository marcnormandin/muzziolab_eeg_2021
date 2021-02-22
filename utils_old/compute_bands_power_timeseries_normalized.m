function [band_power_timeseries, total_power_timeseries, sample_times] = compute_bands_power_timeseries_normalized(settings, spectrogram, spectrogram_freq, bands)
    % Compute the total power time series
    total_power_timeseries = compute_band_power_timeseries(spectrogram, spectrogram_freq, settings.total_power_f_low, settings.total_power_f_high);
    numTimeSamples = length(total_power_timeseries);

    % Compute the power for each band
    numBands = length(bands);
    band_power_timeseries = nan(numBands, numTimeSamples); % allocate memory
    for iBand = 1:numBands
        band_power_timeseries(iBand,:) = compute_band_power_timeseries(spectrogram, spectrogram_freq, bands(iBand).f_low, bands(iBand).f_high);

        % Normalize
        band_power_timeseries(iBand,:) = band_power_timeseries(iBand,:) ./ total_power_timeseries;
    end
    
    % One sample per second
    sample_times = (0:(numTimeSamples-1));
end % function