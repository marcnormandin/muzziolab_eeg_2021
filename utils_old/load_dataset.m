function [dataset, numMice] = load_dataset()
    datasetFolder = 'T:\EPHYS_SLEEP_STUDY\datasets\dataset_1';

    dataset = men_edf_get_filenames( datasetFolder );
    numMice = length(dataset);
end % function
