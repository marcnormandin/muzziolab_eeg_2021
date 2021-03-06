function scores = ml_ephys_bayesclassifier_scores_load(scoredMatFilename)
% This load the scores from the matlab files generated by the Bayes
% Classifier. The ridiculousness is that the main variable is always the
% name of the mouse and so we need to find that name dynamically.
%
% Also the Bayes Classifier uses codes 0,1,2, but the spinde detection
% needs the codes as 1,2,3, so this code also adds 1 to the codes for the
% conversion.

    tmp = load(scoredMatFilename, '-mat');
    f = fields(tmp);
    if length(f) ~= 1
        error('Expected the scored mat file to contain only one structure, but it contains more.');
    end

    s = tmp.(f{1});
    scores = s.score + 1; % the mat files have 0, 1, 2
    if any(~ismember(scores, [1,2,3]))
        error('Score values should be 1,2,3 but some other number is present')
    end
end % function
