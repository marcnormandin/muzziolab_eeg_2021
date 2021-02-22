%close all
clear all
clc

close all
clear all
clc

datasetFolder = 'T:\EPHYS_SLEEP_STUDY\datasets\dataset_7';
settings = load_settings();
%settings.spectrogram_window_size_s = 8;
settings.outputFolder = fullfile(settings.parentAnalysisFolder, 'sigma_transitions');

%load(fullfile(settings.outputFolder, 'workspace_sigma_transitions_ds7_4s.mat'));
load(fullfile('T:\EPHYS_SLEEP_STUDY\analysis\sigma_transitions', 'workspace_sigma_transitions_ds7_v4.mat'));

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
wakeToNremGroupMean = zeros(numGroups, length(sigmaMatch_times));
wakeToNremGroupStd = zeros(numGroups, length(sigmaMatch_times));

for iGroup = 1:numGroups
    gindices = [];
    for iMouse = 1:numMice
        if strcmp(dataset(iMouse).subtype, groups{iGroup})
            gindices(end+1) = iMouse;
        end
    end

    [wakeToNremGroupMean, wakeToNremGroupStd, sigmaMatch_times] = compute_sigma_power_across_state_transitions(settings, nremToRemMeans(gindices,:), 1);
    title(sprintf('group: %s', groups{iGroup}))
    
%     [nremToRemGroupMean(iGroup,:), nremToRemGroupStd(iGroup,:), remToNremGroupMean(iGroup,:), remToNremGroupStd(iGroup,:)] = ...
%     compute_sigma_power_across_transitions(settings, nremToRemMeans(gindices,:), remToNremMeans(gindices,:), 1);
end

%%
% post learning
% pli = find(ismember(groups, [{'OCP'}, {'YCP'}])==1);
% ri = find(~ismember(groups, [{'OCP'}, {'YCP'}])==1);
% 
% D = nremToRemGroupMean;
% 
% 
% h = figure;
%     subplot(1,2,1)
%     plot(sigmaMatch_times, D(pli,:), 'linewidth', 4)
%     title('Post-learning')
%     legend(groups{pli})
%     axis tight
%     ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%     xlabel('Time [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%     title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%     
%     subplot(1,2,2)
%     plot(sigmaMatch_times, D(ri,:), 'linewidth', 4)
%     title('Recovery')
%     legend(groups{ri})
%     axis tight
%     ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%     xlabel('Time [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%     title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%     
% grid on
% 
% fnPrefix = sprintf('sigma_transitions_all_groups_nremtorem');
% saveas(h, sprintf('%s.png', fnPrefix), 'png');
% saveas(h, sprintf('%s.pdf', fnPrefix), 'pdf');
% savefig(h, sprintf('%s.fig', fnPrefix));

function [stateToStateGroupMean, stateToStateGroupStd, sigmaMatch_times] = compute_sigma_power_across_state_transitions(settings, stateToStateMeans, doPlot)

    sigmaMatch_times = -settings.sigmaMatch_t_before_and_after:settings.sigmaMatch_t_before_and_after+1;

    stateaToStateMeans_cleaned = stateToStateMeans * 100;
    stateaToStateMeans_cleaned(all(stateaToStateMeans_cleaned == 0, 2), :) = [];
    stateToStateGroupMean = mean(stateaToStateMeans_cleaned, 1);
    stateToStateGroupStd = std(stateaToStateMeans_cleaned, 1) ./ sqrt(size(stateaToStateMeans_cleaned,1));

    if doPlot == 1
        figure

        subplot(1,1,1)
        %plot(sigmaMatch_times, nremToRemMeans_cleaned, 'k-')
        hold on
        x2 = [sigmaMatch_times, fliplr(sigmaMatch_times)];
        inBetween = [stateToStateGroupMean-stateToStateGroupStd, fliplr(stateToStateGroupMean+stateToStateGroupStd)];
        fill(x2, inBetween, 'k');

        plot(sigmaMatch_times, stateToStateGroupMean, 'r-', 'linewidth', 4)
        %errorbar(sigmaMatch_times(1:4:end), nremToRemGroupMean(1:4:end), nremToRemGroupStd(1:4:end), 'k-');

        axis tight
        ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        xlabel('Time relative to transition [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        %title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
    end % if doPlot
end % function
