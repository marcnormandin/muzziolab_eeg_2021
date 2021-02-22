function [settings] = load_settings()

    settings = {};
    settings.CODE_WAKE = 1;
    settings.CODE_NREM = 2;
    settings.CODE_REM = 3;
    settings.CODE_QUIETWAKE = 4;
    settings.parentAnalysisFolder = 'T:\EPHYS_SLEEP_STUDY\analysis_cellreports';

    settings.EPOCH_LENGTH_S = 4; % 4 seconds per epoch/score
    settings.FNTSZ = 12;
    settings.eegSelected = 2;
    settings.total_power_f_low = 0;
    settings.total_power_f_high = 100.0;
    settings.f_low = 0.1; % filter frequencies below this
    settings.f_high = 100; % filter frequencies above this
    settings.spectrogram_freq = 0.25:0.25:settings.f_high;
    settings.spectrogram_window_size_s = 4; % seconds
    settings.sigmaMatch_t_before_and_after = 60; % seconds
    
    settings.bands = load_bands_info();
    
    settings.bandMap = containers.Map;
    for i = 1:length(settings.bands)
        settings.bandMap(settings.bands(i).name) = i;
    end
    
    settings.scoreMap = containers.Map;
    settings.scoreMap('WAKE') = settings.CODE_WAKE;
    settings.scoreMap('NREM') = 2;
    settings.scoreMap('REM') = 3;
    
    settings.scoreToTextMap = containers.Map;
    settings.scoreToTextMap(int2str(settings.CODE_WAKE)) = 'WAKE';
    settings.scoreToTextMap(int2str(settings.CODE_NREM)) = 'NREM';
    settings.scoreToTextMap(int2str(settings.CODE_REM)) = 'REM';

end % function