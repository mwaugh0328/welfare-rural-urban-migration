function theta = calibrate_model(cal_params,specs,flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cal_params should have the following order
% 1: standard Deviation of shocks (todo, veryfy its stand dev or variance)
% 2: Pareto shape parameter for permenant ability in the urban area.
% 3: Urban TFP
% 4: Persistance of transitory shocks
% 5: Ubar, disutility of being in urban area
% 6: Getting experince 
% 7: Losing it. (TO DO, veryify the 6 and 7 is correct rel. paper)
% 8: Gamma parameter in shock process
% 9: Logit shocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[yyy] = compute_outcomes(cal_params, specs,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aggregate Moments....
aggregate_moments = [1.89, 0.61, 0.625, 0.47];

%%% Description:
% Wage gap
% The rural share
% The urban variance... note that this is position number 3 (see below)
% Fraction with no liquid assets

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment Moments...
%experiment_moments = [0.22, 0.092, 0.30];

%control_moments = [0.36, 0.25, 0.16, 0.10,  0.19];

%experiment_hybrid_v2 = [0.36, 0.22, 0.092, 0.30, 0.10, 0.25/0.36, 0.40];

%experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.10, 0.40];
%experiment_hybrid = [0.36, 0.22/2, 0.092/2, 0.30, 0.10, 0.40];
experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.15, 0.40];

% The experiment hybrid is a combination of conrol and experiment...
% seasonal migration in control
% increase in r1 (22 percent)
% increase in r2 (9.2 percent)
% LATE estiamte
% OLS estimate
% Standard deviation of consumption growth. See line 400 in
% ``compute_outcomes.``

% Note there is currently an inconsistency between the numbers in the table
% and what I have here. 0.40 corresponds with a variance of 0.16, note 0.18
% which is what is in my slides. To edit: onece we have a consistent
% number, we should change code so we work in only variances or stds.

% Also note how this is working, in ``compute_outcomes'' we do not include
% measurment error in the out put moments. The idea is that since it is
% additive, we only need to check ex-post what the measurment error is.
% This simplifies the calibration since we are calibrating 2 less
% parameters. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targets = [aggregate_moments, experiment_hybrid];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g_theta = (targets'-yyy')./targets';

yyy([3,end]) = [];
targets([3,end]) = [];

g_theta = zeros(length(targets),1);

%g_theta(1) = log(targets(1)'./yyy(1)');

g_theta(1:end) = (targets(1:end)')-(yyy(1:end)');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is how the variances are being treated. 
% const_var = false(length(g_theta),1);
% 
% % This is just saying if the variances are above targets, pennelize. If
% % not...then count as zero penelty. 
% const_var(3) = g_theta(3) > 0;
% const_var(end) = g_theta(end) > 0;
% 
% g_theta(const_var) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

W = eye(length(g_theta));

if flag == 1

theta = g_theta'*W*g_theta;

elseif flag == 2
    
theta = yyy;

end