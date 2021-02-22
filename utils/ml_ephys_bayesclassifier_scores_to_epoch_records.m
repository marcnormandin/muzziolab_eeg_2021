function [record] = ml_ephys_bayesclassifier_scores_to_epoch_records(scores)

    if isempty(scores)
        record = {};
        return
    end

    iCurrent = 1;
    currentState = scores(iCurrent);
    currentStateStart = iCurrent;

    record = {};
    while true
        if scores(iCurrent) ~= currentState
            % End of the current chunk
            currentStateEnd = iCurrent - 1;
            currentStateIndices = currentStateStart:currentStateEnd;

            k = length(record) + 1;
            record(k).state = currentState;
            record(k).epochs = currentStateIndices;
            record(k).numEpochs = length(record(k).epochs);

            currentStateStart = iCurrent;
            currentState = scores(iCurrent);
        else
            iCurrent = iCurrent + 1;
            if iCurrent > length(scores)
                break;
            end
        end
    end
    % Add the remaning
    % End of the current chunk
    currentStateEnd = length(scores);
    currentStateIndices = currentStateStart:currentStateEnd;

    k = length(record) + 1;
    record(k).state = currentState;
    record(k).epochs = currentStateIndices;
    record(k).numEpochs = length(record(k).epochs);
end
