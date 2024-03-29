
warning('off','stats:regress:RankDefDesignMat');
addpath('../utils')
addpath('../calibration')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT
R = [];
beta = [];
min_consumption = [];
perm_movecost = [];


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../calibration/calibrated_baseline.mat')
load('../calibration/calibrated_valuefunction_guess.mat')

x1(4) = [];

opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',300,'TolFun',10^-3,'TolX',10^-3);

ObjectiveFunction = @(xxx) calibrate_fix_rho((xxx), moments, [], [], R, beta, min_consumption, perm_movecost,  vguess,1);

UB = [5.25, 0.60, 5.70,  5.9, 0.85, 0.85, 5.50, 1.00];
LB = [0.25, 0.30, 1.00,  1.0, 0.15, 0.15, 0.15, 0.01];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj_old = calibrate_fix_rho(x1, moments, [], [], R, beta, min_consumption, perm_movecost, vguess,1);

disp(obj_old)

for xxx = 1:5
    
    x1 = x1.*exp(0.02.*randn(size(x1)));

    x1_new = fminsearchcon(ObjectiveFunction, x1, LB, UB,[],[],[],opts);

    obj_new = calibrate_fix_rho(x1_new, moments, [], [], R, beta, min_consumption, perm_movecost,  vguess,1);
    
    disp(obj_old)
    disp(obj_new)

if obj_new < obj_old
    
    obj_old = obj_new;
    
    x1 = x1_new;
    
    save appendix_fix_rho x1 obj_new
    
end
    
end






