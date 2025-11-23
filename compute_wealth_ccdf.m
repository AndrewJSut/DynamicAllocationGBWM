function CCDF = compute_wealth_ccdf(w, T, P, policy, w0)
% Build data for Figure 2 (wealth distribution evolution)
% CCDF(:,t_index) gives P(W(t-1) >= w) for t_index = 2..T+1

nw = numel(w);
p = zeros(nw, T+1);

% Start with mass at the node closest to w0
[~, i0] = min(abs(w - w0));
p(i0,1) = 1;

for t = 1:T
    p_next = zeros(nw,1);

    for i = 1:nw
        k = policy(i,t);                 % optimal portfolio at node i, time t
        p_next = p_next + p(i,t) * squeeze(P(i,:,k))';
    end

    p(:,t+1) = p_next;
end

CCDF = zeros(nw, T+1);

for t = 1:T+1
    CDF = cumsum(p(:,t));    % cumulative sum over wealth
    CCDF(:,t) = 1 - CDF;     % probability of having AT LEAST w
end

end
