dataFolder = uigetdir(pwd, 'Select the folder containing the EDF files and the scores');

% First check that each EDF (data) file has an associated score file
% (_scores.mat).
edfFilenames = dir( fullfile(dataFolder, '*.edf') );
allScoresAvailable = true;
for fn = 1:length(edfFilenames)
    [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
    scoreFilename = sprintf('%s_scores.mat', name);
    if exist( fullfile(filePath, scoreFilename), 'file' ) == false
        fprintf('The score file with name (%s) does not exist.\n', scoreFilename);
        allScoresAvailable = false;
        break
    end
end
if allScoresAvailable
    fprintf('All EDF files have associated scores! Fantastic!\n');
end

% Generate the Excel files required by the SpindleDetection software
if allScoresAvailable
    for fn = 1:length(edfFilenames)
        [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
        scoreFilename = sprintf('%s_scores.mat', name);
        
        x = matfile( fullfile(filePath, scoreFilename) );
        varlist = who(x);
        if length(varlist) == 1
            data = x.(varlist{1});
            scores = data.score;
            [scoreCounts, scoreEdges] = histcounts(scores, [0,1,2,3,inf]);
            for iScore = 1:length(scoreEdges)-1
                fprintf('Score %3d = %10d, ', scoreEdges(iScore), scoreCounts(iScore))
            end
            fprintf('\n');
            
            % All values should be 0, 1, 2
            if scoreCounts(4) ~= 0
                error('The file %s has a score == 3, but should only be 0,1,or 2.\n', scoreFilename);
            end
                        
            % Add 1 to get the proper mapping
            scores = scores + 1;
            fprintf('Adding +1 to the Excel scores to be compatibl with profs spingdle code.\n');
            
            
            % save the scores as a single columned Excel file
            excelFn = fullfile( filePath, sprintf('%s_scores.xlsx', name) );
            T = table(scores);
            writetable(T,excelFn,'Sheet',1,'WriteVariableNames',false)
        else
            fprintf('Error! The file %s contains more than one root variable!\n', scoreFilename)
            break;
        end
    end
end

fprintf('Done!')
