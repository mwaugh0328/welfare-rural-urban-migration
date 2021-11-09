
clc
table_order = [11,4,5,9,6,7,8,10,1,2,3];

addpath('../utils')
addpath('../calibration')

load('../calibration/calibrated_valuefunction_guess.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these are the baseline moments:
aggregate_moments = [1.89, 0.61, 0.625, 0.47];

%%% Description:
% (1) Wage gap
% (2) The rural share
% (3) The urban variance... note that this is position number 3 (see below)
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

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Basline Model')
disp([obj])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../calibration/calibrated_baseline.mat')
% This is just change R, not recalibrate 

R = 0.90;
beta = [];
min_consumption = [];
perm_movecost = [];

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Low R')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../calibration/calibrated_baseline.mat')
% This is just change R, not recalibrate 

R = 1.0;
beta = [];
min_consumption = [];
perm_movecost = [];

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('High R')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../calibration/calibrated_baseline.mat')
% This is just change beta, not recalibrate 

R = [];
beta = 0.97;
min_consumption = [];
perm_movecost = [];

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(beta)
disp('High beta')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../calibration/calibrated_baseline.mat')
% This is just change beta, not recalibrate 

R = [];
beta = 0.90;
min_consumption = [];
perm_movecost = [];

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(beta)
disp('Low beta')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_subsistence.mat')

R = [];
beta = [];
min_consumption = 0.0878;
perm_movecost = [];

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(min_consumption)
disp('Subsistence')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_subsistence_high.mat')

R = [];
beta = [];
min_consumption = min_consumption;
perm_movecost = [];

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(min_consumption)
disp('Subsistence High')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_perm_movingcost.mat')

R = [];
beta = [];
min_consumption = [];
perm_movecost = perm_movecost;

obj = calibrate_model_appendix(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);
model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(perm_movecost)
disp('Perm Moving Cost')
disp([obj, obj_new])
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
disp('rho = 0')
disp([obj, obj_new])
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
disp('ubar = 1')
disp([obj, obj_new])
disp(round(model_moments(table_order)',2))

