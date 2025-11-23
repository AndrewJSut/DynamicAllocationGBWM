function [V, policy] = solve_dp(w, G, T, P)
% Solve the dynamic programming problem given transition probabilities P.
%
% Value function:
%   V(i,t) = value at wealth node i and time index t (t = 1..T+1)
% policy(i,t) = optimal portfolio index at (i,t)

[nw, ~, num_pf] = size(P);

% Value function:
V = zeros(nw, T+1);         % V(: , time index)
policy = zeros(nw, T);      % store optimal portfolio index at each (i,t)

% Terminal condition at t = T  -> column index T+1
V(:, T+1) = double(w >= G);

% Bellman Recursion
for t = T:-1:1        % Start at T and go to 1
    V_next = V(:, t+1);     

    for i = 1:nw
        EV = zeros(num_pf,1);

        % Expected value under each portfolio
        for k = 1:num_pf
            EV(k) = P(i,:,k) * V_next;
        end

        [V(i,t), policy(i,t)] = max(EV); % Choose best pf
    end
end
end
