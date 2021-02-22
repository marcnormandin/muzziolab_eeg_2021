function men_edf_plot( fn )
%fn = 'AT_97_O_C_R.edf';

[record, hdr] = men_edf_read( fn );
 
fs=hdr.samplingrate;

numSamples = size(record,2);
tSecs = 0:(numSamples-1);
tSecs = tSecs ./ fs;
tHrs = tSecs ./ 3600;

figure
ax(1) = subplot(3,1,1);
plot(tHrs, record(1,:))
title(sprintf('%s', fn), 'Interpreter', 'none')
ylabel('EEG 1')
ax(2) = subplot(3,1,2);
plot(tHrs, record(2,:))
ylabel('EEG 2')
ax(3) = subplot(3,1,3);
plot(tHrs, record(3,:))
ylabel('EMG');
xlabel('Time, t [hours]')

linkaxes(ax, 'xy')
axis tight
