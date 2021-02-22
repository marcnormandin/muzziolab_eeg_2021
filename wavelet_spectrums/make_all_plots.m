close all
clear all
clc

% Run this after the main script has made the workspace

% Use the same settings as were used to create the workspace

settings = ml_sleepstudy_settings_load();
% mouseTable = ml_sleepstudy_mousetable_load(settings)
% numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'wavelet_state_spectrums');
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end

if ~isfile(fullfile(outputFolder, 'workspace.mat'))
    error('workspace.mat must be created first.');
end
load( fullfile(outputFolder, 'workspace.mat') );

% Rename so we don't clober it
miceTable = mouseTable;
miceSpectrum = meanSpectrum;

% Rescale
for iMouse = 1:size(mouseTable,1)
    for iState = 1:3
        miceSpectrum{iMouse, iState} = miceSpectrum{iMouse, iState}.^2; 
    end
end

% Normalize by state
miceSpectrumNormalizedByState = ml_wavelet_state_spectrums_normalize_by_state(miceSpectrum);
miceSpectrumNormalizedByTotal = ml_wavelet_state_spectrums_normalize_by_total(miceSpectrum);

%%
plot_all_mice_spectrums_overlayed(settings, freqs, miceTable, miceSpectrum, miceSpectrumNormalizedByTotal, miceSpectrumNormalizedByState, outputFolder )

%%
plot_groups_by_state(settings, freqs, miceTable, miceSpectrumNormalizedByTotal, outputFolder)

%% Recovery. Select a subset by the period 'recovery' because Isabel wants
% it separate, and then make the figure
plot_group_average_spectrums(settings, miceTable, freqs, miceSpectrumNormalizedByTotal, 'R', outputFolder)
plot_group_average_spectrums(settings, miceTable, freqs, miceSpectrumNormalizedByTotal, 'P', outputFolder)

%% Plot each mouses state spectrums
plot_all_mice_spectrums_separate(miceTable, freqs, miceSpectrumNormalizedByTotal, outputFolder);


function plot_all_mice_spectrums_separate(mouseTable, freqs, miceSpectrum, outputFolder)
    hMain = figure('position', get(0, 'screensize'));
    for iMouse = 1:size(mouseTable,1)

        mouse = mouseTable(iMouse,:);

        fprintf('Processing %d of %d (%s)\n', iMouse, size(mouseTable,1), mouse.codename{1});

        clf(hMain, 'reset')  
        set(gcf, 'name', mouse.codename{1});
        plot(freqs, miceSpectrum{iMouse, 1}, 'r-', 'linewidth', 2)
        hold on
        plot(freqs, miceSpectrum{iMouse, 2}, 'g-', 'linewidth', 2)
        plot(freqs, miceSpectrum{iMouse, 3}, 'b-', 'linewidth', 2)
        legend({'Wake', 'NREM', 'REM'})
        ylabel('Average wavelet value', 'fontweight', 'bold')
        xlabel('Frequency, f [Hz]', 'fontweight', 'bold')
        grid on
        outputFilename = fullfile(outputFolder, sprintf('%s.pdf', mouse.codename{1}));
        saveas(hMain, outputFilename);
        outputFilename = fullfile(outputFolder, sprintf('%s.svg', mouse.codename{1}));
        saveas(hMain, outputFilename);
        outputFilename = fullfile(outputFolder, sprintf('%s.png', mouse.codename{1}));
        saveas(hMain, outputFilename);
    end

end % function

function plot_group_average_spectrums(settings, mouseTable, freqs, miceSpectrum, period, outputFolder)
    [subTable, subSpectrums] = helper_get_subset_by_period(mouseTable, miceSpectrum, period);
    [groupSpectrums, groups] = compute_group_spectrums_normalized(subTable, subSpectrums);
    hMain = figure('position', get(0, 'screensize'));
    ax = [];
    for iGroup = 1:length(groups)
        for iState = 2:3
            ax(iState+1) = subplot(1,2,iState-1);

            plot(freqs, groupSpectrums{iGroup, iState}, 'linewidth', 4);
            hold on
            title(settings.scoreToTextMap(int2str(iState)));
            legend(groups)
            axis([0, 30, 0, 0.03])
        end
    end

    saveas(hMain, fullfile(outputFolder, sprintf('group_state_spectrums_%s.png', period)));
    saveas(hMain, fullfile(outputFolder, sprintf('group_state_spectrums_%s.svg', period)));
end % function


%% Compute the average spectrums per subtype/group
function [groupSpectrums, groups] = compute_group_spectrums_normalized(miceTable, miceSpectrum)
    groups = unique(miceTable.subtype);
    numGroups = length(groups);
    numStates = 3;
    groupSpectrums = cell(numGroups, numStates);
    for iGroup = 1:numGroups
        group = groups{iGroup};
        [subTable, subSpectrums] = helper_get_subset_by_subtype(miceTable, miceSpectrum, group);
        numMice = size(subTable,1);

        groupTotal = 0;
        for iState = 1:3
            s = zeros(size(subSpectrums{1,1}));
            for iMouse = 1:numMice
                s = s + subSpectrums{iMouse, iState};
            end % iMouse
            s = s ./ numMice;

            groupTotal = groupTotal + sum(s); % So we can normalize after

            groupSpectrums{iGroup, iState} = s;
        end % iState

        for iState = 1:3
            groupSpectrums{iGroup, iState} = groupSpectrums{iGroup, iState}; % ./ groupTotal;
        end

    end
end % function


%%
function [subTable, subSpectrums] = helper_get_subset_by_subtype(mouseTable, miceSpectrum, subtype)
    miceIds = find(ismember(mouseTable.subtype, subtype));
    numMice = length(miceIds);
    if isempty(miceIds)
        warning('The subtype (%s) is not present in the table.')
        return
    end

    
    subTable = mouseTable(miceIds,:);
    subSpectrums = cell(size(subTable,1), 3);

    for iMouse = 1:numMice
        mid = miceIds(iMouse);
        for iState = 1:3
            subSpectrums{iMouse, iState} = miceSpectrum{mid, iState};
        end
    end
end % function

%%
function [subTable, subSpectrums] = helper_get_subset_by_period(mouseTable, miceSpectrum, periodName)
    miceIds = find(ismember(mouseTable.period, periodName));
    numMice = length(miceIds);

    if isempty(miceIds)
        warning('The period (%s) is not present in the table. Must be R or P')
        return
    end

    subTable = mouseTable(miceIds,:);
    subSpectrums = cell(size(subTable,1), 3);

    for iMouse = 1:numMice
        mid = miceIds(iMouse);
        for iState = 1:3
            subSpectrums{iMouse, iState} = miceSpectrum{mid, iState};
        end
    end
end % function

%% To show the different versions of the spectrums based on normalization, plot them all.
function plot_all_mice_spectrums_overlayed(settings, freqs, mouseTable, miceSpectrum, miceSpectrumNormalizedByTotal, miceSpectrumNormalizedByState, outputFolder )

    hMain = figure('position', get(0, 'screensize'), 'name', 'Normalizations');
    for iMouse = 1:size(mouseTable,1)
        for iState = 1:3
            subplot(3,3,iState)
            plot(freqs, miceSpectrum{iMouse, iState});
            hold on
            ylabel('Mean')
            title(sprintf('%s', settings.scoreToTextMap(int2str(iState))))
        end

        for iState = 1:3

            subplot(3,3,iState+3)
            plot(freqs, miceSpectrumNormalizedByTotal{iMouse, iState});
            hold on
            ylabel(sprintf('Normalized\nby Total'))
            title(sprintf('%s', settings.scoreToTextMap(int2str(iState))))
        end

        for iState = 1:3

            subplot(3,3,iState+6)
            plot(freqs, miceSpectrumNormalizedByState{iMouse, iState});
            hold on
            ylabel(sprintf('Normalized\nby State'))
            title(sprintf('%s', settings.scoreToTextMap(int2str(iState))))
        end
    end % iMouse
    grid on

    outputFilename = fullfile(outputFolder, 'diagnostics_all_mice_normalizations.png');
    saveas(hMain, outputFilename);
    outputFilename = fullfile(outputFolder, 'diagnostics_all_mice_normalizations.svg');
    saveas(hMain, outputFilename);
end % function



%%
function plot_groups_by_state(settings, freqs, miceTable, miceSpectrums, outputFolder)
    groups = unique(miceTable.subtype);

    hMain = figure();
    for iGroup = 1:length(groups)
        groupName = groups{iGroup};
        for iState = 1:3
            clf(hMain, 'reset');
            % Compute the mean spectrum
            miceIds = find(ismember(miceTable.subtype, groupName));
            groupSpectrum = zeros(size(miceSpectrums{1,1}));
            for iMouse = 1:length(miceIds)
                groupSpectrum = groupSpectrum + miceSpectrums{miceIds(iMouse), iState};
            end
            groupSpectrum = groupSpectrum ./ length(miceIds);

            for iMouse = 1:length(miceIds)
                plot(freqs, miceSpectrums{miceIds(iMouse), iState}, 'k-');
                hold on
            end
            plot(freqs, groupSpectrum, 'r-', 'linewidth', 2)
            
            % 2020-02-03: Isabel wants a fixed y scale for REM and another for NREM
            if strcmpi(settings.scoreToTextMap(int2str(iState)), 'REM')
                axis([0 30, 0, 0.035]);
            elseif strcmpi(settings.scoreToTextMap(int2str(iState)), 'NREM')
                axis([0, 30, 0, 0.06]);
            end
            
            title(sprintf('%s - %s', groupName, settings.scoreToTextMap(int2str(iState))))
            saveas(hMain, fullfile(outputFolder, sprintf('group_%s_%s.png', groupName, settings.scoreToTextMap(int2str(iState)))));
            saveas(hMain, fullfile(outputFolder, sprintf('group_%s_%s.svg', groupName, settings.scoreToTextMap(int2str(iState)))));
        end
    end
end % function


%% Make the group spectrums by all states shown
% function plot_groups_and_states(settings, freqs, mouseTable, groupMeanSpectrums, filePrefix, outputFolder)
%     groups = unique(mouseTable.subtype);
%     numGroups = length(groups);
%     numStates = 3;
% 
%     hMain = figure('position', get(0, 'screensize'));
%     set(gcf, 'position', get(0, 'screensize'))
%     for iState = 1:numStates
%        ax(iState) = subplot(1,3,iState);
%        ll = {};
%        for iGroup = 1:numGroups
%           ll{iGroup} = groups{iGroup};
% 
%           groupTotal = 0; % Total power across all states will be constant
%           for iStatee = 1:3
%             groupTotal = groupTotal + sum(meanGroupSpectrum{iGroup, iStatee}.^2, 'all');
%           end
% 
%           plot(freqs, meanGroupSpectrum{iGroup, iState}.^2./groupTotal, 'linewidth', 2)
%           hold on
%        end
%        if iState == 2
%         legend(ll,'fontsize', 8)
%        end
%        grid on
%        title(settings.scoreToTextMap(int2str(iState)))
%        axis([0, 30, 0, 0.025])
%     end
%     linkaxes(ax, 'xy')
%     saveas(hMain, fullfile(outputFolder, sprintf('group_state_spectrums_%s.png', filePrefix)));
%     saveas(hMain, fullfile(outputFolder, sprintf('group_state_spectrums_%s.svg', filePrefix)));
% end % function

