# Dynamic Portfolio Allocation in Goals-Based Wealth Management 

### MATLAB Implementation of the Model by Das, Ostrov, Radhakrishnan, & Srivastav (2019)

This repository contains a full MATLAB implementation of the dynamic programming model from:

Das, S.R., Ostrov, D., Radhakrishnan, A., & Srivastav, D. (2019).
Dynamic Portfolio Allocation in Goals-Based Wealth Management.
Working Paper, 2019.

The goal of the project is to reproduce the numerical results of the paper, including:

Optimal dynamic portfolio strategies

Probability of achieving a wealth target (in-sample)

Out-of-sample performance via simulation

Sensitivity to grid discretization and state-space range

Reproductions of Figures 2 and 4

## Repo structure:
.
├── src/
│   ├── grid.m                          % Builds log-wealth grid
│   ├── build_transitions.m             % Transition probability matrices (DP)
│   ├── solve_dp.m                      % Backward DP/Bellman recursion
│   ├── compute_success_probabilities.m % In-sample success probabilities
│   ├── simulate_oos.m                  % Out-of-sample Monte-Carlo simulation
│   ├── plot_policy.m                   % Figure 4: Optimal policy heatmap
│   └── plot_wealth_distribution.m      % Figure 2: CCDF evolution of wealth
│
├── scripts/
│   ├── run_reference_case.mlx          % Reproduces core results from paper
│   ├── experiment_vary_nw.mlx          % Test effect of grid resolution
│   └── experiment_vary_ns.mlx          % Test effect of grid range (std dev)
│
├── results/
│   ├── table_nw.csv                    % Numerical results (varying n_w)
│   ├── table_ns.csv                    % Numerical results (varying n_s)
│   └── figures/                        % Figures 2, 4, and additional plots
│
├── README.md

## Model Overview:
The model solves a finite-horizon dynamic stochastic control problem:

- Investor aims to reach a wealth target G within T years
- At each year, they choose one of m portfolios lying on the mean-variance efficient frontier
- Wealth evolves lognormally based on portfolio mean return μ and volatility σ
- Decisions are made on a discretized wealth grid, uniform in log-space
- Backward induction solves for the optimal policy
- A forward simulation evaluates out-of-sample performance
This implementation faithfully follows equations and methodology from
Das et al. (2019).

## Key MATLAB Functions
`grid.m`

Constructs the log-uniform wealth grid used in the dynamic program.

Inputs:

w0 — initial wealth
T — number of periods
nw — number of grid points
ns — number of standard deviations to span
vmu, vsi — portfolio means and volatilities
G — target wealth

Functionality:

- Computes the minimum and maximum possible wealth using ±ns standard deviations
- Creates a uniform grid in log-wealth space
- Shifts the entire grid so that log(G) lies exactly between two nodes

Outputs:

w — grid of wealth values
lw — grid of log-wealth values

`build_transitions.m`

Builds the transition probability matrices for each portfolio.

Implements Equation (6) from Das et al. (2019):

\[
\tilde{p}(W_j \mid W_i, \mu_k)
= 
\phi\!\left(
\frac{\ln(W_j / W_i) - \left(\mu_k - \frac{\sigma_k^2}{2}\right)}
{\sigma_k}
\right)
\]


Produces:

- P(i,j,k) — transition matrix

- ctpm(i,:,k) — cumulative transition probabilities

- start_ctpm(:,k) — transitions from the non-grid initial wealth w0

Used by both DP and out-of-sample simulation.

