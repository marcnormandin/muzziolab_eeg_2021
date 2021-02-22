function [waveletPowerSpectrogram, waveletFreqs, waveletFs, waveletTimes, eegDownsampled, eeg, eegFs] =  ml_sleepstudy_mouse_wavelet_powerspectrogram_compute(settings, mouse)
    
    
    scores = mouse.scores{1};

    %% Load the eeg data
    eegFullFilename = mouse.eegFullFilename{1};    
    [eeg1, eeg2, emg, eegFs] = ml_ephys_load_eeg_edf( eegFullFilename );
    if mouse.eegSelected == 1
        eeg = eeg1;
    elseif mouse.eegSelected == 2
        eeg = eeg2;
    else
        error('settings.eegSelected must be 1 or 2.');
    end
    
    % Normalization by computing a z-score on the wake state (if we have
    % scores, otherwise use entire eeg).
    if ~isempty(scores)
        eegIndicesWake = ml_ephys_eeg_indices_for_state(scores, settings.EPOCH_LENGTH_S, settings.CODE_WAKE, eegFs);
        eegWake = eeg(eegIndicesWake);
    else
        eegWake = eeg;
    end
    meanWake = mean(eegWake);
    stdWake = std(eegWake);
    eeg = (eeg - meanWake) ./ stdWake;
    
    
    %% Compute the wavelets
    [awt, waveletFreqs, waveletFs, eegDownsampled] = ml_ephys_wavelet_compute(eeg, eegFs, settings.waveletsDownsampleFactor);
    waveletPowerSpectrogram = awt.^2;
    
    % Wavelet sample times
    waveletTimes = (0:(length(eegDownsampled)-1)) / waveletFs;
end