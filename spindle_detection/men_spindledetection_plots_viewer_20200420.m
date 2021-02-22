function men_spindledetection_plots_viewer_20200420()
% Modified this one heavily so that the spindle lines up with the
% threshold.

% Sleep Study
% Spindle Example
% Copied from August 6, 2019
% 2020-02-04
close all
clear all
clc

% NEED TO TEST THIS VERSION MORE
% EXAMPLE IS AT 14 Y C R zoomed to 160-175 secs

% EEG 1
%spindleFolder = '../output/01_Aug_2019/19_45_01';
edfSearchFolder = '../../DATA/EEG_EMG';
%spindleSearchFolder = '../output/02_Aug_2019/12_33_35';
spindleSearchFolder = '../output/31_Mar_2020/19_19_21/eeg_2';

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

% package from the contact of Dr. Muzzio. Add it to the search path.
WAKE_CODE=1; % these are the values in the XLSX files that I make which are 1,2,3
NREM_CODE=2;
REM_CODE=3;

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
%tn = fs*10;
t = 0:size(data,2)-1;
t = t ./ fs;
y0 = emg;
y1 = eeg;
y2 = BandFiltered_DataAll;
y3 = Transformed_DataAll;

% This is how we calculate it if not using a state (all states)
% but instead we just grab it from the spindle results
%y3_mean = mean(y3);
%y3_low  = 1.2 * y3_mean;
%y3_high = 3.5 * y3_mean;
y3_low = Results.Lower_threshold;
y3_high = Results.Upper_threshold;

% Trunacate it so that only the first hour is shown
hourIndex = find(t >= 3600, 1, 'first');
nr = 1:hourIndex;
t = t(nr);
y0 = y0(nr);
y1 = y1(nr);
y2 = y2(nr);
y3 = y3(nr);

YLABELSIZE=14;
YTICKFONTSIZE=12;
YTICKFONTWEIGHT='bold';

XLABELSIZE=16;

h = figure('Name', edfFilename);
p = 5; q = 1;
k = 1;
ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y3, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y3, y3_low, y3)
end
plot(t,ones(1,length(t)).*y3_low, 'k-', 'linewidth', 2)
plot(t,ones(1,length(t)).*y3_high, 'k:', 'linewidth', 2);
ylabel(upper(sprintf('RMS\nTransformed')), 'fontsize', YLABELSIZE)

grid on
axis tight
a = get(gca,'YTickLabel');  

set(gca,'YTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
set(gca,'YTickLabelMode','auto')


set(gca,'Xticklabel',[])

ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y2, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y3, y3_low, y2)
end
ylabel(upper('band-filtered'), 'fontsize', YLABELSIZE)
grid on
axis tight
set(gca,'Xticklabel',[])
set(gca,'YTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
set(gca,'YTickLabelMode','auto')


ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y1, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y3, y3_low, y1)
end
%ylabel(upper(sprintf('raw EEG #%d', eegNum), 'fontsize', YLABELSIZE))
ylabel(upper(sprintf('raw EEG', eegNum)), 'fontsize', YLABELSIZE)
grid on
axis tight
set(gca,'Xticklabel',[])
set(gca,'YTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
set(gca,'YTickLabelMode','auto')


ax(k) = subplot(p,q,k);
k = k + 1;
yscore = zeros(1,length(t));
for iSpindle = 1:numSpindles
    %spindleStart = Results.SpindleStart_NREM( iSpindle );
    %spindleStop = Results.SpindleEnd_NREM( iSpindle );
    [spindleStart, spindleStop] = get_corrected_spindle_bounds(Results, iSpindle, y3, y3_low);

    yscore(spindleStart:spindleStop) = 1;
    %yscore = ones(1, length(y3));
    %plot_spindle_num_score(Results, iSpindle, t, y3, y3_low)

end
yscore_1 = find(yscore == 1);
plot(t(yscore_1), yscore(yscore_1), 'r.');
hold on
yscore_0 = find(yscore == 0);
plot(t(yscore_0), yscore(yscore_0), 'b.');
ylabel(upper(sprintf('algorithm\nspindle score')), 'fontsize', YLABELSIZE)
grid on
axis tight
set(gca,'Xticklabel',[])
set(gca,'YTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
set(gca,'YTickLabelMode','auto')


ax(k) = subplot(p,q,k);
k = k + 1;
plot(t, y0, 'b-');
hold on
for iSpindle = 1:numSpindles
    plot_spindle_num(Results, iSpindle, t, y3, y3_low, y0)
end
ylabel(upper('raw EMG'), 'fontsize', YLABELSIZE)
xlabel('Time, t [sec]', 'fontsize', XLABELSIZE)

axis tight
grid on

a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',14,'FontWeight','bold')
set(gca,'XTickLabelMode','auto')

set(gca,'YTickLabel',a,'fontsize',YTICKFONTSIZE,'FontWeight',YTICKFONTWEIGHT)
set(gca,'YTickLabelMode','auto')

ylim([-200, 200])
yticks([-200,-100,0,100,200])

linkaxes(ax, 'x')
%axis tight

xlim([2273, 2284])

end % function

function [spindleStart, spindleStop] = get_corrected_spindle_bounds(Results, spindleNum, y, lowerThreshold)
    spindleStart = Results.SpindleStart_NREM( spindleNum );
    spindleStop = Results.SpindleEnd_NREM( spindleNum );

    % For some unknown reason the spindle indices are not lined up with
    % the threshold, so we have to calculate them
    if y(spindleStart) < lowerThreshold
        while y(spindleStart) < lowerThreshold
            spindleStart = spindleStart + 1;
            if spindleStart > length(y)
                spindleStart = length(y); % SHOULD NEVER HAPPEN
                break;
            end
        end 
    elseif y(spindleStart) > lowerThreshold
        while y(spindleStart) > lowerThreshold
            spindleStart = spindleStart - 1;
            if spindleStart < 1
                spindleStart = 1;
                break
            end
        end
    end
    
    if y(spindleStop) < lowerThreshold
        while y(spindleStop) < lowerThreshold
            spindleStop = spindleStop - 1;
            if spindleStop < 1
                spindleStop = 1;
                break;
            end
        end 
    elseif y(spindleStop) > lowerThreshold
        while y(spindleStop) > lowerThreshold
            spindleStop = spindleStop + 1;
            if spindleStop > length(y)
                spindleStop = length(y);
                break;
            end
        end
    end
    
    % Check for bound
    if spindleStart < 1
        spindleStart = 1;
    end
    
    if spindleStop > length(y)
        spindleStop = length(y);
    end
    
    if spindleStop <= spindleStart
        error('Impossible!')
    end
end % function


function plot_spindle_num(Results, spindleNum, t, y, lowerThreshold, yToPlot)
    [spindleStart, spindleStop] = get_corrected_spindle_bounds(Results, spindleNum, y, lowerThreshold);
    %[spindleStart, spindleStop] = get_corrected_spindle_bounds(Results, spindleNum, y, lowerThreshold)
    spindleT = t(spindleStart:spindleStop);
    spindleYToPlot = yToPlot(spindleStart:spindleStop);

    plot(spindleT, spindleYToPlot, 'r-')
end % function

