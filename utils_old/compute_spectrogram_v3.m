% Compute the spectrogram
function [spectrogram, time_samples, freq_samples] = compute_spectrogram_v3(eeg_raw, fs, f_low, f_high, window_size_s, method)
    % Limit the data length
    t_max_s = floor(length(eeg_raw)/fs);
    eeg_raw((t_max_s*fs)+1:end) = [];


    % Filter the eeg
    feeg = filter_eeg(eeg_raw, fs, f_low, f_high);
    
    % Window size of the data in seconds for which we will compute
    % the spectrogram
    Ws = window_size_s; 
    
    N = window_size_s*fs;
    M = floor(N/2) + 1; % number of one-sided freqs
    time_samples = 1:t_max_s;
    freq_samples = (0:(M-1)) * fs / N;
    
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
        
        if q - p ~= N
            continue
        end
        
        x = feeg(p:q);
        % The default is a Hamming window
        %[Pxx,~] = pwelch(x,[],[],spectrogram_freq,fs,'power', 'onesided');
        %[Pxx,~] = pwelch(x,[],[],fs,'power', 'onesided');
        if strcmpi(method, 'fft')
            [P_rms, ~] = ml_ephys_power_rms(x, fs);
        elseif strcmpi(method, 'pwelch')
            [P_rms, ~] = pwelch(x,[],[],freq_samples,fs,'power', 'onesided');
        else
            error('Method must be fft or pwelch');
        end
        
        %[Pxx, freq_samples] = ml_ephys_power_rms(x, fs);
        spectrogram(:,t) = P_rms';
    end

end % function