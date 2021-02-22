close all
clear all
clc

settings = ml_sleepstudy_settings_load();
mouseTable = ml_sleepstudy_mousetable_load(settings)
numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'new_scores');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%hMain = figure();

%%
iMouse = find(ismember(mouseTable.codename, 'AT_20_Y_D_R'))
if isempty(iMouse)
    error('Mouse not found');
end

mouse = mouseTable(iMouse,:)

scores = mouse.scores{1};


%%
% Load the EEG data
eegFullFilename = mouse.eegFullFilename{1};    
[eeg1, eeg2, emg, fs] = ml_ephys_load_eeg_edf( eegFullFilename );
if settings.eegSelected == 1
    eeg = eeg1;
elseif settings.eegSelected == 2
    eeg = eeg2;
else
    error('settings.eegSelected must be 1 or 2.');
end

%%
close all
scoreRecords = ml_ephys_bayesclassifier_scores_to_epoch_records(scores)
hMain = figure('position', get(0, 'screensize'));
p = 3;
q = 1;
for iState = 1:3
    %stateEegIndices{iState} = ml_ephys_wavelet_indices_for_state(scores, settings.EPOCH_LENGTH_S, iState, fs);
    recordState{iState} = record_to_eeg_indices(scores, settings.EPOCH_LENGTH_S, iState, fs);
end

t_secs = (0:1:(length(eeg1)-1))/fs;
t_epochs = t_secs/settings.EPOCH_LENGTH_S;

ax(1) = subplot(p,q,1);
plot_scored_timeseries(t_epochs, eeg1, recordState, settings)
% for iState = 1:3
%     r = recordState{iState};
%     for iBlock = 1:length(r)
%         plot(t_epochs(r(iBlock).eeg_indices), eeg1(r(iBlock).eeg_indices), '-', 'color', settings.scoreColourMap(settings.scoreToTextMap(int2str(iState))))
%     end
%     hold on
% end

ax(2) = subplot(p,q,2);
plot_scored_timeseries(t_epochs, eeg2, recordState, settings)

ax(3) = subplot(p,q,3);
plot_scored_timeseries(t_epochs, emg, recordState, settings)

linkaxes(ax, 'x')

axis tight

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
