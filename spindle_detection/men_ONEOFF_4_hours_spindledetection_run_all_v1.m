close all
clear all
clc

% NOTE. THIS SOURCE CODE REQUIRES THE SEPARATE 'SpindleDetection' software
% package from the contact of Dr. Muzzio. Add it to the search path.
WAKE_CODE=1; % these are the values in the XLSX files that I make which are 1,2,3
NREM_CODE=2;
REM_CODE=3;
EEG_NUM_TO_USE = input('Enter EEG number to use. 1 or 2.');

% Location of the EDF files
%INPUT_DATA_DIR = fullfile('..','..', 'DATA', 'EEG_EMG');
INPUT_DATA_DIR = uigetdir(pwd, 'Select the input data directory containing the EDF and score files');

% Location to output the results to
OUTPUT_PARENT_DIR = uigetdir(pwd, 'Select the main output directory');
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

if ~exist([OUTPUT_PARENT_DIR filesep dateStr filesep timeStr filesep sprintf('eeg_%d', EEG_NUM_TO_USE)], 'dir')
    mkdir([OUTPUT_PARENT_DIR filesep dateStr filesep timeStr filesep sprintf('eeg_%d', EEG_NUM_TO_USE)]);
end

OUTPUT_DIR = [OUTPUT_PARENT_DIR filesep dateStr filesep timeStr filesep sprintf('eeg_%d', EEG_NUM_TO_USE)];
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
        settings = men_spindledetection_load_settings(WAKE_CODE, NREM_CODE, REM_CODE);
        settings.filename = name;
        settings.filetype = 'edf';
        settings.channel = EEG_NUM_TO_USE; % USE EEG 2
        settings.scoreFileExt = '_scores';
        
        fprintf('USING 4 HOURS ONLY\n');
        settings.endTime = 4*3600;
        settings.numblock = 4;
        
        % Call the main program (bypass the GUI)
        Spindle_detect_v17_4s_function_muzziolab(settings, INPUT_DATA_DIR, OUTPUT_DIR);
    end
end

% Save the settings
settings.input_data_dir = INPUT_DATA_DIR;
settings.output_dir = OUTPUT_DIR;
settings.dateStr = dateStr;
settings.timeStr = timeStr;
save(fullfile(OUTPUT_DIR, 'settings.mat'), 'settings');

fprintf('SpindleDetection RUN ALL completed successfully!\n')
