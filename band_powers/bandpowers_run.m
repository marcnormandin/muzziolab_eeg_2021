close all
clear all
clc

% Run this after the main script has made the workspace

% Use the same settings as were used to create the workspace

settings = ml_sleepstudy_settings_load();
% mouseTable = ml_sleepstudy_mousetable_load(settings)
% numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'band_powers');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder)
end

% Load the wavelet results
waveletFolder = fullfile(settings.parentAnalysisFolder, 'wavelet_state_spectrums');
if ~isfile(fullfile(waveletFolder, 'workspace.mat'))
    error('workspace.mat must be created first.');
end
load( fullfile(waveletFolder, 'workspace.mat') );

numMice = size(mouseTable,1);
%%
powerStats = [];

for iMouse = 1:numMice
    mouse = mouseTable(iMouse,:);
    
    % Total spectrums band power (irregardless of state) (all EEGs should have this)
    MT = totalSpectrum{iMouse}.^2;
    MT = MT ./ sum(MT, 'all'); % Normalize so that all mice have the same total power
    for iBand = 1:length(settings.bands)
            band = settings.bands(iBand);
            bandName = band.name;
            idx = find( freqs >= band.f_low & freqs <= band.f_high );
            if ~isempty(idx)
                p = sum(MT(idx), 'all');
            else
                p = 0;
            end
            eval([sprintf('powerStats(iMouse).%s_%s = p;', bandName, 'all')])
    end
    
    scores = mouse.scores{1};
    
    if ~isempty(scores) % Or check the saved wavelet spectrums
        % State dependent (Only scored EEGs will have this)
        
        % Get the average spectrum for each state
        
        mMean = meanSpectrum(iMouse,:); % meanSpectrum is cell array (# mice) x (3 states)
        
        % Compute the total sum across the 3 states and all frequencies
        totalPowerPerState = zeros(1, 3);
        for iState = 1:3
            totalPowerPerState(iState) = sum(mMean{iState}.^2, 'all');
        end
        totalPowerAllStates = sum(totalPowerPerState, 'all');

        check = 0;
        for iState = 1:3
            % This is one normalization
            %perTotal = mMean{iState} ./ totalPowerAllStates*100;
            
            % This normalization makes the total per state 100%
            perTotal = mMean{iState}.^2 ./ totalPowerPerState(iState)*100; 
            
            stateName = settings.scoreToTextMap(int2str(iState));

            for iBand = 1:length(settings.bands)
                band = settings.bands(iBand);
                bandName = band.name;
                
                % Entire band
                idx = find( freqs >= band.f_low & freqs <= band.f_high );
                if ~isempty(idx)
                    p = sum(perTotal(idx), 'all');
                else
                    p = 0;
                end
                check = check + p;
                eval([sprintf('powerStats(iMouse).%s_%s = p;', bandName, stateName)])
                
                % Subbands if they exist
                if ~isempty(band.subbands)
                    numBands = length(band.subbands)-1;
                    if numBands < 1
                        error('Something is not right about the bands for (%s)', bandName);
                    end
                    
                    for iSub = 1:numBands
                        sub_f_low = band.subbands(iSub);
                        sub_f_high = band.subbands(iSub+1);
                        
                        idx = find( freqs >= sub_f_low & freqs <= sub_f_high );
                        if ~isempty(idx)
                            p = sum(perTotal(idx), 'all');
                        else
                            p = 0;
                        end
                        %check = check + p;
                        ts = sprintf('%s_%s_sub_%0.2f_%0.2f', bandName, stateName, sub_f_low, sub_f_high);
                        ts = strrep(ts, '.', '_'); % variable names can't have a period
                        eval([sprintf('powerStats(iMouse).%s = p;',ts )])
                    end
                end
            end
            
            % Process subbands
        end
        powerStats(iMouse).codename = mouse.codename{1};
        powerStats(iMouse).group = mouse.subtype{1};
        powerStats(iMouse).totalPercent = check;
    else
        % No scores, so add blanks
        for iState = 1:3
            stateName = settings.scoreToTextMap(int2str(iState));
            for iBand = 1:length(settings.bands)
                band = settings.bands(iBand);
                bandName = band.name;
                p = 0;
                eval([sprintf('powerStats(iMouse).%s_%s = p;', bandName, stateName)])
            end
        end
        powerStats(iMouse).codename = mouse.codename{1};
        powerStats(iMouse).group = mouse.subtype{1};
        powerStats(iMouse).totalPercent = 0;
    end
end
PowerTable = struct2table(powerStats);

h1 = figure;
%subplot(3,1,1)
boxplot(PowerTable.delta_NREM, PowerTable.group)
title('Delta NREM')
ylabel('Percent Total Power')
grid on

h2 = figure;
%subplot(3,1,2)
boxplot(PowerTable.theta_REM, PowerTable.group)
title('Theta REM')
ylabel('Percent Total Power')
grid on

h3 = figure;
%subplot(3,1,3)
boxplot(PowerTable.sigma_NREM, PowerTable.group)
title('Sigma NREM')
ylabel('Percent Total Power')
grid on

h4 = figure;
%subplot(3,1,3)
boxplot(PowerTable.beta_REM, PowerTable.group)
title('Beta REM')
ylabel('Percent Total Power')
grid on

saveas(h1, fullfile(outputFolder, sprintf('boxplot_bands_%s.png', 'delta_NREM')));
saveas(h2, fullfile(outputFolder, sprintf('boxplot_bands_%s.png', 'theta_REM')));
saveas(h3, fullfile(outputFolder, sprintf('boxplot_bands_%s.png', 'sigma_NREM')));
saveas(h4, fullfile(outputFolder, sprintf('boxplot_bands_%s.png', 'beta_REM')));


writetable(PowerTable, fullfile(outputFolder, 'band_powers_table.xlsx'))

save(fullfile(outputFolder, 'workspace.mat'));


