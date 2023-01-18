function theta = calibrate_model_appendix(cal_params,moments,specs, seed, R, beta, min_consumption, perm_movecost, vguess, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cal_params should have the following order
% 1: standard Deviation of shocks 
% 2: Pareto shape parameter for permenant ability in the urban area.
% 3: Urban TFP
% 4: Persistance of transitory shocks
% 5: Ubar, disutility of being in urban area
% 6: Getting experince 
% 7: Losing it 
% 8: Gamma parameter in shock process
% 9: Logit shocks
% 10: Seasonal migration cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model_moments = compute_outcomes_appendix(cal_params, specs, seed, R, beta, min_consumption, perm_movecost, vguess, 0);

% Also note how this is working, in ``compute_outcomes'' we do not include
% measurment error in the out put moments. The idea is that since it is
% additive, we only need to check ex-post what the measurment error is.
% This simplifies the calibration since we are calibrating 2 less
% parameters. 

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g_theta = (moments'-yyy')./moments';

if flag == 1
    
    model_moments(:, [3,end]) = []; % this takes out the varince moments per desciption above

    mean_model_moments = mean(model_moments,1);
    
    moments([3,end]) = [];

    g_theta = zeros(length(moments),1);

%g_theta(1) = log(moments(1)'./yyy(1)');

    g_theta(1:end) = (moments(1:end)')-(mean_model_moments(1:end)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    W = eye(length(g_theta));

    theta = g_theta'*W*g_theta;

elseif flag == 2
    
    model_moments(:, [3,end]) = []; % this takes out the varince moments per desciption above

    mean_model_moments = mean(model_moments,1);
    
    theta = mean_model_moments;

elseif flag == 3
    
    mean_model_moments = mean(model_moments,1);
    
    theta = mean_model_moments;

end