function ml_ephys_plot_scored_timeseries(data_timeseries_full_fs, fs, scores, secsPerEpoch)

colorMap = containers.Map({'255','1','2','3'}, {[0.5, 0.5, 0.5], [1.0, 0, 0], [0, 1, 0], [0, 0, 1]});
%secsPerEpoch = 4;

numSamples = length(data_timeseries_full_fs);
numScores = length(scores);
tSecs = 0:(numSamples-1);
tSecs = tSecs ./ fs;
tHrs = tSecs ./ 3600;

data_timeseries = data_timeseries_full_fs;
% resample
%data_timeseries = resample(data_timeseries_full_fs,secsPerEpoch,1);

scorePerTimeSample = repelem(scores, secsPerEpoch*fs);

% Make the same length
if scorePerTimeSample > length(data_timeseries)
    scorePerTimeSample = scorePerTimeSample(1:length(data_timeseries));
elseif scorePerTimeSample < length(data_timeseries)
    tend = length(scorePerTimeSample);
    scorePerTimeSample(tend+1:length(data_timeseries)) = scorePerTimeSample(tend);
end
uniqueScores = unique(scores)
for iScore = 1:length(uniqueScores)
    scoreValue = uniqueScores(iScore);
    indices = find(scorePerTimeSample == scoreValue);
    x = tHrs(indices);
    %x = 1:length(emg);
    %x = x(indices);
    y = data_timeseries(indices);
    
    % We don't want to draw lines between the gaps so we need to group them
    gids = ml_util_group_points(indices, 1);
    ugids = unique(gids);
    for iGroup = 1:length(ugids)
        ugid = ugids(iGroup);
        gindices = find(gids == ugid);
        plot(x(gindices), y(gindices), '-', 'color', colorMap(num2str(scoreValue)));
        hold on
    end % iGroup
end
hold on
%title(sprintf('%s\ngray not scored, red = wake, green = nrem, blue = rem', fnPrefix), 'Interpreter', 'none')
% ylabel('EMG', 'fontsize', YLABELSIZE)
% xlabel('Time, t [hour]', 'fontsize', XLABELSIZE)
% grid on
% a = get(gca,'YTickLabel');  
% set(gca,'YTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
% set(gca,'YTickLabelMode','auto')
% 
% a = get(gca,'XTickLabel');  
% set(gca,'XTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
% set(gca,'XTickLabelMode','auto')

end % function
