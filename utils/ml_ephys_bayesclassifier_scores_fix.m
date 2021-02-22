function [scores, problems] = ml_ephys_bayesclassifier_scores_fix(scores)
    record = ml_ephys_bayesclassifier_scores_to_epoch_records(scores);

    problems = find_problems(scores, record, 1) | find_problems(scores, record, 2);
    recp = ml_ephys_util_find_groups(problems, 1);

    for i = 1:length(recp)
       r = recp(i);
       n = r.numEpochs;
       nleft = ceil(n/2);
       nright = n - nleft;

       ileft = min(r.epochs);
       iright = max(r.epochs);

       % Should be impossible to fail unless the entire data is problematic!
       if ileft-1 >= 1
           vleft = scores(ileft-1);
       else
           vleft = scores(iright+1);
       end

       if iright+1 <= length(scores)
           vright = scores(iright+1);
       else
           vright = scores(ileft-1);
       end

       for j = 1:nleft
           scores(ileft+j-1) = vleft;
       end

       for j = 1:nright
           scores(ileft+nleft-1+j) = vright;
       end
    end
end % function





function [problems] = find_problems(scores, r, epochSize)
    problems = zeros(size(scores));
    for iState = 1:3
        istates = find([r.state] == iState);
        rstate = r(istates);

        irstate = rstate(find([rstate.numEpochs]==epochSize));

        for j = 1:length(irstate)
           problems(irstate(j).epochs) = 1;
        end
    end
end