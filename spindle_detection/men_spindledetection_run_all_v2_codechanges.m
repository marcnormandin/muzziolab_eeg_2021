close all
clear all
clc

% NOTE. THIS SOURCE CODE REQUIRES THE SEPARATE 'SpindleDetection' software
% package from the contact of Dr. Muzzio. Add it to the search path.
WAKE_CODE=1; % these are the values in the XLSX files that I make which are 1,2,3
NREM_CODE=2;
REM_CODE=3;

% SpindleCode version to use
spindleVersion_1 = 'v17_4s'; % This is the first version we used and whose data was submitted to referees
spindleVersion_2 = 'v17_5s'; % This is the second version given to us on 2020-03-11
spindleVersion = spindleVersion_2;

sprintf('Using SpindleDetection version %s\n', spindleVersion);


% Location of the EDF files
INPUT_DATA_DIR = fullfile('..','..', 'DATA', 'EEG_EMG');

% Location to output the results to
OUTPUT_PARENT_DIR = fullfile('..', 'output', spindleVersion);
t = datestr(datetime('now','TimeZone','local','Format','d_MMM_y HH_mm_ss'));
z = strrep(t, '-', '_');
z = strrep(z, ':', '_');
z = split(z, ' ');
dateStr = z{1};
timeStr = z{2};


if ~exist( OUTPUT_PARENT_DIR, 'dir' )
    mkdir( OUTPUT_PARENT_DIR )
end

if ~exist([OUTPUT_PARENT_DIR filesep dateStr], 'dir')
    mkdir([OUTPUT_PARENT_DIR filesep dateStr])
end

if ~exist([OUTPUT_PARENT_DIR filesep dateStr filesep timeStr], 'dir')
    mkdir([OUTPUT_PARENT_DIR filesep dateStr filesep timeStr])
end

OUTPUT_DIR = [OUTPUT_PARENT_DIR filesep dateStr filesep timeStr];
fprintf('All output files will be saved to the directory: %s\n', OUTPUT_DIR);


% First check that each EDF (data) file has an associated score file
% (_scores.mat).
edfFilenames = dir( fullfile(INPUT_DATA_DIR, '*.edf') );
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
    
    for fn = 1:length(edfFilenames)
        [filePath, name, ext] = fileparts( fullfile(edfFilenames(fn).folder, edfFilenames(fn).name) );
        
        % Now run the SpindleDetection program on all of the scored data
        if strcmp(spindleVersion, 'v17_4s')
            settings = men_spindledetection_load_settings(WAKE_CODE, NREM_CODE, REM_CODE);
        elseif strcmp(spindleVersion, 'v17_5s')
            settings = men_spindledetection_load_settings_v17_5s(WAKE_CODE, NREM_CODE, REM_CODE);
        else
            error('Invalid spindle version')
        end
        
        settings.filename = name;
        settings.filetype = 'edf';
        settings.channel = 2; % USE EEG 2
        settings.scoreFileExt = '_scores';
        
        % Call the main program (bypass the GUI)
        if strcmp(spindleVersion, 'v17_4s')
            Spindle_detect_v17_4s_function_muzziolab(settings, INPUT_DATA_DIR, OUTPUT_DIR);
        elseif strcmp(spindleVersion, 'v17_5s')
            Spindle_detect_v17_5s_function_muzziolab(settings, INPUT_DATA_DIR, OUTPUT_DIR);
        else
            error('Invalid spindle version')
        end
    end
end

% Save the settings
settings.input_data_dir = INPUT_DATA_DIR;
settings.output_dir = OUTPUT_DIR;
settings.dateStr = dateStr;
settings.timeStr = timeStr;
settings.spindleVersion = spindleVersion;
save(fullfile(OUTPUT_DIR, 'settings.mat'), 'settings');

fprintf('SpindleDetection RUN ALL completed successfully!\n')
