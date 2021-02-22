function [scores] = ml_ephys_bayesclassifier_scores_load_excel( scoredFilename )
% Load an Excel 'xlsx' single-column file of scores
% We don't need to convert them from 0,1,2 because they are already
% converted to 1,2,3 for the spindle code.

    x = readtable( scoredFilename );
    y = table2struct(x);
    
    f = fieldnames(y);
    if length(f) ~= 1
        error('The imported score file has more than one field name!\n');
    end
    scores = [y.(f{1})]; 
end % function
