% This script was created to convert scores from excel format to mat format
% since we handscored some of the excel.

close all
clear all
clc

settings = ml_sleepstudy_settings_load();
mouseTable = ml_sleepstudy_mousetable_load(settings)
numMice = size(mouseTable,1);

outputFolder = fullfile(settings.parentAnalysisFolder, 'new_scores');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end


% Intentionally disabled DANGEROUS
% for iMouse = 1:size(mouseTable,1)
%     mouse = mouseTable(iMouse,:);
% 
%     x.score = reshape(mouse.scores{1}, numel(mouse.scores{1}), 1);
%     
%     % We have to subtract 1 from the scores because the excel has 1,2,3 and
%     % the mat files should have 0,1,2.
%     x.score = x.score - 1;
%     
%     v = genvarname(mouse.codename{1});
%     eval([v '= x;']);
%     outputFolder = mouse.filePath{1};
%     fn = fullfile(outputFolder, sprintf('%s_scores.mat', mouse.codename{1}))
%     save(fn, v);
% end
