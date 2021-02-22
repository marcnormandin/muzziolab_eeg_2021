function [freqs, meanGroupSpectrum, groups] = ml_wavelet_state_spectrums_group_compute( mouseTable, meanSpectrum, freqs, groupName, iState)
    % Get unique groups
    groups = unique(mouseTable.subtype);
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

    % Normalize each state spectrum of each mouse. The result is that the
    % sum of the spectrum will be 1.
    normalizedSpectrums = cell(size(meanSpectrum));
    for k = 1:length(miceIds)
        for iState = 1:3
            mouseId = miceIds(k);
            x = meanSpectrum{mouseId, iState};
            s = sum(x, 'all');
            x = x ./ s;
            normalizedSpectrums{mouseId, j} = x;
        end
    end
    
    % Copy all of the normalized spectrums into an array so that we can
    % compute the mean.
    groupSpectrums = [];
    for k = 1:length(miceIds)
        mouseId = miceIds(k);
        groupSpectrums(:,k) = normalizedSpectrums{mouseId, iState} ;
    end
    meanGroupSpectrum = mean(groupSpectrums,2); % Average over the mice
    
end % function
