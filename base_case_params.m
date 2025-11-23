function params = base_case_params()
% Define the "base case" as described in paper:

% Environment:
params.w0   = 100;     % Initial wealth
params.G    = 200;     % Goal wealth
params.T    = 10;      % Time horizon (10 years)

% Portfolios:
params.num_pf = 15;    % Number of MV efficient portfolios
params.rho_g  = 3.0;   % Grid point density per min annual std in pf performance

% Empirical Index Fund metrics

% for: U.S. Bonds | International Stocks | U.S. Stocks
params.m = [0.0493 0.0770 0.0886]'; % Index funds mean return

params.Sigma = [ 0.0017  -0.0017  -0.0021;
                -0.0017   0.0396   0.0309;
                -0.0021   0.03086  0.0392]; % Index funds covariance matrix
end