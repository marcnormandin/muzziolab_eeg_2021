[filename, pathname] = uigetfile(pwd, 'Select an EDF file');
fullFilename = fullfile(pathname, filename);
[data,header,cfg] = men_edf_read(fullFilename);
