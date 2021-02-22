function ml_ephys_bayesclassifier_scores_mat_to_xlsx(scoresMatFilename)
% This function reads in the scores from the Bayes Classifier and then
% converts the mat file to an Excel file for the spindle code.

    % Output filename
    scoresXlsxFilename = strrep(scoresMatFilename, '.mat', '.xlsx');

    % Load the Bayes Classifier scores that are also converted from
    % 0, 1, 2 to 1,2,3. So we only need to save it as Excel under a new
    % name.
    scoresMat = ml_ephys_bayesclassifier_scores_load_mat(scoresMatFilename);
    scoresMat = reshape(scoresMat, numel(scoresMat), 1); % We want it to be a column
    
    fprintf('File %s converted and saved as %s.\n', scoresMatFilename, scoresXlsxFilename);
    
    T = table(scoresMat);
    writetable(T,scoresXlsxFilename,'Sheet',1,'WriteVariableNames',false)
end
