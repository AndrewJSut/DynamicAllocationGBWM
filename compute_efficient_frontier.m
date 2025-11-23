function [W, vmu, vsi, mu_vec] = compute_efficient_frontier(m, Sigma, num_pf, doPlot)
% Compute the Efficient Frontier (as per Sec 2.2)
% Returns:
%   W    : num_pf x n weights of index funds
%   vmu  : num_pf x 1 vector of portfolio mean returns
%   vsi  : num_pf x 1 vector of portfolio standard deviations
%   mu_vec : num_pf x 1 target means along the frontier

if nargin < 4
    doPlot = false;
end

n = numel(m); % Number of index funds
o = ones(n,1);
Sigma_inv = Sigma \ eye(n);

% Define constants
k = m' * Sigma_inv * o;
l = m' * Sigma_inv * m;
p = o' * Sigma_inv * o;

% Define Vectors
g = (l * (Sigma_inv * o) - k * (Sigma_inv * m)) / (l*p - k^2);
h = (p * (Sigma_inv * m) - k * (Sigma_inv * o)) / (l*p - k^2);

% Define constants for hyperbola
a = h' * Sigma * h;
b = 2 * (g' * Sigma * h);
c = g' * Sigma * g;

if doPlot
    mu_plot = linspace(0.04, 0.1, 200);     % or [mu_min, mu_max]
    sigma_plot = sqrt(a*mu_plot.^2 + b*mu_plot + c);

    figure;
    plot(sigma_plot, mu_plot, 'LineWidth', 2);
    xlabel('\sigma\_plot'); ylabel('\mu\_plot');
    title('Efficient Frontier');
end

mu_min = k / p;
mu_max = max(m);
mu_vec = linspace(mu_min, mu_max, num_pf);

% Get weights of index fund portfolios
W = zeros(length(mu_vec), length(g));
for i = 1:length(mu_vec)
    mu = mu_vec(i);
    W(i,:) = (g + mu * h)';     
end

% Compute vmu and vsi:
% vmu: 15x1 vector of portfolio mean returns
vmu = W * m;   

% vsi: 15×1 vector of portfolio standard deviations
vsi = sqrt(sum((W * Sigma) .* W, 2));

end