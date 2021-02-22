function [bands] = ml_ephys_load_bands_info()
    bands = struct('name', {}, 'f_low', [], 'f_high', []);
    k = length(bands)+1;
    bands(k).name = 'delta';
    bands(k).f_low = 0.25;
    bands(k).f_high = 4.0;
    bands(k).subbands = linspace(bands(k).f_low, bands(k).f_high, 4);

    k = length(bands)+1;
    bands(k).name = 'theta';
    bands(k).f_low = 4.0;
    bands(k).f_high = 10.0;
    bands(k).subbands = [];

    k = length(bands)+1;
    bands(k).name = 'sigma';
    bands(k).f_low = 10.0;
    bands(k).f_high = 15.0;
    bands(k).subbands = [];
    
    k = length(bands)+1;
    bands(k).name = 'beta';
    bands(k).f_low = 15.0;
    bands(k).f_high = 30.0;
    bands(k).subbands = [];

    k = length(bands)+1;
    bands(k).name = 'gamma';
    bands(k).f_low = 30.0;
    bands(k).f_high = 100.0;
    bands(k).subbands = [];
end % function