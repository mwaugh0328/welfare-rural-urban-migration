clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these are the baseline moments:
aggregate_moments = [1.89, 0.61, 0.625, 0.47];

%%% Description:
% Wage gap
% The rural share
% The urban variance... note that this is position number 3 (see below)
% Fraction with no liquid assets

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment Moments...

experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.10, 0.40];
% The experiment hybrid is a combination of conrol and experiment...
% seasonal migration in control
% increase in r1 (22 percent)
% increase in r2 (9.2 percent)
% LATE estiamte
% OLS estimate
% Standard deviation of consumption growth. See line 400 in
% ``compute_outcomes.``

moments = [aggregate_moments, experiment_hybrid];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('./robust_calibrations/cal_ols_same.mat')
%x0 = exp(new_val);

ObjectiveFunction = @(xxx) calibrate_model((xxx), moments, [],1);

UB = [2.25, 0.60, 1.70, 0.95, 1.9, 0.85, 0.85, 1.50, 0.30];
LB = [1.00, 0.40, 1.20, 0.25, 1.0, 0.20, 0.35, 0.15, 0.01];

% options_pa = optimoptions('patternsearch','Display','iter','MaxFunEvals',200);
% % 
% new_cal = patternsearch(ObjectiveFunction,x0,[],[],[],[],(LB),(UB),[],options_pa) ;

opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',1000,'TolFun',10^-5,'TolX',10^-5);

tic
[new_cal, fval] = fminsearchcon(ObjectiveFunction, x1 ,(LB),(UB),[],[],[], opts);
toc

save calibration_r2 new_cal fval



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% optsNM = optimset('Display','iter','MaxFunEvals',100);
% 
% opts = optimoptions('patternsearch','Display','iter','UseParallel',true,'MaxFunEvals',100,'TolFun',10^-3,'TolX',10^-3,...
%     'SearchFcn',{@searchneldermead});
% 
% x1 = patternsearch(@(xxx) calibrate_model((xxx),[],1),exp(new_val), [],[],[],[],(LB),(UB),[],opts);
% 
% 
% opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',50000,'TolFun',10^-3,'TolX',10^-3);
% 
% x1 = fminsearchcon(@(xxx) compute_effecient(xxx, exp(new_val), tfp, 0), best.x1,LB,UB,A,b,[],opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.3065    0.4961    1.4559    0.7239    1.4440    0.5445    0.4921    0.6590
%1.3066    0.4961    1.4598    0.7219    1.4479    0.5745    0.5109    0.6590
% guess = [1.2893    0.5511    1.5691    0.7426    1.5548    0.5939    0.6258    0.5327    0.1161 0.08];
% 
% guess = [1.2879    0.5484    1.5817    0.7409    1.5645    0.5909    0.5919    0.5339    0.1172    0.0969] + .01*randn(1,length(guess));
% 
% %guess = [1.0333    0.5488    1.5184    0.6904    0.8454    0.4534    0.6359    0.7371]
% 
% upper_bound = [1.75, 0.60, 1.70, 0.95, 1.9, 0.85, 0.85, 0.95, 0.30];
% lower_bound = [1.00, 0.40, 1.20, 0.25, 1.1, 0.20, 0.35, 0.15, 0.01];

% ObjectiveFunction = @(x) calibrate_model((exp(x)),1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% options = gaoptimset('Display','iter','Generations',10,'Initialpopulation',log(guess));
% % 
% cal = ga(ObjectiveFunction, length(upper_bound),[],[],[],[],log(lower_bound),log(upper_bound),[],options)
% 
% save calibration_ga cal
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ObjectiveFunction = @(x) calibrate_model(exp(x),1);
% 





