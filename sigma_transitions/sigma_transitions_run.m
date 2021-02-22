close all
clear all
clc

settings = ml_sleepstudy_settings_load();
mouseTable = ml_sleepstudy_mousetable_load(settings)
numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'sigma_transitions');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% This is just so that I can run this in a parfar. I need to know the array
% sizes outside the loop
% For us the eeg fs is always 400
eegFs = 400;
waveletFs = eegFs / settings.waveletsDownsampleFactor;
nSamples = settings.sigmaMatch_t_before_and_after * waveletFs;
sigmaTransitionTimes = (-nSamples:nSamples) / waveletFs;
numTimeSamples = length(sigmaTransitionTimes);

sigmaTransitionsAverage = zeros(numMice, numTimeSamples);
numSigmaTransitions = zeros(numMice, 1);

for iMouse = 1:numMice
    mouse = mouseTable(iMouse,:);
    fprintf('Processing %d of %d: %s\n', iMouse, numMice, mouse.codename{1});

    [~, sigmaTransitionsAverage(iMouse,:), numSigmaTransitions(iMouse)] =  ml_ephys_mouse_sigma_nrem_to_rem_timeseries(settings, mouse);
end % iMouse

% Save the entire workspace
save(fullfile(outputFolder, 'workspace.mat'));
