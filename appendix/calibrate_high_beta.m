clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');
addpath('../utils')
addpath('../calibration')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT
R = [];
beta = 0.97;


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../calibration/calibrated_baseline.mat')
load('../calibration/calibrated_valuefunction_guess.mat')

opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',20,'TolFun',10^-3,'TolX',10^-3);

ObjectiveFunction = @(xxx) calibrate_model_appendix((xxx), moments, [], [], R, beta, vguess,1);

UB = [2.25, 0.60, 1.70, 0.95, 1.9, 0.85, 0.85, 1.50, 0.30];
LB = [0.25, 0.30, 1.00, 0.05, 1.0, 0.15, 0.15, 0.15, 0.01];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj_old = calibrate_model_appendix(x1, moments, [], [], R, beta, vguess,1);

disp(obj_old)

for xxx = 1:2
    
    x1 = x1.*exp(0.02.*randn(size(x1)));

    x1_new = fminsearchcon(ObjectiveFunction, x1, LB, UB,[],[],[],opts);

    obj_new = calibrate_model_appendix(x1_new, moments, [], [], R, beta, vguess,1);
    
    disp(obj_old)
    disp(obj_new)

if obj_new < obj_old
    
    obj_old = obj_new;
    
    x1 = x1_new;
    
    save appendix_cal_high_beta x1 beta
    
end
    
end






