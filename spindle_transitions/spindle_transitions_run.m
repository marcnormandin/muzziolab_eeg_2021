close all
clear all
clc

spindleFolder = 'T:\projects\eeg_2021\analysis_included_excluded\spindles\v17_5s\19_Jan_2021\16_35_14'; %fullfile(settings.parentAnalysisFolder, 'spindles');
if ~exist(spindleFolder, 'dir')
    error('This script requires the spindles to have been made.');
end

load(fullfile(spindleFolder, 'workspace.mat'));

beta = 3; % 1 second intervals

outputFolder = fullfile(settings.parentAnalysisFolder, sprintf('spindle_transitions_%ds', beta));
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end


eegFs = 400;
waveletFs = eegFs / settings.waveletsDownsampleFactor;

spindleTransitionsAverage = cell(1, numMice);

for iMouse = 1:numMice
    mouse = mouseTable(iMouse,:);
    
    fprintf('Processing %d of %d (%s)\n', iMouse, numMice, mouse.codename{1});

    [spindleTransitionTimes, spindleTransitionsAverage{iMouse}] = ml_sleeptudy_mouse_get_spindle_transition_average(settings, mouse, spindleFolder, beta);
    
end

fprintf('Done!\n\n');

% figure
% %inds = 1:5*waveletFs:length(spindleTransitionsAverage);
% %plot(spindleTransitionTimes(inds), spindleTransitionsAverage(inds));
% plot(spindleTransitionTimes(1:end-1), spindleTransitionsAverage)

%%

save(fullfile(outputFolder, 'workspace.mat'));

