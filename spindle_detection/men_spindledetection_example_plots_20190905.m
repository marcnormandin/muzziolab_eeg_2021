% Sleep Study
% Spindle Example
% August 6, 2019

close all
clear all
clc

% EEG 1
%spindleFolder = '../output/01_Aug_2019/19_45_01';
spindleFolder = '../output/02_Aug_2019/12_33_35';


eegFolder = '../../DATA/EEG_EMG';

% spindleFn = fullfile(spindleFolder, 'SpindleResults_NREMall_AT_19_O_D_RE2_0-0.99667h.mat');
% eegFn = fullfile(eegFolder, 'AT_19_O_D_R.edf');

spindleFn = fullfile(spindleFolder, 'SpindleResults_NREMall_AT_19_O_C_PE2_0-0.99667h.mat');
eegFn = fullfile(eegFolder, 'AT_19_O_C_P.edf');
%'AT_25_Y_C_P'

[data,header,cfg] = men_edf_read( eegFn );
load(spindleFn)

eeg2 = data(2,:);

% Copied from the spindle detection algorithm
%%% Bandpass filter data from 10-15Hz %%%
settings = men_spindledetection_load_settings();
fs = 400;

bpSpiFiltIIR = designfilt('bandpassiir','DesignMethod','butter','MatchExactly', 'stopband','StopbandFrequency1', 3, 'PassbandFrequency1', 10,...
    'PassbandFrequency2', 15, 'StopbandFrequency2', 22, 'StopbandAttenuation1', 24, 'PassbandRipple', 1, 'StopbandAttenuation2', 24, 'SampleRate', fs);
BandFiltered_DataAll=filtfilt(bpSpiFiltIIR,eeg2); % Zero-phase delay
RMS_DataAll = fastrms(BandFiltered_DataAll,fs*settings.rmsWindow);
Transformed_DataAll = RMS_DataAll'.^3;
%clear RMS_DataAll
x = Transformed_DataAll;

% This works, but is also negative
%x = BandFiltered_DataAll'.^3;   

%x = rms = fastrms(BandFiltered_DataAll,window,dim,amp)

%%
close all
tn = fs*10;
t = 0:size(data,2)-1;
t = t ./ fs;

plotW = 5;
plotH = 3;
plotN = plotW * plotH;
k = 0;
for spindleNum = 1:length(Results.SpindleStart_NREM)
    spindleStart = Results.SpindleStart_NREM( spindleNum );
    spindleStop = Results.SpindleEnd_NREM( spindleNum );


    a = spindleStart - tn;
    if a < 1
        a = 1;
    end
    b = spindleStop + tn;
    if b > length(eeg2)
        b = length(eeg);
    end

    spindleRegionT = t(a:b);
    spindleRegionEeg = x(a:b);

    spindleT = t(spindleStart:spindleStop);
    spindleEeg = x(spindleStart:spindleStop);

    if k == 0
    figure
    k = k + 1;
    end
    subplot(plotH, plotW, k)
    plot(spindleRegionT, spindleRegionEeg)
    hold on
    plot(spindleT, spindleEeg, 'r-')
    hold off
    set(gca,'visible','off')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    title(sprintf('%d', spindleNum))
    k = k + 1;
    if k > plotN
        k = 0;
    end
end

%%
figure
plot(t, x)
