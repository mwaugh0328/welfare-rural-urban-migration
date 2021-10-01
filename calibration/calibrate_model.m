function theta = calibrate_model(cal_params,moments,specs,flag)
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
% 10: Seasonal migration cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[yyy] = compute_outcomes(cal_params, specs,0);

% Note there is currently an inconsistency between the numbers in the table
% and what I have here. 0.40 corresponds with a variance of 0.16, note 0.18
% which is what is in my slides. To edit: onece we have a consistent
% number, we should change code so we work in only variances or stds.

% Also note how this is working, in ``compute_outcomes'' we do not include
% measurment error in the out put moments. The idea is that since it is
% additive, we only need to check ex-post what the measurment error is.
% This simplifies the calibration since we are calibrating 2 less
% parameters. 

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g_theta = (moments'-yyy')./moments';

yyy([3,end]) = []; % this takes out the varince moments per desciption above
moments([3,end]) = [];

g_theta = zeros(length(moments),1);

%g_theta(1) = log(moments(1)'./yyy(1)');

g_theta(1:end) = (moments(1:end)')-(yyy(1:end)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

W = eye(length(g_theta));

if flag == 1

theta = g_theta'*W*g_theta;

elseif flag == 2
    
theta = yyy;

end