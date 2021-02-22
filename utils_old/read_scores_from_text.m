function [scores] = read_scores_from_text( filename )
%     Text file data should look like this
%     AEpoch #,Start Time,End Time,Score #, Score
%     1,03/19/2015 14:36:06,03/19/2015 14:36:10,1,Wake
%     2,03/19/2015 14:36:10,03/19/2015 14:36:14,1,Wake
%     3,03/19/2015 14:36:14,03/19/2015 14:36:18,1,Wake

    data = readmatrix( filename, 'filetype', 'text' );
    scores = data(:,4);
end % function
