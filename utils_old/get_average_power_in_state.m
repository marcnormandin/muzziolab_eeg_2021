function [meanPower, stdPower, numMatches] = get_average_power_in_state(band_timeseries, y_score, state_code)
    meanPower = 0;
    stdPower = 0;
    
    matchesi = find(y_score == state_code);
    numMatches = length(matchesi);
    if isempty(matchesi)
        return
    end
    
    state_power = band_timeseries(matchesi);
    
    meanPower = mean(state_power, 'all', 'omitnan');
    stdPower = std(state_power, 0, 'all', 'omitnan');
end