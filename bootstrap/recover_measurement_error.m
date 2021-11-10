function mesurment_error = recover_measurement_error(cal_params, moments, specs, seed, vguess)
% to run
% need to have addpath('../utils')
% and addpath('../calibration')
%
% load('..\calibration\calibrated_baseline.mat')
% load('..\calibration\calibrated_valuefunction_guess.mat')
% recover_measurement_error(x1,[],[], [], vguess)
%
% to run on bootstrap, just pass point estimates in place of x1


model_moments = calibrate_model(cal_params, moments, specs, seed, vguess, 3);

var_log_wages_data = 0.56; % Table 2 ~ page 17
var_log_cons_growth_data = 0.19; % Table 2 ~ Page 17

var_log_wages_model = model_moments(3).^2;
% model does everything in standard deviation, see line ~324 in
% compute_outcomes.m

var_log_cons_growth_model = model_moments(11).^2;
% model does everything in standard deviation, see line ~324 in
% compute_outcomes.m

urban_wage_me = max(var_log_wages_data - var_log_wages_model, 0) ; 
%it's possible there is too much, me = 0 in that case. Data does not happen, 
% bootstrap it might.
                                                                   
rural_cons_me = max(var_log_cons_growth_data - var_log_cons_growth_model, 0) ;

mesurment_error = [urban_wage_me, rural_cons_me];