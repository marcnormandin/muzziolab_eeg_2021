function [scores4, epochLength_s] = ml_ephys_load_scores_xlsx( scoredFilename )
% Load an Excel 'xlsx' single-column file of scores
    x = readtable( scoredFilename );
    y = table2struct(x);
    
    f = fieldnames(y);
    if length(f) ~= 1
        error('The imported score file has more than one field name!\n');
    end
    scores4 = [y.(f{1})];
    
    % The excel files SHOULD have the epoch length, but dont
    epochLength_s = 4; % 4 seconds
    
end % function
