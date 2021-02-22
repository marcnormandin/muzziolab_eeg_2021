function [settings] = men_spindledetection_load_settings_v17_5s(wakeCode, nremCode, remCode)



settings.filename = [];% Enter datafile name
settings.filetype = [];% Datafile format 'edf' 'mat'
settings.channel = [];% EEG1=1,EEG2=2 %Check channel order in fieldName
settings.scoreFileExt = ''; % Sleep score file name extension
settings.scoreType='number';
settings.scoreEpoch = 4;% Sleep scoring epoch size (s)
settings.wake = wakeCode; % Score ID for Wake
settings.nrem = nremCode; % Score ID for NREM
settings.rem = remCode; % Score ID for REM
settings.laserFileExt = ''; % Sleep score file name extension
settings.laserDur = 0;% Laser On duration (s), If no laser was used, put zero.
settings.startTime = 0;% Start time -1 for analysis (s), e.g. if first one hr is to be used, startTime=0.  Second hr 3600 etc..
settings.endTime = 17940; % default 3600;% End time for analysis (s) e.g. end of first hr=3600, second hr=7200, third hr=10800
settings.numblock = 5; % default 1; % Enter number of blocks within the selected interval to be analized (e.g. For analyzing each hour of selected 4hr recording, numblock=4. For analyzing the entire length of selected 4hr recording, numblock=1.)
settings.spindleState = 'NREM'; % Specify which sleep/wake state to use to detect spindles, 'NREM'=NREM spindles (default), 'WAKE'=Wake spindles, 'REM'=REM spindles
settings.method = 'mean'; % Choose method to define thresholds, 'mean'(default) or 'median'
settings.spindleInterval = 0.1; % minimum time between spindles (seconds) (default 0.1)
settings.threshState = 'all'; % default is 'all for v17_4s. default is 'nrem' for v17_5s; % Specify which sleep/wake state data to use for threshold setting, 'all'(default), 'wake','nrem','rem'
settings.lower_threshRatio = 1.2; % default for v17_4s is 1.2; % (v17_5s default is 1.0)
settings.upper_threshRatio = 3.5; % default for v17_4s is 3.5; % (v17_5s default is 2.5)
settings.lo_duration = 0.5; % minimum spindle duration (default 0.5)
settings.hi_duration = 10; % maximum apindle duration (default 10)
settings.rmsWindow = 3/4; % multiply fs by this number to set RMS window(default 3/4)
settings.smoothing = 'exp'; % 'exp'(default)= exponential weighted moving average filter, 'MA' = moving average smoothing, 'cubic'= svavitsky golay filter, 'binom'=binomial weighted moving average filter, 'none'=no smoothing,
settings.alpha = 0.05; % alpha value (between zero and one, default 0.05) used for exponential weighted moving average filter. A higher value of alpha will have less smoothing.
settings.timeBlock = 1000; % Time block for Moving average smoothing (default 1000)
settings.plotFigure = 0; % Enter 1 for plotting a main spindle figure at the end, 0 for skipping plotting.
settings.saveBigData = 0; % Enter 1 to save large data (Transformed_Data and BandFiltered_Data) at the end, 0 to avoid saving these data.
settings.exclLaserPeriod = 0; % Enter 1 to exclude data of laser on time when computing thresholds.
settings.stimInterval = 0; % Enter stimulus interval (s) (e.g. For 10Hz 5s-on 55s-off, the stimulus interval is 55s)
settings.subEpoch = 0; % Enter 1 to specify sub-epoch to use for spindle detection based on TTL laser time stamp.
settings.epochStart = 0; % Specify start time (s)of sub-epoch relative to TTL laser time stamp (e.g. To start the sub-epoch at the TTL laser time stamp, enter 0. To start the sub-epoch 10s after the TTL laser time stamp, enter 10. To start the sub-epoch 10s before the TTL laser time stamp, enter -10.)
settings.epochEnd = 0; % Specify end time (s) of sub-epoch relative to TTL laser time stamp (e.g. To end the sub-epoch 60s after the TTL laser time stamp, enter 60.)
end % function
