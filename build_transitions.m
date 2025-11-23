function [P, ctpm, start_ctpm] = build_transitions(w, w0, vmu, vsi)
% Dynamic Programming
%
% Transition Probabilities:
%
% P(i,j,k)   = p( Wealth_j(t+1) | Wealth_i(t), portfolio k )
% ctpm       = cumulative transition probabilities
% start_ctpm = cumulative transitions starting from w0 (not necessarily on grid)

nw     = numel(w);
num_pf = numel(vmu);

P        = zeros(nw, nw, num_pf); % P(i,j,k) = p( Wealth_j(t+1) | Wealth_i(t), portfolio k )
ctpm     = zeros(nw, nw, num_pf);      % cumulative transition probabilities
start_ctpm = zeros(nw, num_pf);        % cumulative transitions starting from w0

for k = 1:num_pf
    mu_k = vmu(k);
    si_k = vsi(k);
    drift_k = mu_k - 0.5 * si_k^2; 

    % transitions from each wealth grid node
    for i = 1:nw
        Wi = w(i);
        z = (log(w ./ Wi) - drift_k) ./ si_k; % EQN 6 from paper
        p = normpdf(z);
        p = p ./ sum(p);              % normalize to sum to 1
        P(i,:,k)    = p;              % store transition probabilities
        ctpm(i,:,k) = cumsum(p);      % store cumulative probabilities
    end

    % transitions starting from actual initial wealth w0 (not on the grid)
    z0 = (log(w ./ w0) - drift_k) ./ si_k;
    p0 = normpdf(z0);
    p0 = p0 ./ sum(p0);
    start_ctpm(:,k) = cumsum(p0);
end
end
