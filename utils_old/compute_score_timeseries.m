function [x_score, y_score] = compute_score_timeseries(scoredFilename, EPOCH_LENGTH_S)
    tmp = load(scoredFilename);
    f = fields(tmp);
    if length(f) ~= 1
        error('Expected the scored mat file to contain only one structure, but it contains more.');
    end

    s = tmp.(f{1});
    scores = s.score + 1;
    if any(~ismember(scores, [1,2,3]))
        error('Score values should be 1,2,3 but some other number is present')
    end

    numScores = length(scores);

    y_score = scores;
    x_score = (1:numScores) .* EPOCH_LENGTH_S;
end % function