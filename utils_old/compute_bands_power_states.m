%%
function [band_power_states] = compute_bands_power_states(settings, band_power_timeseries, bands, y_score)
    states = [settings.CODE_WAKE, settings.CODE_NREM, settings.CODE_REM];  
    num_states = length(states);
    
    num_info_per_state = 3;

    % Process each band
    numBands = length(bands);
    band_power_states = nan(numBands, num_states*num_info_per_state); % allocate memory, 2 for mean, and std, and numMatches
    for iBand = 1:numBands
        single_band_timeseries = band_power_timeseries(iBand,:);
        
        for iState = 1:num_states
            state_code = states(iState);
            [meanPower, stdPower, numMatches] = get_average_power_in_state(single_band_timeseries, y_score, state_code);
            band_power_states(iBand, num_info_per_state*(iState-1)+1) = meanPower;
            band_power_states(iBand, num_info_per_state*(iState-1)+2) = stdPower;
            band_power_states(iBand, num_info_per_state*(iState-1)+3) = numMatches;
        end % iState
    end
    
end % function