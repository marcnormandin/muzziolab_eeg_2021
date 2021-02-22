function men_spindledetection_example_plots_20200205_nospindles()

% Modified from what Isabel said to do yesterday. Removed the highlighting
% of the machine classified spindle sections so that Matt just has
% the data and will score himself (and compare later).

% Sleep Study
% Spindle Example
% Copied from August 6, 2019
% 2020-02-04
% 2020-02-05 Modified to remove spindle highlighting
close all
clear all
clc

eegFolder = '../../DATA/EEG_EMG';
eegFn = fullfile(eegFolder, 'AT_19_O_C_P.edf');

[data,header,cfg] = men_edf_read( eegFn );

eegNum = 1;
eeg = data(eegNum,:);
emg = data(3,:);

% Copied from the spindle detection algorithm
%%% Bandpass filter data from 10-15Hz %%%
settings = men_spindledetection_load_settings();
fs = 400;

bpSpiFiltIIR = designfilt('bandpassiir','DesignMethod','butter','MatchExactly', 'stopband','StopbandFrequency1', 3, 'PassbandFrequency1', 10,...
    'PassbandFrequency2', 15, 'StopbandFrequency2', 22, 'StopbandAttenuation1', 24, 'PassbandRipple', 1, 'StopbandAttenuation2', 24, 'SampleRate', fs);
BandFiltered_DataAll=filtfilt(bpSpiFiltIIR,eeg); % Zero-phase delay
RMS_DataAll = fastrms(BandFiltered_DataAll,fs*settings.rmsWindow);
Transformed_DataAll = RMS_DataAll'.^3;
%clear RMS_DataAll

% NEW PLOT 2020-02-04
t = 0:size(data,2)-1;
t = t ./ fs;
y0 = emg;
y1 = eeg;
y2 = BandFiltered_DataAll;
y3 = Transformed_DataAll;

y3_mean = mean(y3);
y3_low  = 1.2 * y3_mean;
y3_high = 3.5 * y3_mean;

h = figure('Name', 'AT_19_O_C_P.edf');
p = 4; q = 1;
k = 1;
ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y3, 'b-');
hold on
plot(t,ones(1,length(t)).*y3_low, 'k-')
plot(t,ones(1,length(t)).*y3_high, 'k:');
ylabel(sprintf('RMS\nTransformed'))
grid on
axis tight

ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y2, 'b-');
hold on
ylabel('band-filtered')
grid on
axis tight

ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y1, 'b-');
hold on
ylabel(sprintf('raw EEG #%d', eegNum))
grid on
axis tight


ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y0, 'b-');
hold on
ylabel('raw EMG')
xlabel('Time, t [secs]')
axis tight
grid on

linkaxes(ax, 'x')
axis tight

end % function
