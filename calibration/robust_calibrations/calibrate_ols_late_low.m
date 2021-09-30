clear
addpath('../../calibration')


UB = [2.25, 0.60, 1.70, 0.95, 1.90, 0.85, 0.85, 1.50, 0.30];
LB = [1.00, 0.40, 1.20, 0.25, 0.80, 0.20, 0.35, 0.35, 0.01];

load('calibration_final.mat')
x1 = exp(new_val);

for xxx = 1:10
    
    obj_old = calibrate_model(x1,[],1);
    
    x1 = x1.*exp(0.01.*randn(size(x1)));
    
    ObjectiveFunction = @(xxx) calibrate_model((xxx),[],1);

    opts = optimset('Display','iter','MaxFunEvals',400,'TolFun',10^-3,'TolX',10^-3);
 
    x1_new = fminsearchcon(ObjectiveFunction, x1,LB, UB,[],[],[],opts);

    obj_new = calibrate_model(x1_new,[],1);
    
    disp(obj_old)
    disp(obj_new)

if obj_new < obj_old

    x1 = x1_new;
    
    save cal_ols_high x1
    
end
    



end

rmpath('../../calibration')

%1.7500    0.5379    1.4779    0.8213    1.4047    0.5674    0.5052    0.6627    0.0564