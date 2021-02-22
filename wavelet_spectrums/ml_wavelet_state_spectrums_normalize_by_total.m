function [normalizedSpectrums] = ml_wavelet_state_spectrums_normalize_by_total(meanSpectrum)
% The input 'meanSpectrum' has not been normalized, and this code
% normalized each mouses state spectrum so that the total across all states
% is 1.

    if isempty(meanSpectrum)
        warning('Input meanSpectrum is empty. Returning empty.');
        normalizedSpectrums = [];
        return
    end

    numMice = size(meanSpectrum, 1);
    numStates = size(meanSpectrum, 2);
    
    normalizedSpectrums = cell(size(meanSpectrum));
    for iMouse = 1:numMice
        mouseTotal = 0;
        for iState = 1:numStates
            mouseTotal = mouseTotal + sum(meanSpectrum{iMouse, iState});
        end

        for iState = 1:numStates
            x = meanSpectrum{iMouse, iState};
            normalizedSpectrums{iMouse, iState} = x / mouseTotal;
        end
    end
    
end % function