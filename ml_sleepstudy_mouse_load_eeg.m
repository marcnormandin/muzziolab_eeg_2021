function [eeg, fs] = ml_sleepstudy_mouse_load_eeg(mouse)    
    eegFullFilename = mouse.eegFullFilename{1};    
    [eeg1, eeg2, emg, fs] = ml_ephys_load_eeg_edf( eegFullFilename );
    if mouse.eegSelected == 1
        eeg = eeg1;
    elseif mouse.eegSelected == 2
        eeg = eeg2;
    else
        error('settings.eegSelected must be 1 or 2.');
    end
    
end % function
    