% Convert all Bayes Classifier scores to Excel scores
close all
clear all
clc

datasetFolder = 'T:\projects\eeg_2021\datasets\dataset_10_included_excluded';

files = dir( fullfile(datasetFolder, '*.edf' ) );
for iFile = 1:length(files)
    edfFilename = fullfile( files(iFile).folder, files(iFile).name );
    scoresMatFilename = strrep(edfFilename, '.edf', '_scores.mat');
    
    ml_ephys_bayesclassifier_scores_mat_to_xlsx(scoresMatFilename);
end
