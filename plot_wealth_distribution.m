function plot_wealth_distribution(w, CCDF, T)
% Plot Figure 2: Wealth Distribution Evolution

figure; hold on;
colors = lines(T);

for tau = 1:T
    t_idx = tau + 1;  % t=1..T corresponds to columns 2..T+1
    plot(w, CCDF(:, t_idx), 'LineWidth', 2, 'Color', colors(tau,:));
end

xlabel('W(t)', 'FontSize', 12);
ylabel('1 - Cumulative Probability', 'FontSize', 12);
title('Wealth Distribution Evolution', 'FontSize', 14);

legendStrings = arrayfun(@(x) sprintf('t=%d', x), 1:T, 'UniformOutput', false);
legend(legendStrings, 'Location', 'best');
xlim([0 400]);
end
