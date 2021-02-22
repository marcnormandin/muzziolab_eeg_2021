function [x] = filter_eeg(eeg, fs, f_low, f_high)
    x = remove_line_noise(eeg, fs);
    x = lowpass(x, f_high, fs);
    x = highpass(x, f_low, fs);
end