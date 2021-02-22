close all
clear all
clc

settings = ml_sleepstudy_settings_load();
mouseTable = ml_sleepstudy_mousetable_load(settings)
numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'scored_figures');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%hMain = figure();

%%
hMain = figure('position', get(0, 'screensize'));

for iMouse = 1:numMice
    fprintf('Processing %d of %d.\n', iMouse, numMice);
    mouse = mouseTable(iMouse,:)
    make_scored_figure(settings, mouse, hMain);
    saveas(hMain, fullfile(outputFolder, sprintf('%s.png', mouse.codename{1})));
    saveas(hMain, fullfile(outputFolder, sprintf('%s.svg', mouse.codename{1})));
    savefig(hMain, fullfile(outputFolder, sprintf('%s.fig', mouse.codename{1})));
    %savas(hMain, fullfile(outputFolder, sprintf('%s.png', mouse.codename{1})));
end

fprintf('Done making figures.\n');


function make_scored_figure(settings, mouse, hMain)
    scores = mouse.scores{1};

    %%
    % Load the EEG data
    eegFullFilename = mouse.eegFullFilename{1};    
    [eeg1, eeg2, emg, fs] = ml_ephys_load_eeg_edf( eegFullFilename );
    if mouse.eegSelected == 1
        eeg = eeg1;
    elseif mouse.eegSelected == 2
        eeg = eeg2;
    else
        error('settings.eegSelected must be 1 or 2.');
    end

    %%
    scoreRecords = ml_ephys_bayesclassifier_scores_to_epoch_records(scores);
    p = 3;
    q = 1;
    for iState = 1:3
        %stateEegIndices{iState} = ml_ephys_wavelet_indices_for_state(scores, settings.EPOCH_LENGTH_S, iState, fs);
        recordState{iState} = record_to_eeg_indices(scores, settings.EPOCH_LENGTH_S, iState, fs);
    end

    t_secs = (0:1:(length(eeg1)-1))/fs;
    t_epochs = t_secs/settings.EPOCH_LENGTH_S;
    t_hrs = t_secs / 3600;
    
    clf(hMain, 'reset');

    ax(1) = subplot(p,q,1);
    plot_scored_timeseries(t_hrs, eeg1, recordState, settings)
    title('EEG 1')

    ax(2) = subplot(p,q,2);
    plot_scored_timeseries(t_hrs, eeg2, recordState, settings)
    title('EEG 2')

    ax(3) = subplot(p,q,3);
    plot_scored_timeseries(t_hrs, emg, recordState, settings)
    title('EMG')

    linkaxes(ax, 'x')

    axis tight
end


function plot_scored_timeseries(t, x, recordState, settings)
    for iState = 1:3
        r = recordState{iState};
        for iBlock = 1:length(r)
            plot(t(r(iBlock).eeg_indices), x(r(iBlock).eeg_indices), '-', 'color', settings.scoreColourMap(settings.scoreToTextMap(int2str(iState))))
            hold on
        end
        
    end
end

function [r] = record_to_eeg_indices(scores, epoch_size_s, iState, fs)
    record = ml_ephys_bayesclassifier_scores_to_epoch_records(scores);
    reci = find([record.state] == iState);
    r = record(reci);
    
    
    % Convert from epochs to time indices into the wavelet matrix
    for j = 1:length(r)
       kstart = r(j).epochs(1);
       kend = r(j).epochs(end);
       
       k1 = (kstart-1)*fs*epoch_size_s + 1;
       k2 = kend*fs*epoch_size_s;

       r(j).eeg_indices = k1:k2;
    end
end
