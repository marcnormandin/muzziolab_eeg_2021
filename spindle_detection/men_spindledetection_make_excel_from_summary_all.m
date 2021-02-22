% Sleep Study
% Go through all of the EDF filenames and break down the code
close all
clear all
clc

dataFolder = uigetdir(pwd, 'Select the folder with the EDF data files');
spindleFolder = uigetdir(pwd, 'Select the folder with the SpindleDetection outputted mat files');

edfFilenames = dir( fullfile(dataFolder, '*.edf') );

mouseCodes = struct('technician', [], 'name', [], 'age', [], 'type', [], 'period', [], 'fullname', [], 'subtype', []);

for fn = 1:length(edfFilenames)
    [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
    
    nameParts = split(name, '_');
    mouseCodes(fn).technician = nameParts{1};
    mouseCodes(fn).name = nameParts{2};
    mouseCodes(fn).age = nameParts{3};
    mouseCodes(fn).type = nameParts{4};
    mouseCodes(fn).period = nameParts{5};
    mouseCodes(fn).fullname = name;
    mouseCodes(fn).subtype = [mouseCodes(fn).age mouseCodes(fn).type mouseCodes(fn).period];
end

T = struct2table(mouseCodes);
sortedT = sortrows(T, 'subtype');
sortedS = table2struct(sortedT);

numMissing = 0;
for fn = 1:length(sortedS)
    spindleDataFilenamePrefix = ['SummarySpResults_NREMall_' sortedS(fn).fullname];
    d = dir( fullfile(spindleFolder, [spindleDataFilenamePrefix '*.mat']) );
    if isempty(d)
        fprintf('Error! Unable to find %s.\n', spindleDataFilenamePrefix)
        numMissing = numMissing + 1;
    else
        sortedS(fn).spindleResultsFilename = d.name;
        
        x = load( fullfile(spindleFolder, sortedS(fn).spindleResultsFilename ) );
        vars = {...
            'NREM_Spindle', ...
            'TotalNREMTimeSec', ...
            'Avg_SpindleDuration_NREM', ...
            'Med_SpindleDuration_NREM', ...
            'SD_SpindleDuration_NREM', ...
            'Avg_SpindleAmplitude_NREM', ...
            'Med_SpindleAmplitude_NREM', ...
            'SD_SpindleAmplitude_NREM', ...
            'Avg_NormSpindleAmplitude_NREM', ...
            'Med_NormSpindleAmplitude_NREM', ...
            'SD_NormSpindleAmplitude_NREM', ...
            'Avg_SpindleHz_NREM', ...
            'Med_SpindleHz_NREM', ...
            'SD_SpindleHz_NREM' };
        for vn = 1:length(vars)
            v = x.Summary.(vars{vn});
            %for hr = 1:length(v)
            sortedS(fn).(vars{vn}) = v;
        end
    end
end

if numMissing ~= 0
    error('Missing required files.\n')
else
    fprintf('All required spindle results are present.\n');
end


sortedRecovery = sortedS([sortedS(:).period] == 'R');
sortedPostlearn = sortedS([sortedS(:).period] == 'P');

% Append date and time string
s = datestr(now);
s = strrep(s,'-','_');
s = strrep(s,' ','_');
s = strrep(s,':','_');

excelFilename = fullfile(spindleFolder, sprintf('men_sleepstudy_spindlesstats_%s.xlsx', s));

if ~isempty(sortedPostlearn)
    writetable(struct2table(sortedPostlearn), excelFilename, 'Sheet', 'Postlearn');
end

if ~isempty(sortedRecovery)
    writetable(struct2table(sortedRecovery),  excelFilename, 'Sheet', 'Recovery');
end
