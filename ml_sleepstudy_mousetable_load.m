function mouseTable = ml_sleepstudy_mousetable_load(settings)
% This load the table of mice data that will be used for the sleep study.
% This allows for us to change the dataset used for all of the code by
% simply changing this function.

mouseTable = ml_ephys_mice_table_load( settings.datasetFolder );

mouseTable(ismember(mouseTable.codename, settings.badMice), :) = [];

if settings.use_fixed_scores == 1
   fprintf('Fixing the Bayesian scores... ');
   numMice = size(mouseTable,1);
   
   for iMouse = 1:numMice
      mouse = mouseTable(iMouse,:);
      
      codename = mouse.codename{1};
%       if ismember(codename, {'AT_99_Y_D_R', 'AT_15_Y_C_R'})
%           mouse.eegSelected = 1;
%       end
      
      scores1 = mouse.scores{1}; % since cell
      
      % Can only fix scores if the mouse has them.
      if ~isempty(scores1)
          [scores2, ~] = ml_ephys_bayesclassifier_scores_fix(scores1); 
          iscore = find(ismember(mouseTable.Properties.VariableNames, 'scores'));
          if length(iscore) ~= 1
              error('Matched more than one variable name! Only one should contain scores.');
          end
          mouse.scores  = {scores2};
          mouseTable(iMouse, :) = mouse;
      end
   end
   fprintf('done!\n');
end

end % function
