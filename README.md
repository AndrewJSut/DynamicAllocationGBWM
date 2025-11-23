# Dynamic Portfolio Allocation in Goals-Based Wealth Management 

### MATLAB Implementation of the Model by Das, Ostrov, Radhakrishnan, & Srivastav (2019)

This repository contains a full MATLAB implementation of the dynamic programming model from:

Das, S.R., Ostrov, D., Radhakrishnan, A., & Srivastav, D. (2019).
Dynamic Portfolio Allocation in Goals-Based Wealth Management.
Working Paper, 2019.

The goal of the project is to reproduce the numerical results of the paper, including:

- Optimal dynamic portfolio strategies

- Probability of achieving a wealth target (in-sample)

- Out-of-sample performance via simulation

- Sensitivity to grid discretization and state-space range

- Reproductions of Figures 2 & 4 (Wealth Distribution Evolution & Optimal Policy Map)

## Key Files:

- Baseline Recreation recreates  Section 4.1 of the paper

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
### `grid.m`

Constructs the log-uniform wealth grid used in the dynamic program.

#### Inputs:

- w0 — initial wealth
- T — number of periods
- nw — number of grid points
- ns — number of standard deviations to span
- vmu, vsi — portfolio means and volatilities
- G — target wealth

#### Functionality:

- Computes the minimum and maximum possible wealth using ±ns standard deviations
- Creates a uniform grid in log-wealth space
- Shifts the entire grid so that log(G) lies exactly between two nodes

#### Outputs:

- w — grid of wealth values
- lw — grid of log-wealth values

### `build_transitions.m`

Builds the transition probability matrices for each portfolio.

Implements Equation (6) from Das et al. (2019):

$\tilde{p}(W_j \mid W_i, \mu_k) = 
\phi\left( \frac{\ln(W_j/W_i) - (\mu_k - \sigma_k^2/2)}{\sigma_k} \right)$

#### Produces:

- P(i,j,k) — transition matrix

- ctpm(i,:,k) — cumulative transition probabilities

- start_ctpm(:,k) — transitions from the non-grid initial wealth w0

Used by both DP and out-of-sample simulation.

### `solve_dp.m`

Solves the dynamic programming problem by backward induction.

#### Inputs:

- w — wealth grid
- G — target wealth
- T — number of periods
- P — transition probability tensor, with P(i,j,k) = p(W_j(t+1) | W_i(t), portfolio k)

#### Functionality:

- Sets up the terminal value function at time T as an indicator of reaching the target:
  - V_T(i) = 1 if w(i) ≥ G, else 0
- Applies the Bellman recursion backwards in time:
  - For each time t = T−1,…,0 and each wealth node i:
    - Computes the expected continuation value for each portfolio k:
      - EV(k) = Σ_j P(i,j,k) · V_{t+1}(j)
    - Chooses the portfolio k that maximizes EV(k)
- Stores both the value function and the optimal policy (portfolio index) at each (i,t)

#### Outputs:

- V — value function array of size (nw × (T+1)), where V(i,t_index) is the probability of success starting from wealth node i at that time
- policy — optimal portfolio indices of size (nw × T), policy(i,t) gives the optimal portfolio at wealth node i and time t


### `compute_success_probabilities.m`

Computes the probability of reaching the target from the true starting wealth w0.

#### Inputs:

- w — wealth grid
- w0 — initial wealth
- V — value function from the DP

#### Functionality:

- Finds the grid node closest to w0 and records the “raw” (nearest-node) probability:
  - ProbRaw = V(i0, 1)
- Identifies the two grid nodes just below and above w0
- Linearly interpolates the value function between these two nodes to estimate the probability at w0:
  - ProbInterp = V(w0) via linear interpolation in w

#### Outputs:

- ProbRaw — in-sample success probability using nearest wealth grid node
- ProbInterp — in-sample success probability using linear interpolation between nodes (recommended)


### `simulate_oos.m`

Runs an out-of-sample Monte Carlo simulation of wealth evolution under the optimal policy.

#### Inputs:

- w — wealth grid
- policy — optimal portfolio indices from the DP (nw × T)
- start_ctpm — cumulative transition probabilities for the first step from w0 (size nw × num_pf)
- ctpm — cumulative transition probabilities for subsequent steps (size nw × nw × num_pf)
- w0 — initial wealth
- G — target wealth
- T — time horizon
- Nsim — number of simulation paths

#### Functionality:

- Uses the nearest wealth grid node to w0 to determine the first-period portfolio:
  - k0 = policy(i0, 1)
- For each simulation path:
  - Draws a first wealth node index using `start_ctpm(:,k0)` (inverse transform sampling)
  - For each subsequent year t = 2,…,T:
    - Uses the current wealth node index and the optimal policy to choose portfolio k = policy(idx, t)
    - Draws the next wealth node index using `ctpm(idx,:,k)`
  - Converts the final node index back to a wealth level using the wealth grid w
  - Records whether the final wealth exceeds the target G
- Estimates the out-of-sample success probability as the fraction of successful paths

#### Outputs:

- p_oos — out-of-sample probability of success
- W_final — vector of final simulated wealth values of length Nsim


### `compute_wealth_ccdf.m`

Computes the complementary cumulative distribution function (CCDF) of wealth over time under the optimal policy (used for Figure 2).

#### Inputs:

- w — wealth grid
- T — time horizon
- P — transition probability tensor P(i,j,k)
- policy — optimal policy (nw × T)
- w0 — initial wealth

#### Functionality:

- Initializes the distribution at time 0 as a point mass at the wealth node closest to w0
- For each time step t = 1,…,T:
  - Propagates the wealth distribution forward using the optimal policy and transition probabilities:
    - p_{t+1}(j) = Σ_i p_t(i) · P(i,j, policy(i,t))
- For each time t, converts the probability mass function into a CCDF:
  - CCDF(w_j, t) = P(W_t ≥ w_j) = 1 − CDF(w_j, t)

#### Outputs:

- CCDF — array of size (nw × (T+1)), where CCDF(i,t_index) is the probability that wealth at that time is at least w(i)


### `plot_wealth_distribution.m`

Plots the evolution of the wealth distribution over time as complementary cumulative distribution functions (CCDFs), reproducing Figure 2 from the paper.

#### Inputs:

- w — wealth grid
- CCDF — CCDF matrix from `compute_wealth_ccdf.m` (nw × (T+1))
- T — time horizon

#### Functionality:

- For each time t = 1,…,T:
  - Plots the curve `w` vs. `CCDF(:, t+1)` (since column 1 corresponds to t = 0)
- Uses a distinct color per time step
- Labels axes as wealth vs. 1 − cumulative probability
- Adds a legend labeling each curve by time t
- Restricts the x-axis to a relevant wealth range (e.g., [0, 400]) to match the paper

#### Outputs:

- A figure showing the evolution of the wealth distribution under the optimal dynamic strategy


### `plot_policy_map.m`

Plots the optimal portfolio choice as a function of time and wealth, reproducing Figure 4 from the paper.

#### Inputs:

- w — wealth grid
- policy — optimal policy (nw × T)
- num_pf — number of efficient portfolios

#### Functionality:

- Displays a heatmap with:
  - x-axis: time (0, 1, …, T−1)
  - y-axis: wealth levels on the grid w
  - color: portfolio index (often shifted to 0,…,num_pf−1 to match the paper)
- Flips the y-axis so that wealth increases upward
- Restricts the wealth axis to the range where the policy actually varies (e.g., [37, 226])
- Uses a log scale on the wealth axis to reflect the lognormal nature of wealth
- Applies a colormap (e.g., flipped parula) so that:
  - Light colors correspond to conservative portfolios
  - Dark colors correspond to aggressive portfolios
- Adds a colorbar with integer tick labels for the portfolio indices

#### Outputs:

- A figure showing the optimal policy map over wealth and time, visually similar to Figure 4 in the paper


## Numerical Experiments

### 1. Effect of Wealth Grid Resolution (`n_w`)

#### Description:

This experiment varies the number of wealth grid points `n_w` while keeping all other inputs (including `ns`) fixed at the reference values. The goal is to understand how discretization of the wealth space affects:

- In-sample probabilities (from the DP)
- Out-of-sample probabilities (from simulation)
- Computation time

Typical values tested include, for example: `n_w ∈ {100, 200, 327, 500, 800, 1200}`.

#### Metrics recorded:

For each `n_w`, the following are computed:

- `ProbRaw` — in-sample probability using the nearest wealth node to w0
- `ProbInterp` — in-sample probability using linear interpolation at w0
- `ProbOOS` — out-of-sample probability from Monte Carlo
- `DP_Time` — time to solve the DP (Bellman recursion)
- `OOS_Time` — time to run the Monte Carlo simulation

#### Findings (qualitative):

- Coarse grids (small `n_w`) can bias the in-sample probability, especially `ProbRaw`.
- As `n_w` increases, `ProbInterp` and `ProbOOS` converge to a stable value.
- Beyond a moderate `n_w` (around 200–350), further refinement yields very small accuracy gains but increases `DP_Time` significantly.
- `DP_Time` grows roughly linearly with `n_w`, while `OOS_Time` grows more modestly.

---

### 2. Effect of Standard Deviation Range (`n_s`)

#### Description:

This experiment varies `n_s`, the number of standard deviations of terminal wealth that the grid spans, while keeping the number of grid points `n_w` fixed. The wealth grid is recomputed for each `n_s` using the `grid.m` function.

Typical values tested include: `n_s ∈ {1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0}`.

#### Metrics recorded:

For each `n_s`, the following are computed:

- `ProbRaw` — in-sample nearest-node probability
- `ProbInterp` — in-sample interpolated probability
- `ProbOOS` — out-of-sample probability from Monte Carlo
- `DP_Time` — time to solve the DP
- `OOS_Time` — time to run the simulation

#### Findings (qualitative):

- Very small `n_s` (e.g., `n_s = 1`) leads to a wealth grid that is too narrow and truncates the true distribution. This can significantly distort the success probabilities.
- For `n_s` in a reasonable range (roughly `2.5 ≤ n_s ≤ 4`), in-sample and out-of-sample probabilities become stable and consistent.
- The choice `n_s = 3`, as used in the paper, is a good default: it balances coverage of extreme outcomes with computational efficiency.
- Computation times do not change dramatically with `n_s`, since the number of grid points `n_w` is held fixed; only the wealth range changes.

---

### 3. In-Sample vs Out-of-Sample Comparison

#### Description:

For each combination of `n_w` and `n_s` tested above, the experiment compares:

- In-sample success probability (from the DP value function at w0, typically using interpolation)
- Out-of-sample success probability (from Monte Carlo simulation under the optimal policy)

#### Findings (qualitative):

- When `n_w` is sufficiently large and `n_s` is not too small, the in-sample interpolated probability (`ProbInterp`) and the out-of-sample probability (`ProbOOS`) match very closely (to within ~0.001–0.002).
- This close agreement indicates:
  - The DP discretization is accurate.
  - The optimal policy generalizes well and is not overfitting to the discretized state space.
- Discrepancies between in-sample and out-of-sample probabilities mostly appear only when the grid is too coarse (`n_w` small) or the range is too narrow (`n_s` small).

---

### 4. Generated Figures

#### Wealth Distribution Evolution (Figure 2)

Using `compute_wealth_ccdf.m` and `plot_wealth_distribution.m`, the code produces a figure showing:

- The complementary cumulative distribution function (CCDF) of wealth at each time t = 1,…,T.
- Each curve plots `P(W_t ≥ w)` against wealth `w` under the optimal dynamic policy.

This reproduces the qualitative behavior of Figure 2 in the paper, showing how the distribution of wealth shifts and spreads over time.

#### Optimal Policy Map (Figure 4)

Using `plot_policy_map.m`, the code produces a heatmap showing:

- Time on the x-axis
- Wealth on the y-axis (often on a log scale)
- Optimal portfolio index as color

This matches the structure of Figure 4 in the paper:

- More aggressive portfolios at low wealth and early times
- More conservative portfolios when wealth is already high or remaining time is short


