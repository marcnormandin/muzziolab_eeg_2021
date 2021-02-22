% Sleep Study Paper 2020
% Marc Normandin
% 2020-07-20 - Started this script after meeting initiated because of the
% latest review of the paper by the journal.
% 2020-08-03 - Modified the code again after using new scores.
% 2021-01-07 - Started this based on v5. Goal is to add plot like Figure
% 3.H from Uygun automated sleep scoring paper (Spindle # vs transition
% time).
close all
clear all
clc

datasetFolder = 'T:\EPHYS_SLEEP_STUDY\datasets\dataset_8_corrected_scores';

settings = load_settings();
settings.sigmaMatch_t_before_and_after = 30;
%settings.spectrogram_window_size_s = 8;
settings.outputFolder = fullfile(settings.parentAnalysisFolder, 'sigma_transitions_pwelch');
if ~exist(settings.outputFolder, 'dir')
    mkdir(settings.outputFolder);
end

dataset = men_edf_get_filenames( datasetFolder );
% Filter the bad mice
[badi] = find_badmice_indices_in_dataset(dataset);
if ~isempty(badi)
    dataset(badi) = [];
end

numMice = length(dataset);


nremToRemMeans = zeros(numMice, 2*settings.sigmaMatch_t_before_and_after+2);
remToNremMeans = zeros(numMice, 2*settings.sigmaMatch_t_before_and_after+2);
wakeToNremMeans = zeros(numMice, 2*settings.sigmaMatch_t_before_and_after+2);

start_bulk_tic = tic;

%iMouse = 7;
for iMouse = 1:numMice
    %try
    mouseInfo = dataset(iMouse);
    edfFilename = mouseInfo.fullFilename;
    scoredFilename = strrep(edfFilename, '.edf', '_scores.xlsx');
    
    start_tic = tic;
    fprintf('Processing mouse %d of %d: %s ...', iMouse, numMice, mouseInfo.fullname);

    
    % Load the scores (1 every 4 seconds)
    [y_scoreAlgo, ~] = ml_ephys_load_scores_xlsx( scoredFilename );
    
    % Post-process the scores the way Isabel wants. Set the

    % Load the EPHYS data
    [edfData,edfHeader,edfCfg] = men_edf_read( edfFilename );
    fs = edfHeader.samplingrate;
    eegr = edfData(settings.eegSelected,:);

    % Compute the spectrogram in 1 second intervals
    [spectrogram, time_samples, freq_samples] = compute_spectrogram_v3(eegr, fs, settings.f_low, settings.f_high, settings.spectrogram_window_size_s, 'pwelch');

    band = settings.bands(settings.bandMap('sigma'));

        
    % Integrate the spectrum in 1 second intervals for each band
    %[band_power_timeseries, sample_times] = compute_bands_power_timeseries_normalized(settings, spectrogram, settings.spectrogram_freq, settings.bands);
    sigma_power_vs_time = compute_band_power_timeseries_v3(spectrogram, freq_samples, band.f_low, band.f_high);
    
    % Normalize to mean sigma power in nrem over the entire recording
    % Expand the scores to 1 per second to match the time series
    scores_per_second = repelem(y_scoreAlgo, settings.EPOCH_LENGTH_S);
    % Truncate it to be the same size as the time series
    if length(scores_per_second) > length(sigma_power_vs_time)
        scores_per_second(length(sigma_power_vs_time)+1:end) = [];
    end
    % Now find all matching NREM instances
    nremi = find(scores_per_second == settings.CODE_NREM);
    sigma_power_vs_time_mean = mean(sigma_power_vs_time(nremi));
    
    sigma_power_vs_time_normalized_nrem = sigma_power_vs_time ./ sigma_power_vs_time_mean;
    
    
    % NREM to REM
    [sigmaMatch, sigmaMatch_mean, sigmaMatch_std, sigmaMatch_times, matchesi] = get_sigma_transition_match_v4(...
        settings.sigmaMatch_t_before_and_after, settings.EPOCH_LENGTH_S, time_samples, sigma_power_vs_time_normalized_nrem, y_scoreAlgo, settings.CODE_NREM, settings.CODE_REM);
    nremToRemMeans(iMouse,:) = sigmaMatch_mean;
    
%     % REM to NREM
    [sigmaMatch, sigmaMatch_mean, sigmaMatch_std, sigmaMatch_times] = get_sigma_transition_match_v4(...
        settings.sigmaMatch_t_before_and_after, settings.EPOCH_LENGTH_S, time_samples, sigma_power_vs_time_normalized_nrem, y_scoreAlgo, settings.CODE_REM, settings.CODE_NREM);
    remToNremMeans(iMouse,:) = sigmaMatch_mean;
    
%     % Wake to NREM
    [sigmaMatch, sigmaMatch_mean, sigmaMatch_std, sigmaMatch_times] = get_sigma_transition_match_v4(...
        settings.sigmaMatch_t_before_and_after, settings.EPOCH_LENGTH_S, time_samples, sigma_power_vs_time_normalized_nrem, y_scoreAlgo, settings.CODE_WAKE, settings.CODE_NREM);
    wakeToNremMeans(iMouse,:) = sigmaMatch_mean;
    
    fprintf('done! (%0.25f mins)\n', toc(start_tic)/60);
    
%     catch ME
%         mouseInfo = dataset(iMouse);
%         fprintf('Error processing: %s\n', mouseInfo.fullname);
%         continue;
%     end
end

time_bulk_hours = toc(start_bulk_tic)/60/60;
fprintf('Total computation time was %0.2f hours.\n', time_bulk_hours);

%%
save(fullfile(settings.outputFolder, 'workspace_sigma_transitions_ds8_v5.mat'));
