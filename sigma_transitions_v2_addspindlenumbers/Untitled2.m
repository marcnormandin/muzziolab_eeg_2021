close all

X = sigmaMatch;
x = mean(X, 1, 'omitnan');

figure
plot(sigmaMatch_times, X, 'k-')
hold on
plot(sigmaMatch_times, x, 'r-', 'linewidth', 4)
grid on


for i = 1:size(X,1)
    %if any(~isnan(X(i,:)))
        figure
        plot(sigmaMatch_times(1:settings.sigmaMatch_t_before_and_after+1), X(i,1:settings.sigmaMatch_t_before_and_after+1), 'g-', 'linewidth', 4)
        hold on
        plot(sigmaMatch_times(settings.sigmaMatch_t_before_and_after+2:end), X(i,settings.sigmaMatch_t_before_and_after+2:end), 'b-', 'linewidth', 4)
        %plot(sigmaMatch_times, x, 'k-', 'linewidth', 4)
        grid on
        title(sprintf('Transition: %d', i));
        xlabel('Time, t [s]')
    %end
end