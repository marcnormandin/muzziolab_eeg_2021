%close all
clear all
clc

%close all
clear all
clc

datasetFolder = 'T:\EPHYS_SLEEP_STUDY\datasets\dataset_7';
settings = load_settings();
%settings.spectrogram_window_size_s = 8;
settings.outputFolder = fullfile(settings.parentAnalysisFolder, 'sigma_transitions_pwelch');

load(fullfile(settings.outputFolder, 'workspace_sigma_transitions_ds7_v4.mat'));

% Filter the bad mice
[badi] = find_badmice_indices_in_dataset(dataset);
if ~isempty(badi)
    dataset(badi) = [];
    nremToRemMeans(badi,:) = [];
    wakeToNremMeans(badi,:) = [];
    remToNremMeans(badi,:) = [];
    numMice = length(dataset);
end

% eliminate 51 which is a huge outlier
dataset(51) = [];
wakeToNremMeans(51,:) = [];

numMice = length(dataset);

settings.FNTSZ = 20;
FNTSZ = settings.FNTSZ;

sigmaMatch_times = -settings.sigmaMatch_t_before_and_after:settings.sigmaMatch_t_before_and_after;

%miceAges = [dataset.age];
%youngi = find(miceAges == 'Y');
%oldi = find(miceAges == 'O');
groups = unique({dataset.age});
numGroups = length(groups);
%groups = struct('name', {}, 'indices', []);

wakeToNremGroupMean = zeros(numGroups, length(sigmaMatch_times));
wakeToNremGroupStd = zeros(numGroups, length(sigmaMatch_times));


for iGroup = 1:numGroups
    gindices = [];
    for iMouse = 1:numMice
        if strcmp(dataset(iMouse).age, groups{iGroup})
            gindices(end+1) = iMouse;
        end
    end

    [wakeToNremGroupMean, wakeToNremGroupStd, sigmaMatch_times] = compute_sigma_power_across_state_transitions(settings, wakeToNremMeans(gindices,:), groups{iGroup}, 1);
    %title(sprintf('Wake-NREM for group: %s', groups{iGroup}))
    grid on
    
    
%     [nremToRemGroupMean(iGroup,:), nremToRemGroupStd(iGroup,:), remToNremGroupMean(iGroup,:), remToNremGroupStd(iGroup,:)] = ...
%     compute_sigma_power_across_transitions(settings, nremToRemMeans(gindices,:), remToNremMeans(gindices,:), 1);
end

%
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

function [stateToStateGroupMean, stateToStateGroupStd, sigmaMatch_times] = compute_sigma_power_across_state_transitions(settings, stateToStateMeans, groupName, doPlot)

    sigmaMatch_times = -settings.sigmaMatch_t_before_and_after:settings.sigmaMatch_t_before_and_after+1;

    stateaToStateMeans_cleaned = stateToStateMeans * 100;
    stateaToStateMeans_cleaned(all(stateaToStateMeans_cleaned == 0, 2), :) = [];
    stateToStateGroupMean = mean(stateaToStateMeans_cleaned, 1);
    stateToStateGroupStd = std(stateaToStateMeans_cleaned, 1)./ sqrt(size(stateaToStateMeans_cleaned,1));

    if doPlot == 1
        h = figure;

        subplot(1,1,1)
        %plot(sigmaMatch_times, nremToRemMeans_cleaned, 'k-')
        hold on
        %x2 = [sigmaMatch_times, fliplr(sigmaMatch_times)];
        %inBetween = [stateToStateGroupMean-stateToStateGroupStd, fliplr(stateToStateGroupMean+stateToStateGroupStd)];
        %fill(x2, inBetween, 'k');
        %plot(sigmaMatch_times, stateaToStateMeans_cleaned, 'k-', 'linewidth', 1)
        %errorbar(sigmaMatch_times(1:4:end), stateToStateGroupMean(1:4:end), stateToStateGroupStd(1:4:end), 'r-');
        errorbar(sigmaMatch_times, stateToStateGroupMean, stateToStateGroupStd, 'k.', 'linewidth', 2);

        plot(sigmaMatch_times, stateToStateGroupMean, 'r-', 'linewidth', 4)
        hold on


        axis tight
        %ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        %xlabel('Time relative to transition [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        title(sprintf('Wake to NREM: %s',groupName), 'fontweight', 'bold', 'fontsize', settings.FNTSZ, 'interpreter', 'none')
        grid on
        
        FNTSZ = 20;

        a = axis;
        axis([-28, 28, 38, 62])
        
        a = get(gca,'XTickLabel');  
        set(gca,'XTickLabel',a,'fontsize',FNTSZ,'FontWeight','bold')
        set(gca,'XTickLabelMode','auto')
        grid on

        a = get(gca,'XTickLabel');
        set(gca, 'YTick', 38:6:62);
        set(gca, 'XTick', -28:14:28);
        set(gca,'XTickLabel',a,'fontsize',FNTSZ,'FontWeight','bold')
        set(gca,'XTickLabelMode','auto')
        grid on
        
        set(gcf,'color','w');
        
        fnPrefix = sprintf('sigma_transition_wake_to_nrem_%s', groupName );
        saveas(h, sprintf('%s.png', fnPrefix), 'png');
        %saveas(h, sprintf('%s.pdf', fnPrefix), 'pdf');
        savefig(h, sprintf('%s.fig', fnPrefix));
        print(h, '-dpdf', sprintf('%s.pdf', fnPrefix), '-fillpage');
    end % if doPlot
end % function
