function [normalizedSpectrums] = ml_wavelet_state_spectrums_normalize_by_state(meanSpectrum)
% The input 'meanSpectrum' has not been normalized, and this code
% normalized each mouses state spectrum so that the total for each state is
% 1. The input should be a numMice x numStates cell array.

    if isempty(meanSpectrum)
        warning('Input meanSpectrum is empty. Returning empty.');
        normalizedSpectrums = [];
        return
    end

    numMice = size(meanSpectrum, 1);
    numStates = size(meanSpectrum, 2);
    
    normalizedSpectrums = cell(size(meanSpectrum));
    for iMouse = 1:numMice
        for iState = 1:numStates
            x = meanSpectrum{iMouse, iState};
            s = sum(x, 'all');
            x = x ./ s;
            normalizedSpectrums{iMouse, iState} = x;
        end
    end
    
end % function