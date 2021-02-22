close all
clear all
clc

%load('workspace_sigma_transitions_ds7_8s.mat');
load(fullfile('T:\EPHYS_SLEEP_STUDY\analysis\sigma_transitions_pwelch', 'workspace_sigma_transitions_ds7_v4.mat'));

% Filter the bad mice
[badi] = find_badmice_indices_in_dataset(dataset);
if ~isempty(badi)
    dataset(badi) = [];
    nremToRemMeans(badi,:) = [];
    remToNremMeans(badi,:) = [];
    numMice = length(dataset);
end


settings.FNTSZ = 20;

sigmaMatch_times = -(settings.sigmaMatch_t_before_and_after):(settings.sigmaMatch_t_before_and_after+1);

% miceAges = [dataset.age];
% youngi = find(miceAges == 'Y');
% oldi = find(miceAges == 'O');
groups = unique({dataset.age});
numGroups = length(groups);

nremToRemGroupMean = zeros(numGroups, length(sigmaMatch_times));
nremToRemGroupStd = zeros(numGroups, length(sigmaMatch_times));
remToNremGroupMean = zeros(numGroups, length(sigmaMatch_times));
remToNremGroupStd = zeros(numGroups, length(sigmaMatch_times));

for iGroup = 1:numGroups
    gindices = [];
    for iMouse = 1:numMice
        if strcmp(dataset(iMouse).age, groups{iGroup})
            gindices(end+1) = iMouse;
        end
    end
    fprintf('Processing group: %s\n', groups{iGroup});
    
    [nremToRemGroupMean(iGroup,:), nremToRemGroupStd(iGroup,:), remToNremGroupMean(iGroup,:), remToNremGroupStd(iGroup,:), h] = ...
        compute_sigma_power_across_transitions(settings, nremToRemMeans(gindices,:), remToNremMeans(gindices,:), 1);
    title(sprintf('NREM TO REM: %s', groups{iGroup}))
    saveas(h, sprintf('sigma_transition_nrem_to_rem_%s.png', groups{iGroup}), 'png');
    saveas(h, sprintf('sigma_transition_nrem_to_rem_%s.pdf', groups{iGroup}), 'pdf');
    savefig(h, sprintf('sigma_transition_nrem_to_rem_%s.fig', groups{iGroup}));
end

%sigmaMatch_times = sigmaMatch_times(61-15:61+15);
%nremToRemGroupMean(:
iuse = sigmaMatch_times > -60 & sigmaMatch_times < 60;

h = figure;
subplot(1,1,1)
plot(sigmaMatch_times(iuse), nremToRemGroupMean(:,iuse))
legend(groups)
axis tight
ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
xlabel('Time, t [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
grid on

% subplot(1,2,2)
% plot(sigmaMatch_times, remToNremGroupMean)
% legend(groups)
% axis tight
% ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% xlabel('Time, t [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% title('REM to NREM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
% grid on

saveas(h, 'sigma_transition_nrem_to_rem_combined.png', 'png');
saveas(h, 'sigma_transition_nrem_to_rem_combined.pdf', 'pdf');
savefig(h,'sigma_transition_nrem_to_rem_combined.fig');

function [nremToRemGroupMean, nremToRemGroupStd, remToNremGroupMean, remToNremGroupStd, h] = ...
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

    %if doPlot == 1
        h = figure;

        subplot(1,1,1)
        %plot(sigmaMatch_times, nremToRemMeans_cleaned, 'k-')
        hold on
        %x2 = [sigmaMatch_times, fliplr(sigmaMatch_times)];
        %inBetween = [nremToRemGroupMean-nremToRemGroupStd, fliplr(nremToRemGroupMean+nremToRemGroupStd)];
        %fill(x2, inBetween, 'k');

        iuse = sigmaMatch_times > -60 & sigmaMatch_times < 60;

        errorbar(sigmaMatch_times(1:1:end), nremToRemGroupMean(1:1:end), nremToRemGroupStd(1:1:end), 'k.', 'linewidth', 2);

        plot(sigmaMatch_times(iuse), nremToRemGroupMean(iuse), 'r-', 'linewidth', 4)
        hold on
        %errorbar(sigmaMatch_times(1:4:end), nremToRemGroupMean(1:4:end), nremToRemGroupStd(1:4:end), 'r.', 'linewidth', 2);

        axis tight
        %ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        %xlabel('Time, t [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        title('NREM to REM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
        grid on
        
        FNTSZ = 20;

        axis([-30, 30, 50, 130])
        
        set(gca, 'YTick', 50:10:130);
        a = get(gca,'XTickLabel');
        set(gca, 'XTick', -30:15:30);
        set(gca,'XTickLabel',a,'fontsize',FNTSZ,'FontWeight','bold')
        set(gca,'XTickLabelMode','auto')
        grid on
        
        set(gcf,'color','w');
        
        
%         subplot(1,2,2)
%         x2 = [sigmaMatch_times, fliplr(sigmaMatch_times)];
%         inBetween = [remToNremGroupMean-remToNremGroupStd, fliplr(remToNremGroupMean+remToNremGroupStd)];
%         fill(x2, inBetween, 'k');
% 
%         %plot(sigmaMatch_times, remToNremMeans_cleaned, 'k-')
%         hold on
%         plot(sigmaMatch_times, remToNremGroupMean, 'r-', 'linewidth', 4)
%         %errorbar(sigmaMatch_times(1:4:end), remToNremGroupMean(1:4:end), remToNremGroupStd(1:4:end), 'k-')
% 
% 
%         axis tight
%         ylabel('Sigma power (% of total)', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%         xlabel('Time, t [s]', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%         title('REM to NREM', 'fontweight', 'bold', 'fontsize', settings.FNTSZ)
%         grid on
    %end % if doPlot
end % function