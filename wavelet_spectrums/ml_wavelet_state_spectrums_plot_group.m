function [freqs, meanGroupSpectrum] = ml_wavelet_state_spectrums_plot_group(hMain, mouseTable, meanSpectrum, averageTotalPower, freqs, groupName, iState)
    % Get unique groups
    groups = unique(mouseTable.subtype)
    numGroups = length(groups);
    
    % We need these ids into the main table to access the data
    miceIds = find( ismember(mouseTable.subtype, groupName) );
    if isempty(miceIds)
        warning('No mice belong to the group name (%s)\n', groupName);
        return;
    end

    % Get all mice that belong to the group
    mouseGroupTable = mouseTable( miceIds, :);
    numGroupMice = size(mouseGroupTable, 1);
    fprintf('Found %d mice in the group.\n', numGroupMice);

    % Normalize the spectrums
    normalizedSpectrums = cell(size(meanSpectrum));
    for k = 1:length(miceIds)
        for j = 1:3
            mouseId = miceIds(k);
            x = meanSpectrum{mouseId, j};
            s = sum(x, 'all');
            x = x ./ s;
            normalizedSpectrums{mouseId, j} = x;
        end
    end
    
    groupSpectrums = [];
    for k = 1:length(miceIds)
        mouseId = miceIds(k);
        groupSpectrums(:,k) = normalizedSpectrums{mouseId, iState} ;
    end
    meanGroupSpectrum = mean(groupSpectrums,2); % Average over the mice

    clf(hMain, 'reset')
    %figure(hMain)
    plot(freqs, groupSpectrums, 'k-')
    hold on
    plot(freqs, meanGroupSpectrum, 'r-', 'linewidth', 2)
    xlabel('Frequency, f [Hz]')
    ylabel('Power (Normalized)')
    grid on
    title(sprintf('%s', groupName))
end
