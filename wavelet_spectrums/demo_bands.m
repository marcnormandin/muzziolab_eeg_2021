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

%%
iMouse = 1;
mouse = mouseTable(iMouse,:)

mMean = meanSpectrum(iMouse,:);

stateTotal = zeros(1, 3);
for iState = 1:3
    stateTotal(iState) = sum(mMean{iState}, 'all');
end
total = sum(stateTotal, 'all');

bandColours = zeros(length(settings.bands),3);
bandColours(1,:) = [1, 0, 0];
bandColours(2,:) = [0, 1, 0];
bandColours(3,:) = [0, 0, 1];
bandColours(4,:) = [1, 1, 0];
bandColours(5,:) = [0, 1, 1];

close all
figure
p = 3; q = 3; k = 1;
sumPower = zeros(length(freqs),1);
for iState = 1:3
    ax(k) = subplot(p,q,k);
    k = k + 1;
    y = mMean{iState};
    plot(freqs, y)
    sumPower = sumPower + mMean{iState};
    title(settings.scoreToTextMap(int2str(iState)))
    if iState == 1
       ylabel(sprintf('Average\nstate power'))
    end
    
    hold on
    for iBand = 1:length(settings.bands)
        band = settings.bands(iBand);
        idx = find( freqs >= band.f_low & freqs <= band.f_high );
        if ~isempty(idx)
            H=area(freqs(idx),y(idx), 'FaceColor', bandColours(iBand,:));
        end
    end
end
for iState = 1:3
    ax(k) = subplot(p,q,k);
    k = k + 1;
    y = mMean{iState} ./ sumPower * 100;
    plot(freqs, y)
    if iState == 1
        ylabel(sprintf('Normalized\nPercent total\n per f'))
    end
        hold on
    for iBand = 1:length(settings.bands)
        band = settings.bands(iBand);
        idx = find( freqs >= band.f_low & freqs <= band.f_high );
        if ~isempty(idx)
            H=area(freqs(idx),y(idx), 'FaceColor', bandColours(iBand,:));
        end
    end
    
    %sumPower = sumPower + mMean{iState};
end
for iState = 1:3
    ax(k) = subplot(p,q,k);
    k = k + 1;
    y = mMean{iState} ./ total*100;
    %plot(freqs, mMean{iState} .* stateTotal(iState) ./ total)
    plot(freqs, y)
    %sumPower = sumPower + mMean{iState};
    if iState == 1
        ylabel(sprintf('Normalized\nPercent total\n all f'))
    end
    
    hold on
    for iBand = 1:length(settings.bands)
        band = settings.bands(iBand);
        idx = find( freqs >= band.f_low & freqs <= band.f_high );
        if ~isempty(idx)
            H=area(freqs(idx),y(idx), 'FaceColor', bandColours(iBand,:));
        end
    end
end