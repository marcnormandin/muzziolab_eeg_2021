close all
clear all
clc

settings = ml_sleepstudy_settings_load();

inputFolder = fullfile(settings.parentAnalysisFolder, 'spindle_transitions_3s');
if ~exist(inputFolder, 'dir')
    error('We need the workspace for the sigma transitions.');
end

load(fullfile(inputFolder, 'workspace.mat'));


%% Saved as a cell, but better as a matrix
sz = length(spindleTransitionsAverage{1});

x = zeros(numMice, sz);
for iMouse = 1:numMice
   x(iMouse, :) = spindleTransitionsAverage{iMouse}; 
end
spindleTransitionsAverage = x;

%% By specific group 
subtypes = unique(mouseTable.subtype);
numSubtypes = length(subtypes);
for iSubtype = 1:numSubtypes
   st = subtypes{iSubtype};
   imembers = find(ismember(mouseTable.subtype, st));
   
   spindleTransitions = spindleTransitionsAverage(imembers,:); % convert to percent
   
   groupMean = mean(spindleTransitions, 1);
   groupError = std(spindleTransitions, 0, 1) ./ sqrt(size(spindleTransitions,1));
   
   errorLow = groupMean - groupError;
   errorHigh = groupMean + groupError;
   
   %errorLow = movmean(groupMean - groupError, waveletFs);
   %errorHigh = movmean(groupMean + groupError, waveletFs);
   
   %groupMean = movmean(groupMean, waveletFs);
   
   p = 1; %5*waveletFs;
   q = 1;
   A = 3.5;
   
   h = figure('name', st);
   area([0, 60], [A, A])
   %plot(sigmaTransitionTimes, sigmaTransitions, 'k-');
   hold on
   plot(spindleTransitionTimes(1:q:end-1), groupMean(1:q:end), 'r-', 'linewidth', 2);
   

   plot(spindleTransitionTimes(1:p:end-1), errorLow(1:p:end), 'k-');
   plot(spindleTransitionTimes(1:p:end-1), errorHigh(1:p:end), 'k-');
   
   xlabel('Time [sec]')
   ylabel(sprintf('Spindle Count'))
   title(sprintf('NREM-REM Transition\nBefore        After'))
   a = axis;
   axis([-60, 60, 0, A]);
   set(gca, 'xtick', [-60, -30, 0, 30, 60])
   
   fnPrefix = sprintf('spindletransitioncounts_%s', st);
   saveas(h, fullfile(inputFolder, sprintf('%s.png', fnPrefix)));
   saveas(h, fullfile(inputFolder, sprintf('%s.svg', fnPrefix)));
end

%% By age 
ages = unique(mouseTable.age);
numAges = length(ages);
for iAge = 1:numAges
   st = ages{iAge};
   imembers = find(ismember(mouseTable.age, st));
   
   spindleTransitions = spindleTransitionsAverage(imembers,:); % convert to percent
   groupMean = mean(spindleTransitions, 1);
   groupError = std(spindleTransitions, 0, 1) ./ sqrt(size(spindleTransitions,1));
   
   errorLow = groupMean - groupError;
   errorHigh = groupMean + groupError;
   
%    errorLow = movmean(groupMean - groupError, waveletFs);
%    errorHigh = movmean(groupMean + groupError, waveletFs);
   
   %groupMean = movmean(groupMean, waveletFs);
   
   p = 1; %5*waveletFs;
   q = p;
   A = 3.5;
   
   h = figure('name', st);
   area([0, 60], [A, A])
   %plot(sigmaTransitionTimes, sigmaTransitions, 'k-');
   hold on
   plot(spindleTransitionTimes(1:q:end-1), groupMean(1:q:end), 'r-', 'linewidth', 2);
   

   plot(spindleTransitionTimes(1:p:end-1), errorLow(1:p:end), 'k-');
   plot(spindleTransitionTimes(1:p:end-1), errorHigh(1:p:end), 'k-');
   
   xlabel('Time [sec]')
   ylabel(sprintf('Spindle Counts'))
   title(sprintf('NREM-REM Transition\nBefore        After'))
   a = axis;
   axis([-60, 60, 0, A]);
   set(gca, 'xtick', [-60, -30, 0, 30, 60])
   
   fnPrefix = sprintf('spindletransitioncounts_%s', st);
   saveas(h, fullfile(inputFolder, sprintf('%s.png', fnPrefix)));
   saveas(h, fullfile(inputFolder, sprintf('%s.svg', fnPrefix)));
end



%% Make an excel of the counts before and after that Isabel wanted\
ns = size(spindleTransitionsAverage,2)/2;
sumBefore = sum( spindleTransitionsAverage(:,1:ns), 2 );
sumAfter = sum( spindleTransitionsAverage(:, ns:end), 2);

ms = ns/4;
sumM30M15 = sum( spindleTransitionsAverage(:, (2*ms):(3*ms)), 2 );
sumM15Zero = sum( spindleTransitionsAverage(:, (3*ms):(4*ms)), 2 );


T = mouseTable(:,1:7);
T.sum_before = sumBefore;
T.sum_after = sumAfter;
T.sum_m30_to_m15 = sumM30M15;
T.sum_m15_to_zero = sumM15Zero;


writetable(T, fullfile(inputFolder, 'spindle_transition_counts.xlsx'))
