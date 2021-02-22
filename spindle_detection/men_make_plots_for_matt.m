close all

fns = {'AT_11_Y_C_P.edf', 'AT_14_Y_C_P.edf', 'AT_18rr_Y_C_P.edf', 'MT_5_Y_C_P.edf'};
outputFolder = fullfile(pwd, 'additional_data_plots_20200221');
for iFile = 1:length(fns)
    h(iFile) = men_edf_plot(fns{iFile});
    s = split(fns{iFile},'.');
    
    
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    %savefig( h(iFile), fullfile(outputFolder, sprintf('%s.fig', s{1})) );
    saveas( h(iFile), fullfile(outputFolder, sprintf('%s.png', s{1})), 'png' );
end
