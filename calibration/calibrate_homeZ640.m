clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');
addpath('../utils')

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

experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.10, 0.25/0.36, 0.10, 0.40];
% (6) seasonal migration in control
% (7) increase in r1 (22 percent)
% (8) increase in r2 (9.2 percent)
% (9) LATE estiamte
% (10) OLS estimate
% (11) Control repeat migration rate 
% (12) Temp Moving cost relative to rural average consumption
% (13) Standard deviation of consumption growth. 

moments = [aggregate_moments, experiment_hybrid];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('cal_home_z640.mat')
%x1 = [x1, 0.08];
%x0 = exp(new_val);

ObjectiveFunction = @(xxx) calibrate_model((xxx), moments, [],1);

UB = [2.25, 0.60, 1.70, 0.95, 1.9, 0.85, 0.85, 1.50, 0.30, 0.20];
LB = [0.75, 0.40, 1.20, 0.25, 1.0, 0.15, 0.15, 0.15, 0.01, 0.05];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% options_pa = optimoptions('patternsearch','Display','iter','MaxFunEvals',1000);
% % 
% new_cal = patternsearch(ObjectiveFunction,x0,[],[],[],[],(LB),(UB),[],options_pa) ;

opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',500,'TolFun',10^-3,'TolX',10^-3);

obj_old = calibrate_model(x1, moments, [],1);

for xxx = 1:10

    x1_new = fminsearchcon(ObjectiveFunction, x1,LB, UB,[],[],[],opts);

    obj_new = calibrate_model(x1_new, moments, [],1);
    
    disp(obj_old)
    disp(obj_new)

if obj_new < obj_old
    
    obj_old = obj_new;
    
    x1 = x1_new;
    
    save cal_home_z640 x1
    
end

x1 = x1.*exp(0.01.*randn(size(x1)));

end