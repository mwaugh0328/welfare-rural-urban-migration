clc
clear

table_order = [4,5,9,10,6,7,8,1,2];

addpath('../utils')
addpath('../calibration')

load('../calibration/calibrated_valuefunction_guess.mat')

disp('-----------------------------------------------------------------------------------------------------')
disp(datetime(now,'ConvertFrom','datenum'))
disp(' ')
ver
disp('-----------------------------------------------------------------------------------------------------')
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these are the baseline moments:
aggregate_moments = [1.89, 0.61, 0.625, 0.47];

%%% Description:
% (1) Wage gap
% (2) The rural share
% (3) The urban standard deviation
% (4) Fraction with no liquid assets

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment Moments...

experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.10, 0.25 ./ 0.36, 0.40];
% (6) seasonal migration in control
% (7) increase in r1 (22 percent)
% (8) increase in r2 (9.2 percent)
% (9) LATE estiamte
% (10) OLS estimate
% (11) Control repeat migration rate 
% (13) Standard deviation of consumption growth. 

moments = [aggregate_moments, experiment_hybrid];

load('../calibration/calibrated_baseline.mat')

R = [];
beta = [];
min_consumption = [];
perm_movecost = [];

tic, obj_baseline = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);, toc
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Baseline Model')
disp([obj_baseline])
disp(round(model_moments(table_order)',2))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_fix_rho.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];

obj = calibrate_fix_rho(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_fix_rho(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('rho = 0, recalibrate')
disp('Objective function: current, as calibrated, baseline') 
disp([obj, obj_new, obj_baseline])
disp('Moments') 
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_fix_ubar.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];


obj = calibrate_fix_ubar(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_fix_ubar(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('ubar = 1, recalibrate')
disp('Objective function: current, as calibrated, baseline') 
disp([obj, obj_new, obj_baseline])
disp('Moments') 
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('appendix_fix_lambda.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];


obj = calibrate_fix_lambda(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_fix_lambda(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('lambda = 0, recalibrate')
disp('Objective function: current, as calibrated, baseline') 
disp([obj, obj_new, obj_baseline])
disp('Moments') 
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('appendix_fix_theta.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];


obj = calibrate_fix_theta(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_fix_theta(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('1/theta = 0, recalibrate')
disp('Objective function: current, as calibrated, baseline') 
disp([obj, obj_new, obj_baseline])
disp('Moments') 
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('appendix_fix_gamma.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];


obj = calibrate_fix_gamma(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_fix_gamma(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('gamma = 1, recalibrate')
disp('Objective function: current, as calibrated, baseline') 
disp([obj, obj_new, obj_baseline])
disp('Moments') 
disp(round(model_moments(table_order)',2))







