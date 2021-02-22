% Compute the spectrogram
function [spectrogram] = compute_spectrogram(eeg_raw, fs, f_low, f_high, spectrogram_freq, window_size)
    % Limit the data length
    t_max_s = floor(length(eeg_raw)/fs);
    eeg_raw((t_max_s*fs)+1:end) = [];

    % Filter the eeg
    feeg = filter_eeg(eeg_raw, fs, f_low, f_high);
    
    % Window size of the data in seconds for which we will compute
    % the spectrogram
    Ws = window_size; 
    
    M = floor(window_size*fs/2) + 1; % number of one-sided freqs
    spectrogram = zeros(M, t_max_s);
    
    for t = 1:t_max_s
        % Compute the spectrum symmetric about the given time
        
        % start of the windowed data in indices
        p = (t - Ws/2)*fs; 
        if p < 1
            p = 1;
        end
        
        % end of the windowd data in indices
        q = p + Ws*fs;
        if q > length(feeg)
            q = length(feeg);
        end
        x = feeg(p:q);
        % The default is a Hamming window
        %[Pxx,~] = pwelch(x,[],[],spectrogram_freq,fs,'power', 'onesided');
        [Pxx,~] = pwelch(x,[],[],fs,'power', 'onesided');
        spectrogram(:,t) = Pxx';
    end

end % function