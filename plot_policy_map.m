function plot_policy_map(w, policy, num_pf)
% Figure 4: Optimal portfolio strategy at each wealth node and time.

figure; 
imagesc(0:size(policy,2)-1, w, policy - 1); % portfolios 0..14
set(gca,'YDir','normal');  % wealth increases upward
ylim([37 226]);
set(gca, 'YScale', 'log');

% Start from parula, but flip it so low values are light, high are dark
cmap = flipud(parula(num_pf));
colormap(cmap);
caxis([-0.5, num_pf-0.5]);           % centers color bins at 0,1,...,14

% Colorbar with integer tick labels
cb = colorbar;
cb.Ticks = 0:(num_pf-1);             % 0..14
cb.TickLabels = 0:(num_pf-1);

xlabel('Time (years)','FontSize',12);
ylabel('Wealth','FontSize',12);
title('Optimal Policy Map','FontSize',14);
end
