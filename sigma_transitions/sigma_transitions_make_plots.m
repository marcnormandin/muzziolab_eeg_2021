close all
clear all
clc

settings = ml_sleepstudy_settings_load();

inputFolder = fullfile(settings.parentAnalysisFolder, 'sigma_transitions');
if ~exist(inputFolder, 'dir')
    error('We need the workspace for the sigma transitions.');
end

load(fullfile(inputFolder, 'workspace.mat'));



%% By specific group 
subtypes = unique(mouseTable.subtype);
numSubtypes = length(subtypes);
for iSubtype = 1:numSubtypes
   st = subtypes{iSubtype};
   imembers = find(ismember(mouseTable.subtype, st));
   
   sigmaTransitions = sigmaTransitionsAverage(imembers,:)*100; % convert to percent
   groupMean = mean(sigmaTransitions, 1);
   groupError = std(sigmaTransitions, 0, 1) ./ sqrt(size(sigmaTransitions,1));
   
%    errorLow = groupMean - groupError;
%    errorHigh = groupMean + groupError;
   
   errorLow = movmean(groupMean - groupError, waveletFs);
   errorHigh = movmean(groupMean + groupError, waveletFs);
   
   groupMean = movmean(groupMean, waveletFs);
   
   p = 5*waveletFs;
   q = p;
   A = 150;
   
   h = figure('name', st);
   area([0, 60], [A, A])
   %plot(sigmaTransitionTimes, sigmaTransitions, 'k-');
   hold on
   plot(sigmaTransitionTimes(1:q:end), groupMean(1:q:end), 'r-', 'linewidth', 2);
   

   plot(sigmaTransitionTimes(1:p:end), errorLow(1:p:end), 'k-');
   plot(sigmaTransitionTimes(1:p:end), errorHigh(1:p:end), 'k-');
   
   xlabel('Time [sec]')
   ylabel(sprintf('Sigma power\n(%% of total)'))
   title(sprintf('NREM-REM Transition\nBefore        After'))
   a = axis;
   axis([-60, 60, 0, A]);
   set(gca, 'xtick', [-60, -30, 0, 30, 60])
   
   fnPrefix = sprintf('sigmatransitionpower_%s', st);
   saveas(h, fullfile(inputFolder, sprintf('%s.png', fnPrefix)));
   saveas(h, fullfile(inputFolder, sprintf('%s.svg', fnPrefix)));
end

%% By age 
ages = unique(mouseTable.age);
numAges = length(ages);
for iAge = 1:numAges
   st = ages{iAge};
   imembers = find(ismember(mouseTable.age, st));
   
   sigmaTransitions = sigmaTransitionsAverage(imembers,:)*100; % convert to percent
   groupMean = mean(sigmaTransitions, 1);
   groupError = std(sigmaTransitions, 0, 1) ./ sqrt(size(sigmaTransitions,1));
   
   errorLow = movmean(groupMean - groupError, waveletFs);
   errorHigh = movmean(groupMean + groupError, waveletFs);
   
   groupMean = movmean(groupMean, waveletFs);
   
   p = 5*waveletFs;
   q = p;
   A = 150;
   
   h = figure('name', st);
   area([0, 60], [A, A])
   %plot(sigmaTransitionTimes, sigmaTransitions, 'k-');
   hold on
   plot(sigmaTransitionTimes(1:q:end), groupMean(1:q:end), 'r-', 'linewidth', 2);
   

   plot(sigmaTransitionTimes(1:p:end), errorLow(1:p:end), 'k-');
   plot(sigmaTransitionTimes(1:p:end), errorHigh(1:p:end), 'k-');
   
   xlabel('Time [sec]')
   ylabel(sprintf('Sigma power\n(%% of total)'))
   title(sprintf('NREM-REM Transition\nBefore        After'))
   a = axis;
   axis([-60, 60, 0, A]);
   set(gca, 'xtick', [-60, -30, 0, 30, 60])
   
   fnPrefix = sprintf('sigmatransitionpower_%s', st);
   saveas(h, fullfile(inputFolder, sprintf('%s.png', fnPrefix)));
   saveas(h, fullfile(inputFolder, sprintf('%s.svg', fnPrefix)));
end

