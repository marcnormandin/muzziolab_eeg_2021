close all
clear all
clc

settings = ml_sleepstudy_settings_load();
mouseTable = ml_sleepstudy_mousetable_load(settings)
numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'wavelet_state_spectrums');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%%
%hMain = figure();

sumTotalSpectrum = cell(1, numMice);
averageTotalSpectrumPower = cell(1,numMice);
averageTotalPower = cell(1, numMice);
waveletIndices = cell(numMice, 3);
meanSpectrum = cell(numMice,3); % Spectrum depending on state
totalSpectrum = cell(1, numMice); % Spectrum regardless of state

for iMouse = 1:numMice

    mouse = mouseTable(iMouse,:);
    
    fprintf('Processing %d of %d: %s\n', iMouse, numMice, mouse.codename{1});
    
    scores = mouse.scores{1};

    %% Load the eeg data
    eegFullFilename = mouse.eegFullFilename{1};    
    [eeg1, eeg2, emg, fs] = ml_ephys_load_eeg_edf( eegFullFilename );
    if mouse.eegSelected == 1
        eeg = eeg1;
    elseif mouse.eegSelected == 2
        eeg = eeg2;
    else
        error('settings.eegSelected must be 1 or 2.');
    end
    
    % Normalization by computing a z-score on the wake state (if we have
    % scores, otherwise use entire eeg).
    if ~isempty(scores)
        eegIndicesWake = ml_ephys_eeg_indices_for_state(scores, settings.EPOCH_LENGTH_S, settings.CODE_WAKE, fs);
        eegWake = eeg(eegIndicesWake);
    else
        eegWake = eeg;
    end
    meanWake = mean(eegWake);
    stdWake = std(eegWake);
    eeg = (eeg - meanWake) ./ stdWake;
    
    
    %% Compute the wavelets
    [awt, waveletFreqs, waveletFs, dsample] = ml_ephys_wavelet_compute(eeg, fs, settings.waveletsDownsampleFactor);

    %% If needed, plot the full wavelets
%     figure
%     %imagesc('XData', 1:(size(wt,2)/(dfs*60*60)), 'YData', f, 'CData', abs(wt))
%     imagesc(awt)
%     colormap jet
%     grid on
%     %set(gca, 'ydir', 'reverse')
%     p = 10;
%     set(gca, 'ytick', 1:p:size(awt,1), 'yticklabels', waveletFreqs(1:p:end))
%     set(gca, 'xtick', 1:(waveletFs*60*60):size(awt,2), 'xticklabels', (0:(waveletFs*60*60):size(awt,2))/(waveletFs*60*60))

    %%
    
    %totalPower = sum(awt,2);
%     figure
    %waveletIndices = {};
    %meanM = {};
    sumTotalSpectrum{iMouse} = sum(awt, 'all');
    averageTotalSpectrum = mean(awt, 2);
    averageTotalSpectrumPower{iMouse} = averageTotalSpectrum.^2;
    averageTotalPower{iMouse} = mean(averageTotalSpectrumPower{iMouse}, 'all');
    
    % Total spectrum, regardless of state
    Mw = awt;
    % Now interpolate it so that the frequencies are spaced linearly.
    M = ml_ephys_wavelet_interpolate(Mw, waveletFreqs, settings.waveletsInterpFreqs);
    totalSpectrum{iMouse} = mean(M,2).^2;
    
    % These require scores
    for iState = 1:3
        if ~isempty(scores)
            [waveletIndices{iMouse, iState}] = ml_ephys_wavelet_indices_for_state(scores, settings.EPOCH_LENGTH_S, iState, waveletFs);

            Mw = awt(:, waveletIndices{iMouse, iState});
            % Now interpolate it so that the frequencies are spaced linearly.
            M = ml_ephys_wavelet_interpolate(Mw, waveletFreqs, settings.waveletsInterpFreqs);
            statePower = mean(M,2).^2;
            meanSpectrum{iMouse, iState} = statePower;
        else
            meanSpectrum{iMouse, iState} = [];
            waveletIndices{iMouse, iState} = [];
        end
%         subplot(2,3,iState)
%         imagesc(M)
%         title(settings.scoreToTextMap(num2str(iState)));
%         colormap jet
%         colorbar
%         %caxis([50,200])
%         p = 4;
%         set(gca, 'ytick', 1:p:size(M,1), 'yticklabels', settings.waveletsInterpFreqs(1:p:end))
%         %set(gca, 'ytick', 1:p:size(awt,1), 'yticklabels', waveletF(1:p:end))
%         %set(gca, 'xtick', 1:(waveletFs*60*60):size(awt,2), 'xticklabels', (0:(waveletFs*60*60):size(awt,2))/(waveletFs*60*60))
%         
%         subplot(2,3,iState + 3)
%         
% %         df = median(abs(diff(settings.waveletsInterpFreqs)));
% %         nf = length(meanM) - 1;
% %         densityM = meanM ./ (nf * df * sum(meanM));
%         plot(settings.waveletsInterpFreqs, meanM{iState}, 'k-', 'linewidth', 2)
%         grid on
        
    end
    
%     clf(hMain, 'reset')
%     set(gcf, 'name', mouse.codename{1});
%     plot(settings.waveletsInterpFreqs, meanSpectrum{iMouse, 1}, 'r-', 'linewidth', 2)
%     hold on
%     plot(settings.waveletsInterpFreqs, meanSpectrum{iMouse, 2}, 'g-', 'linewidth', 2)
%     plot(settings.waveletsInterpFreqs, meanSpectrum{iMouse, 3}, 'b-', 'linewidth', 2)
%     legend({'Wake', 'NREM', 'REM'})
%     ylabel('Average wavelet value', 'fontweight', 'bold')
%     xlabel('Frequency, f [Hz]', 'fontweight', 'bold')
%     grid on
%     
% 
%     
%     outputFilename = fullfile(outputFolder, sprintf('%s.pdf', mouse.codename{1}));
%     saveas(hMain, outputFilename);
%     outputFilename = fullfile(outputFolder, sprintf('%s.png', mouse.codename{1}));
%     saveas(hMain, outputFilename);
end % iMouse

%%
freqs = settings.waveletsInterpFreqs;
save(fullfile(outputFolder, 'workspace'), 'settings', 'meanSpectrum', 'totalSpectrum', 'mouseTable', 'freqs', 'averageTotalSpectrumPower', 'averageTotalPower', 'sumTotalSpectrum');
