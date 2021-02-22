function [badi] = find_badmice_indices_in_dataset(dataset)
    badmice = {'AEG_2_O_C_P', 'AEG_98_Y_D_R', 'MT_8_Y_C_R'};
    badi = [];
    for iMouse = 1:length(dataset)
        for iBad = 1:length(badmice)
            if strcmp(dataset(iMouse).fullname, badmice{iBad})
                badi(end+1) = iMouse;
                fprintf('Found bad mouse: %s\n', dataset(iMouse).fullname);
            end
        end
    end
end % function
