function [prob_hit_goal_raw, prob_hit_goal_inter] = compute_success_probabilities(w, w0, V)
% Compute in-sample probability of reaching goal:
%   - raw: using nearest wealth node
%   - inter: using linear interpolation between grid nodes

% Raw (nearest-node) probability
[~, i0] = min(abs(w - w0)); % Find the node closest to w0
prob_hit_goal_raw = V(i0, 1); % No interpolation

% Interpolated probability at initial wealth w0
iL = find(w <= w0, 1, 'last'); % Find the largest node still less than w0
iU = iL + 1;                   % Get the next node (greater than w0)

wL = w(iL);  
wU = w(iU); % Get the node value
VL = V(iL,1); % Lower prob
VU = V(iU,1); % Higher Prob

alpha = (w0 - wL) / (wU - wL);

prob_hit_goal_inter = VL + alpha * (VU - VL); % Linear interpolation
end
