function [sortedT] = ml_ephys_mice_table_load( dataFolder )
% This is used to create a table of data (but may not be the final one used
% since some mice will be filtered out if the data is poor).
settings = ml_sleepstudy_settings_load(); % Hack to get a default eeg number

edfFilenames = dir( fullfile(dataFolder, '*.edf') );

mouseCodes = struct('technician', [], 'name', [], 'age', [], 'type', [], 'period', [], 'subtype', [], 'codename', [], ...
    'filePath', [], 'eegFullFilename', [], 'scoresFullFilename', [], 'eegSelected', []);

for fn = 1:length(edfFilenames)
    [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
    
    nameParts = split(name, '_');
    mouseCodes(fn).technician = nameParts{1};
    mouseCodes(fn).name = nameParts{2};
    mouseCodes(fn).age = nameParts{3};
    mouseCodes(fn).type = nameParts{4};
    mouseCodes(fn).period = nameParts{5};
    mouseCodes(fn).codename = name;
    mouseCodes(fn).subtype = [mouseCodes(fn).age mouseCodes(fn).type mouseCodes(fn).period];
    mouseCodes(fn).filePath = filePath;
    mouseCodes(fn).eegFullFilename = fullfile(edfFilenames(fn).folder, edfFilenames(fn).name);
    mouseCodes(fn).scoresFullFilename = strrep(mouseCodes(fn).eegFullFilename, '.edf', '_scores.xlsx');
    mouseCodes(fn).eegSelected = settings.eegSelectedDefault;
    
    if isfile(mouseCodes(fn).scoresFullFilename)
        mouseCodes(fn).scores = ml_ephys_bayesclassifier_scores_load_excel( mouseCodes(fn).scoresFullFilename );
    else
        mouseCodes(fn).scores = [];
    end
end

T = struct2table(mouseCodes);
sortedT = sortrows(T, 'subtype');
%sortedS = table2struct(sortedT);

end % function
