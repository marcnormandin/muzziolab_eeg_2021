function [y_score_hypnogram] = compute_score_hyponogram(y_score)
    % 1, WAKE
    % 2, NREM
    % 3, REM
    CODE_WAKE = 1;
    CODE_NREM = 2;
    CODE_REM = 3;

    % We need to convert the scores to a y-value, where it goes
    % 1 = NREM, 2 = REM, 3 = WAKE
    % according to A. Krakovská, K. Mezeiová / Artificial Intelligence in
    % Medicine 53 (2011) 25– 33, FIGURE 1
    numScores = length(y_score);
    y_score_hypnogram = zeros(1,numScores);
    y_score_hypnogram(y_score == CODE_NREM) = 1;
    y_score_hypnogram(y_score == CODE_REM) = 2;
    y_score_hypnogram(y_score == CODE_WAKE) = 3;
end % function