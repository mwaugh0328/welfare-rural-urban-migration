function [estimate, fval] = calibrate_montecarlo(moments)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('..\calibration\robust_calibrations\cal_ols_same.mat')
x1 = x1(1:end-1);

load('..\calibration\calibrated_valuefunction_guess.mat')


opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',300,'TolFun',10^-3,'TolX',10^-3);
ObjectiveFunction = @(xxx) calibrate_model((xxx), moments, [], [], vguess,1);

UB = [2.25, 0.60, 1.70, 0.95, 1.9, 0.90, 0.90, 1.50, 0.30];
LB = [0.75, 0.40, 1.10, 0.15, 1.0, 0.10, 0.10, 0.15, 0.01];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[estimate, fval] = fminsearchcon(ObjectiveFunction, x1, LB, UB,[],[],[],opts);







