function [settings] = ml_sleepstudy_settings_load()
    set(groot, 'defaultAxesFontWeight', 'bold')
    set(groot, 'defaultAxesFontSize', 22)

    settings = {};
    settings.CODE_WAKE = 1;
    settings.CODE_NREM = 2;
    settings.CODE_REM = 3;
    %settings.CODE_QUIETWAKE = 4;
    
    % This is the main/standard analysis
    settings.parentAnalysisFolder = 'T:\projects\eeg_2021\analysis_included_excluded';
    settings.datasetFolder = 'T:\projects\eeg_2021\datasets\dataset_10_included_excluded';

%     settings.datasetFolder = 'T:\projects\eeg_2021\datasets\dataset_1_before_renaming\excluded';
%     settings.parentAnalysisFolder = 'T:\projects\eeg_2021\datasets\dataset_1_excluded';

    % This is the additional one (no scores)
% %     settings.parentAnalysisFolder = 'T:\projects\eeg_2021\analysis_sleep_deprivation_period';
% %     settings.datasetFolder = 'T:\projects\eeg_2021\datasets\dataset_11_sleep_deprivation_period';
    
    
    if ~exist(settings.parentAnalysisFolder, 'dir')
        mkdir(settings.parentAnalysisFolder);
    end
    
    % These are mice that we don't want use
    settings.badMice = {}; %{'AEG_2_O_C_P', 'AEG_98_Y_D_R', 'MT_8_Y_C_R'};

    settings.EPOCH_LENGTH_S = 4; % 4 seconds per epoch/score
    settings.FNTSZ = 12;
    settings.eegSelectedDefault = 1; % 1 or 2
    settings.total_power_f_low = 0;
    settings.total_power_f_high = 100.0;
    settings.f_low = 0.1; % filter frequencies below this
    settings.f_high = 100; % filter frequencies above this
    settings.spectrogram_freq = 0.25:0.25:settings.f_high;
    settings.spectrogram_window_size_s = 4; % seconds
    settings.sigmaMatch_t_before_and_after = 60; % seconds
    
    settings.bands = ml_ephys_load_bands_info();
    
    settings.bandMap = containers.Map;
    for i = 1:length(settings.bands)
        settings.bandMap(settings.bands(i).name) = i;
    end
    
    settings.use_fixed_scores = 1;
    
    % wavelet stuff
    settings.waveletsDownsampleFactor = 2; % Wavelets will go up to 100 Hz.
    settings.waveletsInterpFreqs = 30:-0.25:0.25; % Must be decreasing
    
    settings.scoreMap = containers.Map;
    settings.scoreMap('WAKE') = settings.CODE_WAKE;
    settings.scoreMap('NREM') = settings.CODE_NREM;
    settings.scoreMap('REM') = settings.CODE_REM;
    
    settings.scoreColourMap = containers.Map;
    settings.scoreColourMap('WAKE') = [1, 0, 0];
    settings.scoreColourMap('NREM') = [0, 1, 0];
    settings.scoreColourMap('REM') = [0, 0, 1];
    
    settings.scoreToTextMap = containers.Map;
    settings.scoreToTextMap(int2str(settings.CODE_WAKE)) = 'WAKE';
    settings.scoreToTextMap(int2str(settings.CODE_NREM)) = 'NREM';
    settings.scoreToTextMap(int2str(settings.CODE_REM)) = 'REM';
    
    % Spindles
    % SpindleCode version to use
    spindleVersion_1 = 'v17_4s'; % This is the first version we used and whose data was submitted to referees
    spindleVersion_2 = 'v17_5s'; % This is the second version given to us on 2020-03-11
    settings.spindleVersion = spindleVersion_2;

end % function