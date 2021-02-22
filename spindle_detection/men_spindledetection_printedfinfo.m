% Requires edfread from the SpindleDetection program
edfFiles = dir( fullfile(pwd, '*.edf') );
for fn = 1:length(edfFiles)
    filename = edfFiles(fn).name;
    [hdr, record]= edfread([filename]);
    disp(filename)
    disp(size(record))
    fs=hdr.samples(1)/hdr.duration
    hrs = size(record,2) ./ fs ./ 3600
end
