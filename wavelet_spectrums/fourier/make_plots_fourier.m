close all
clear all
clc

% Run this after the main script has made the workspace

% Use the same settings as were used to create the workspace

settings = ml_sleepstudy_settings_load();
% mouseTable = ml_sleepstudy_mousetable_load(settings)
% numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'fourier_state_spectrums');
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end

if ~isfile(fullfile(outputFolder, 'workspace.mat'))
    error('workspace.mat must be created first.');
end
load( fullfile(outputFolder, 'workspace.mat') );

%% 
%close all
clc

%hMain = figure();
hMain = figure();
groups = unique(mouseTable.subtype);
for iGroup = 1:length(groups)
    groupName = groups{iGroup};
    for iState = 1:3
        [gfreqs{iGroup,iState}, meanGroupSpectrum{iGroup, iState}] = ml_wavelet_state_spectrums_plot_group(hMain, mouseTable, meanSpectrum, averageTotalPower, freqs, groupName, iState)
        title(sprintf('%s - %s', groupName, settings.scoreToTextMap(int2str(iState))))
        saveas(hMain, fullfile(outputFolder, sprintf('group_%s_%s.png', groupName, settings.scoreToTextMap(int2str(iState)))));
    end
end

%%

hMain = figure('position', get(0, 'screensize'));
groupTotal = zeros(length(groups),1);
for iGroup = 1:length(groups)
   for iState = 1:3
      groupTotal(iGroup) = groupTotal(iGroup) + sum(meanGroupSpectrum{iGroup, iState}, 'all');
   end
end

clf(hMain, 'reset')
set(gcf, 'position', get(0, 'screensize'))
for iState = 1:3
   ax(iState) = subplot(1,3,iState)
   ll = {};
   for iGroup = 1:length(groups)
      ll{iGroup} = groups{iGroup};
      plot(gfreqs{iGroup, iState}, meanGroupSpectrum{iGroup, iState}./groupTotal(iGroup), 'linewidth', 2)
      hold on
   end
   if iState == 2
    %legend(ll, 'location', 'southoutside', 'orientation', 'horizontal', 'fontsize', 4)
    legend(ll,'fontsize', 8)
   end
   grid on
   title(settings.scoreToTextMap(int2str(iState)))
   axis([0, 20, 0, 0.03])
end
linkaxes(ax, 'xy')
saveas(hMain, fullfile(outputFolder, 'group_state_spectrums.png'));

%%
  
for iMouse = 1:size(mouseTable,1)
    
    mouse = mouseTable(iMouse,:);
    
    clf(hMain, 'reset')  
    set(gcf, 'name', mouse.codename{1});
    plot(settings.waveletsInterpFreqs, meanSpectrum{iMouse, 1}, 'r-', 'linewidth', 2)
    hold on
    plot(settings.waveletsInterpFreqs, meanSpectrum{iMouse, 2}, 'g-', 'linewidth', 2)
    plot(settings.waveletsInterpFreqs, meanSpectrum{iMouse, 3}, 'b-', 'linewidth', 2)
    legend({'Wake', 'NREM', 'REM'})
    ylabel('Average wavelet value', 'fontweight', 'bold')
    xlabel('Frequency, f [Hz]', 'fontweight', 'bold')
    grid on
    outputFilename = fullfile(outputFolder, sprintf('%s.pdf', mouse.codename{1}));
    saveas(hMain, outputFilename);
    outputFilename = fullfile(outputFolder, sprintf('%s.png', mouse.codename{1}));
    saveas(hMain, outputFilename);
end
