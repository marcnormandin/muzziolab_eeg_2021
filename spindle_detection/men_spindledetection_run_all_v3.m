% 2021-01-18. I created this from the v2 version. It was modified to use
% the new and improved data loading and settings system.

% NOTE. THIS SOURCE CODE REQUIRES THE SEPARATE 'SpindleDetection' software
% package from the contact of Dr. Muzzio. Add it to the search path.


close all
clear all
clc

settings = ml_sleepstudy_settings_load();
mouseTable = ml_sleepstudy_mousetable_load(settings)
numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'spindles');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end



sprintf('Using SpindleDetection version %s\n', settings.spindleVersion);


% Location to output the results to
OUTPUT_PARENT_DIR = fullfile(outputFolder, settings.spindleVersion);
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


for iMouse = 1:numMice
    mouse = mouseTable(iMouse,:);

    % Now run the SpindleDetection program on all of the scored data
    if strcmp(settings.spindleVersion, 'v17_4s')
        spindleSettings = men_spindledetection_load_settings(settings.CODE_WAKE, settings.CODE_NREM, settings.CODE_REM);
    elseif strcmp(settings.spindleVersion, 'v17_5s')
        spindleSettings = men_spindledetection_load_settings_v17_5s(settings.CODE_WAKE, settings.CODE_NREM, settings.CODE_REM);
    else
        error('Invalid spindle version (%s). Must be v17_4s or v17_5s.', settings.spindleVersion)
    end

    [filePath, name, ext] = fileparts( mouse.eegFullFilename{1} );
    
    spindleSettings.filename = name;
    spindleSettings.filetype = 'edf';
    spindleSettings.channel = mouse.eegSelected;
    spindleSettings.scoreFileExt = '_scores';

    % Call the main program (bypass the GUI)
    if strcmp(settings.spindleVersion, 'v17_4s')
        Spindle_detect_v17_4s_function_muzziolab(spindleSettings, settings.datasetFolder, OUTPUT_DIR);
    elseif strcmp(settings.spindleVersion, 'v17_5s')
        Spindle_detect_v17_5s_function_muzziolab(spindleSettings, settings.datasetFolder, OUTPUT_DIR);
    else
        error('Invalid spindle version')
    end
end


% Save the settings
spindleSettings.input_data_dir = settings.datasetFolder;
spindleSettings.output_dir = OUTPUT_DIR;
spindleSettings.dateStr = dateStr;
spindleSettings.timeStr = timeStr;
spindleSettings.spindleVersion = settings.spindleVersion;

save(fullfile(OUTPUT_DIR, 'workspace.mat'));

fprintf('SpindleDetection RUN ALL completed successfully!\n')
