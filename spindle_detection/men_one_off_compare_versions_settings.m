close all
clear all
clc

tmp1 = load('settings_v1.mat');
settings_v1 = tmp1.settings_v1;

tmp2 = load('settings_v2.mat');
settings_v2 = tmp2.settings_v2;

fnl = fieldnames(settings_v1);
for i = 1:length(fnl)
    fn = fnl{i};
    v1 = settings_v1.(fn);
    v2 = settings_v2.(fn);
    
    if isnumeric(v1)
        fprintf('%20.20s: %0.10f\t %0.10f\n', fn, v1, v2);
    else
        fprintf('%20.20s: %0.10s\t %0.10s\n', fn, v1, v2);
    end
end

