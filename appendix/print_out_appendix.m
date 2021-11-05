

table_order = [11,4,5,9,6,7,8,10,1,2,3];

addpath('../utils')
addpath('../calibration')

load('../calibration/calibrated_valuefunction_guess.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT

load('../calibration/calibrated_baseline.mat')

R = [];
beta = [];
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Basline Model')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_low_R.mat')

R = R;
beta = [];
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Low R')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_high_R.mat')

R = R;
beta = [];
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('High R')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_high_beta.mat')

R = [];
beta = beta;
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(beta)
disp('High beta')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_low_beta.mat')

R = [];
beta = beta;
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(beta)
disp('Low beta')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_subsistence.mat')

R = [];
beta = [];
min_consumption = min_consumption;
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(min_consumption)
disp('Subsistence')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_subsistence_high.mat')

R = [];
beta = [];
min_consumption = min_consumption;
perm_movecost = [];

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(min_consumption)
disp('Subsistence High')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_cal_perm_movingcost.mat')

R = [];
beta = [];
min_consumption = [];
perm_movecost = perm_movecost;

model_moments = calibrate_model_appendix(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(perm_movecost)
disp('Perm Moving Cost')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_fix_rho.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_fix_rho(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('rho = 0')
disp(model_moments(table_order)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('appendix_fix_ubar.mat')
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];

model_moments = calibrate_fix_ubar(x1, [], [], [], R, beta, min_consumption, perm_movecost, vguess,3);

disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('ubar = 1')
disp(model_moments(table_order)')

