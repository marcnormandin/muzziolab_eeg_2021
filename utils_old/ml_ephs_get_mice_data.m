function [rec] = ml_ephs_get_mice_data(dataFolder, searchSubdirs)

if searchSubdirs
    edfFiles = dir(fullfile(dataFolder, '**\*.edf'));
else
    edfFiles = dir(fullfile(dataFolder, '*.edf'));
end

numEdfFiles = length(edfFiles);
rec = struct('filePath', {}, 'fullFilename', {}, 'filename', {}, 'codename', {}, 'name',{},'isOld', {},'isYoung', {}, 'isControl', {}, 'isSD', {}, 'isPostLearn', {}, 'isRecovery', {});

for iEdf = 1:numEdfFiles
    edfFn = edfFiles(iEdf).name;
    s = split(edfFn, '_');
    
    %d = struct('name',{},'isOld', {},'isYoung', {}, 'isPostLearn', {}, 'isRecovery', {});
    d = [];
    d.filePath = edfFiles(iEdf).folder;
    d.fullFilename = fullfile(edfFiles(iEdf).folder, edfFiles(iEdf).name);
    
    d.filename = edfFn;

    d.name  = strcat(s{1},'_',s{2});
    
    ss = split(edfFn, '.');
    d.codename = ss{1};
    
    if strcmp(s{3}, 'O')
        d.isOld = true;
    else
        d.isOld = false;
    end
    
    if strcmp(s{3}, 'Y')
        d.isYoung = true;
    else
        d.isYoung = false;
    end
    
    if strcmp(s{4}, 'C')
        d.isControl = true;
    else
        d.isControl = false;
    end
    
    if strcmp(s{4}, 'D')
        d.isSD = true;
    else
        d.isSD = false;
    end
    
    if strcmp(s{5}, 'P.edf')
        d.isPostLearn = true;
    else
        d.isPostLearn = false;
    end
    
    if strcmp(s{5}, 'R.edf')
        d.isRecovery = true;
    else
        d.isRecovery = false;
    end
    
    rec(end+1) = d;
end
end % function
