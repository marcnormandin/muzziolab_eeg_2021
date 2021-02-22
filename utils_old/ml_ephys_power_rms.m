% Computes the rms power of x using the fft
function [P_rms, f] = ml_ephys_power_rms(x, fs)
    N = length(x);
    M = floor(N/2)+1;
    f = (0:(M-1)) *fs / N; % sampling frequencies

    X = fft(x);
    Ptwo = abs(X).^2 / N;
    
    % one sided
    Pone = 2.*Ptwo(1:M);
    Pone(1) = Pone(1) / 2; % Dc term should not be doubled

    % RMS Amplitude (one sided)
    A_rms = sqrt(Pone./N);
    
    % RMS Power (one sided)
    P_rms = A_rms.^2;
end % function
