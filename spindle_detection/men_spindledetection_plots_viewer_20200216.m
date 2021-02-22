function men_spindledetection_plots_viewer_20200216()

% Sleep Study
% Spindle Example
% Copied from August 6, 2019
% 2020-02-04
close all
clear all
clc

% NEED TO TEST THIS VERSION MORE

% EEG 1
%spindleFolder = '../output/01_Aug_2019/19_45_01';
edfSearchFolder = '../../DATA/EEG_EMG';
spindleSearchFolder = '../output/02_Aug_2019/12_33_35';

% spindleFn = fullfile(spindleFolder, 'SpindleResults_NREMall_AT_19_O_D_RE2_0-0.99667h.mat');
% eegFn = fullfile(eegFolder, 'AT_19_O_D_R.edf');
[edfFilename, eegFolder] = uigetfile({sprintf('%s/*.edf',edfSearchFolder)}, 'Select the EDF file'); % eg. 'AT_19_O_C_P.edf';
%[spindleFilename, spindleFolder] = uigetfile({sprintf('%s/SpindleResults_NREMall_*.mat', spindleSearchFolder)}, 'Select first hour spindle file'); % eg. 'SpindleResults_NREMall_AT_19_O_C_PE2_0-0.99667h.mat';
spindleFolder = spindleSearchFolder;
tmp = split(edfFilename,'.');

spindleFilename = sprintf('SpindleResults_NREMall_%sE2_0-0.99667h.mat', tmp{1});
edfFn = fullfile(eegFolder, edfFilename);
spindleFn = fullfile(spindleFolder, spindleFilename);
%'AT_25_Y_C_P'

[data,header,cfg] = men_edf_read( edfFn );

% Spindle Results
load(spindleFn)
numSpindles = length(Results.SpindleStart_NREM);

%eegNum = str2num(input('Use EEG 1 or EEG 2? 1/2 [2]: ', 's'));
eegNum = 2;
if isempty(eegNum)
    eegNum = 2;
end
eeg = data(eegNum,:);
emg = data(3,:);


% Copied from the spindle detection algorithm
%%% Bandpass filter data from 10-15Hz %%%
settings = men_spindledetection_load_settings(WAKE_CODE, NREM_CODE, REM_CODE);
fs = 400;

bpSpiFiltIIR = designfilt('bandpassiir','DesignMethod','butter','MatchExactly', 'stopband','StopbandFrequency1', 3, 'PassbandFrequency1', 10,...
    'PassbandFrequency2', 15, 'StopbandFrequency2', 22, 'StopbandAttenuation1', 24, 'PassbandRipple', 1, 'StopbandAttenuation2', 24, 'SampleRate', fs);
BandFiltered_DataAll=filtfilt(bpSpiFiltIIR,eeg); % Zero-phase delay
RMS_DataAll = fastrms(BandFiltered_DataAll,fs*settings.rmsWindow);
Transformed_DataAll = RMS_DataAll'.^3;
%clear RMS_DataAll
x = Transformed_DataAll;

% NEW PLOT 2020-02-04
tn = fs*10;
t = 0:size(data,2)-1;
t = t ./ fs;
y0 = emg;
y1 = eeg;
y2 = BandFiltered_DataAll;
y3 = Transformed_DataAll;

y3_mean = mean(y3);
y3_low  = 1.2 * y3_mean;
y3_high = 3.5 * y3_mean;


% Trunacate it so that only the first hour is shown
hourIndex = find(t >= 3600, 1, 'first');
nr = 1:hourIndex;
t = t(nr);
y0 = y0(nr);
y1 = y1(nr);
y2 = y2(nr);
y3 = y3(nr);

h = figure('Name', edfFilename);
p = 5; q = 1;
k = 1;
ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y3, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y3)
end
plot(t,ones(1,length(t)).*y3_low, 'g-', 'linewidth', 2)
plot(t,ones(1,length(t)).*y3_high, 'g:', 'linewidth', 2);
ylabel(sprintf('RMS\nTransformed'))
grid on
axis tight

ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y2, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y2)
end
ylabel('band-filtered')
grid on
axis tight

ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y1, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y1)
end
ylabel(sprintf('raw EEG #%d', eegNum))
grid on
axis tight


ax(k) = subplot(p,q,k);
k = k + 1;
yscore = zeros(1,length(t));
for iSpindle = 1:numSpindles
    spindleStart = Results.SpindleStart_NREM( iSpindle );
    spindleStop = Results.SpindleEnd_NREM( iSpindle );
    yscore(spindleStart:spindleStop) = 1;
end
yscore_1 = find(yscore == 1);
plot(t(yscore_1), yscore(yscore_1), 'r.');
hold on
yscore_0 = find(yscore == 0);
plot(t(yscore_0), yscore(yscore_0), 'b.');
ylabel(sprintf('algorithm\nspindle score'))
grid on
axis tight

ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y0, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y0)
end
ylabel('raw EMG')
xlabel('Time, t [secs]')
axis tight
grid on

linkaxes(ax, 'x')
axis tight

end % function

function plot_spindle_num(Results, spindleNum, t, y)
    spindleStart = Results.SpindleStart_NREM( spindleNum );
    spindleStop = Results.SpindleEnd_NREM( spindleNum );
    spindleT = t(spindleStart:spindleStop);
    spindleEeg = y(spindleStart:spindleStop);

    plot(spindleT, spindleEeg, 'r-')
end % function
