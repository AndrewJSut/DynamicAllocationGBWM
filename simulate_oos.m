function [p_out_of_sample, W_final] = simulate_oos(w, policy, start_ctpm, ctpm, w0, G, T, Nsim)
% OOS Approach (Use optimal Policy)
%
% Returns:
%   p_out_of_sample : Monte Carlo estimate of success probability
%   W_final         : Nsim x 1 vector of final wealths

if nargin < 8
    Nsim = 1e6;
end

nw     = numel(w);
num_pf = size(policy,2) + 0; %#ok<NASGU> % kept for possible extensions

success = 0;
W_final = zeros(Nsim,1);

% choose the first-period action using the nearest grid node to w0
[~, i0] = min(abs(w - w0));
k0 = policy(i0, 1);

for s = 1:Nsim
    % Step 1: draw first grid node from w0 using start_ctpm
    u = rand;
    j = find(start_ctpm(:, k0) >= u, 1, 'first');
    idx = j;                 % current wealth index on the grid

    % Steps 2..T using ctpm and policy
    for t = 2:T
        k = policy(idx, t);  % optimal action at (idx, t)
        u = rand;
        idx = find(ctpm(idx, :, k) >= u, 1, 'first');
    end

    Wealth = w(idx);         % final wealth lives on grid
    W_final(s) = Wealth;
    success = success + (Wealth >= G);
end

p_out_of_sample = success / Nsim;
end
