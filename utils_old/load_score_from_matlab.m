function [x_score, y_score] = load_score_from_matlab(scoredFilename, EPOCH_LENGTH_S)
    tmp = load(scoredFilename, '-mat');
    f = fields(tmp);
    if length(f) ~= 1
        error('Expected the scored mat file to contain only one structure, but it contains more.');
    end

    s = tmp.(f{1});
    scores = s.score + 1; % the mat files have 0, 1, 2
    if any(~ismember(scores, [1,2,3]))
        error('Score values should be 1,2,3 but some other number is present')
    end

    % 1, WAKE
    % 2, NREM
    % 3, REM
    CODE_WAKE = 1;
    CODE_NREM = 2;
    CODE_REM = 3;

    numScores = length(scores);
%     y_score = zeros(1,numScores);
%     y_score(scores == CODE_NREM) = 1;
%     y_score(scores == CODE_REM) = 2;
%     y_score(scores == CODE_WAKE) = 3;
    y_score = scores;
    x_score = (1:numScores) .* EPOCH_LENGTH_S;
end % function
