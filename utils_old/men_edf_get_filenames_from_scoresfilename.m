function [sortedS] = men_edf_get_filenames_from_scoresfilename( dataFolder )

edfFilenames = dir( fullfile(dataFolder, '*_scores.vis100') );

mouseCodes = struct('technician', [], 'name', [], 'age', [], 'type', [], 'period', [], 'fullname', [], ...
    'filePath', [], 'fullFilename', [], 'subtype', []);

for fn = 1:length(edfFilenames)
    [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
    
    nameParts = split(name, '_');
    mouseCodes(fn).technician = nameParts{1};
    mouseCodes(fn).name = nameParts{2};
    mouseCodes(fn).age = nameParts{3};
    mouseCodes(fn).type = nameParts{4};
    mouseCodes(fn).period = nameParts{5};
    mouseCodes(fn).fullname = strrep(name, '_scores', '');
    mouseCodes(fn).filePath = filePath;
    mouseCodes(fn).fullFilename = fullfile(edfFilenames(fn).folder, edfFilenames(fn).name);
    mouseCodes(fn).subtype = [mouseCodes(fn).age mouseCodes(fn).type mouseCodes(fn).period];
end

T = struct2table(mouseCodes);
sortedT = sortrows(T, 'subtype');
sortedS = table2struct(sortedT);

end % function
