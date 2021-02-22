function [eeg1, eeg2, emg, fs] = ml_ephys_load_eeg_edf( edfFilename )
% Computes the delta power for each of the two EEG time series in a given
% EDF-formatted data file.

[data,header] = ml_ephys_load_eeg_edf_raw(edfFilename);

fs = header.samplingrate; %400; % samples per second

eeg1 = data(1,:);
eeg2 = data(2,:);
emg = data(3,:);

end % function
