close all
clear all
clc

%load('workspace_sigma_transitions.mat');
datasetFolder = 'T:\EPHYS_SLEEP_STUDY\datasets\dataset_7';
settings = load_settings();
%settings.spectrogram_window_size_s = 8;
settings.outputFolder = fullfile(settings.parentAnalysisFolder, 'sigma_transitions');

load(fullfile(settings.outputFolder, 'workspace_sigma_transitions_ds7_v4.mat'));


% Filter the bad mice
[badi] = find_badmice_indices_in_dataset(dataset);
if ~isempty(badi)
    dataset(badi) = [];
    nremToRemMeans(badi,:) = [];
    remToNremMeans(badi,:) = [];
    numMice = length(dataset);
end

settings.FNTSZ = 20;

sigmaMatch_times = -settings.sigmaMatch_t_before_and_after:settings.sigmaMatch_t_before_and_after+1;

%miceAges = [dataset.age];
% youngi = find(miceAges == 'Y');
% oldi = find(miceAges == 'O');
groups = unique({dataset.subtype});
numGroups = length(groups);

nremToRemGroupMean = zeros(numGroups, length(sigmaMatch_times));
nremToRemGroupStd = zeros(numGroups, length(sigmaMatch_times));
remToNremGroupMean = zeros(numGroups, length(sigmaMatch_times));
remToNremGroupStd = zeros(numGroups, length(sigmaMatch_times));

for iGroup = 1:numGroups
    gindices = [];
    for iMouse = 1:numMice
        if strcmp(dataset(iMouse).subtype, groups{iGroup})
            gindices(end+1) = iMouse;
        end
    end
    [nremToRemGroupMean(iGroup,:), nremToRemGroupStd(iGroup,:), remToNremGroupMean(iGroup,:), remToNremGroupStd(iGroup,:)] = ...
    compute_sigma_power_across_transitions(settings, nremToRemMeans(gindices,:), remToNremMeans(gindices,:), 0);
end

h = figure;
subplot(1,2,1)
plot(sigmaMatch_times, nremToRemGroupMean)
legend(groups)
axis tight
ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
xlabel('Time [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
grid on

subplot(1,2,2)
plot(sigmaMatch_times, remToNremGroupMean)
legend(groups)
axis tight
ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
xlabel('Time [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
title('REM to NREM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
grid on

fnPrefix = sprintf('sigma_transitions_all_groups');
saveas(h, sprintf('%s.png', fnPrefix), 'png');
saveas(h, sprintf('%s.pdf', fnPrefix), 'pdf');
savefig(h, sprintf('%s.fig', fnPrefix));

function [nremToRemGroupMean, nremToRemGroupStd, remToNremGroupMean, remToNremGroupStd] = ...
    compute_sigma_power_across_transitions(settings, nremToRemMeans, remToNremMeans, doPlot)

    sigmaMatch_times = -settings.sigmaMatch_t_before_and_after:settings.sigmaMatch_t_before_and_after+1;

    nremToRemMeans_cleaned = nremToRemMeans * 100;
    nremToRemMeans_cleaned(all(nremToRemMeans_cleaned == 0, 2), :) = [];
    nremToRemGroupMean = mean(nremToRemMeans_cleaned, 1);
    nremToRemGroupStd = std(nremToRemMeans_cleaned, 1) ./ sqrt(size(nremToRemMeans_cleaned,1));


    remToNremMeans_cleaned = remToNremMeans * 100;
    remToNremMeans_cleaned(all(remToNremMeans_cleaned == 0, 2),:) = [];
    remToNremGroupMean = mean(remToNremMeans_cleaned, 1);
    remToNremGroupStd = std(remToNremMeans_cleaned, 1) ./ sqrt(size(remToNremMeans_cleaned,1));

% figure
% subplot(1,2,1)
% plot(sigmaMatch_times, sum(nremToRemMeans_cleaned, 1))
% subplot(1,2,2)
% plot(sigmaMatch_times, sum(remToNremMeans_cleaned, 1))
% 
% 
% figure
% 
% subplot(1,2,1)
% plot(sigmaMatch_times, nremToRemMeans_cleaned, 'k-')
% hold on
% plot(sigmaMatch_times, nremToRemGroupMean, 'r-', 'linewidth', 4)
% axis tight
% ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% xlabel('Time relative to transition [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% title('NREM to REM')
% 
% subplot(1,2,2)
% plot(sigmaMatch_times, remToNremMeans_cleaned, 'k-')
% hold on
% plot(sigmaMatch_times, remToNremGroupMean, 'r-', 'linewidth', 4)
% axis tight
% ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% xlabel('Time relative to transition [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% title('REM to NREM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)

    if doPlot == 1
        figure

        subplot(1,2,1)
        %plot(sigmaMatch_times, nremToRemMeans_cleaned, 'k-')
        hold on
        x2 = [sigmaMatch_times, fliplr(sigmaMatch_times)];
        inBetween = [nremToRemGroupMean-nremToRemGroupStd, fliplr(nremToRemGroupMean+nremToRemGroupStd)];
        fill(x2, inBetween, 'k');

        plot(sigmaMatch_times, nremToRemGroupMean, 'r-', 'linewidth', 4)
        %errorbar(sigmaMatch_times(1:4:end), nremToRemGroupMean(1:4:end), nremToRemGroupStd(1:4:end), 'k-');

        axis tight
        ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        xlabel('Time relative to transition [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)

        subplot(1,2,2)
        x2 = [sigmaMatch_times, fliplr(sigmaMatch_times)];
        inBetween = [remToNremGroupMean-remToNremGroupStd, fliplr(remToNremGroupMean+remToNremGroupStd)];
        fill(x2, inBetween, 'k');

        %plot(sigmaMatch_times, remToNremMeans_cleaned, 'k-')
        hold on
        plot(sigmaMatch_times, remToNremGroupMean, 'r-', 'linewidth', 4)
        %errorbar(sigmaMatch_times(1:4:end), remToNremGroupMean(1:4:end), remToNremGroupStd(1:4:end), 'k-')


        axis tight
        ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        xlabel('Time relative to transition [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        title('REM to NREM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
    end % if doPlot
end % function