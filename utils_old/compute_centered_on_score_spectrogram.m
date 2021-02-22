% Compute the spectrogram
function [spectrogram] = compute_centered_on_score_spectrogram(eeg_raw, fs, f_low, f_high, spectrogram_freq, epoch_length_s, scores)
    num_scores = length(scores);

    % Filter the eeg
    feeg = filter_eeg(eeg_raw, fs, f_low, f_high);
    
    % Window size of the data in seconds for which we will compute
    % the spectrogram
    samples_per_score = epoch_length_s * fs;
    
    window_size_n = samples_per_score; % 1600 samples per epoch
    
    spectrogram = zeros(length(spectrogram_freq), num_scores);
    
    for iScore = 1:num_scores
        % Compute the spectrum symmetric about the given time
        p = (iScore-1)* window_size_n + 1;
        q = iScore * window_size_n;
        
        if p < 1
            p = 1;
        end
        
        if q > length(feeg)
            q = length(feeg);
        end
        x = feeg(p:q);
        [Pxx,~] = pwelch(x,[],[],spectrogram_freq,fs,'psd');
        spectrogram(:,iScore) = Pxx';
    end

end % function