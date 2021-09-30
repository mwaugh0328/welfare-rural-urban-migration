clear
addpath('../../calibration')
addpath('../../utils')
warning('off','stats:regress:RankDefDesignMat');

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

experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.30, 0.25/0.36, 0.40];
% (6) seasonal migration in control
% (7) increase in r1 (22 percent)
% (8) increase in r2 (9.2 percent)
% (9) LATE estiamte
% (10) OLS estimate
% (11) Control repeat migration rate 
% (12) Standard deviation of consumption growth. 

moments = [aggregate_moments, experiment_hybrid];

ObjectiveFunction = @(xxx) calibrate_model((xxx), moments, [],1);

UB = [2.25, 0.60, 1.70, 0.95, 1.90, 0.85, 0.85, 1.50, 0.30];
LB = [1.00, 0.40, 1.20, 0.25, 0.80, 0.20, 0.35, 0.35, 0.01];


load('calibration_final.mat')
x1 = exp(new_val);

obj_old = calibrate_model(x1, moments, [],1);
opts = optimset('Display','iter','MaxFunEvals',400,'TolFun',10^-3,'TolX',10^-3);

for xxx = 1:2
    
    x1 = x1.*exp(0.01.*randn(size(x1)));

    x1_new = fminsearchcon(ObjectiveFunction, x1,LB, UB,[],[],[],opts);

    obj_new = calibrate_model(x1_new, moments, [],1);
    
    disp(obj_old)
    disp(obj_new)

if obj_new < obj_old
    
    obj_old = obj_new;
    
    x1 = x1_new;
    
    save cal_ols_same x1
    
end
    



end

rmpath('../../calibration')

%1.7500    0.5379    1.4779    0.8213    1.4047    0.5674    0.5052    0.6627    0.0564