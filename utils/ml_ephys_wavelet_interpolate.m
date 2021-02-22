function [M] = ml_ephys_wavelet_interpolate(awt, waveletFreqs, interpFreqs)
% This function takes a wavelet matrix that was already computed and then
% interpolates the values to form a new matrix at the frequencies that we
% want. The interpFreqs must go from HIGH to LOW.
    if any(diff(interpFreqs) > 0)
        error('interpolation frequencies must go from HIGH to LOW.');
    end

    % Wavelet values
    [X,Y] = meshgrid(1:size(awt,2), waveletFreqs);

    % Interpolate values
    [Xq,Yq] = meshgrid(1:size(awt,2),interpFreqs);
    
    % Interpolate wavelet matrix on new frequencies
    M = interp2(X,Y,awt,Xq,Yq);
    
end