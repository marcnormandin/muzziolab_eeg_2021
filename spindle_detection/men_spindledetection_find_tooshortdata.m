% This script finds EDF files that don't have the minimum of 5 hours of
% data

dataFolder = pwd;

edfFilenames = dir( fullfile(dataFolder, '*.edf') );
for fn = 1:length(edfFilenames)
    [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
    [hdr, record]= edfread( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
    %fprintf('%s: %d\n', edfFilenames(fn).name, size(record,2))
    if size(record,2) < 5*3600*400
        d = size(record,2) / 3600 / 400;
        fprintf('OOPS! %s: has less than 5 hours of data (%f hours)\n', edfFilenames(fn).name, d)
    end
end

