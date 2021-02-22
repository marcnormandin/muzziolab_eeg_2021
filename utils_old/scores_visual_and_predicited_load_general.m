function [score_truth, score_predicted] = scores_visual_and_predicited_load_general(filenameTruth, filenamePredicted)
    
    %A = xlsread(fullfile('T:\EPHYS_SLEEP_STUDY\datasets\dataset_6_100percent', 'AT_14_Y_C_R_formatted.xlsx'));
    score_truth = read_scores_from_text(filenameTruth);
    score_truth = score_truth';
    
    % mat
    %score_predicted = read_scores_from_text(fullfile('T:\EPHYS_SLEEP_STUDY\datasets\dataset_6_100percent\AT15', 'NEW10pscores.txt'));
    %score_predicted = score_predicted';
    score_predicted_filename = filenamePredicted;
    [~, score_predicted] = load_score_from_matlab(score_predicted_filename, 4);
    score_predicted = score_predicted';
    
    % clean since everything is different!
    score_truth = reshape(score_truth, 1, length(score_truth));
    score_predicted = reshape(score_predicted, 1, length(score_predicted));

    % make the same length
    len = min([length(score_truth), length(score_predicted)]);
    if len < length(score_truth)
        score_truth(len+1:end) = [];
    end
    if len < length(score_predicted)
        score_predicted(len+1:end) = [];
    end    
end % function
