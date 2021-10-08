%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here is the code that generated the "indentification table" that we had
% in the paper. 
%
% Basic idea is take int he parmeters. We should have 8 parameters. The
% calibration will pop out 10 moments. Change the parameters by a small
% amount. Record the change in the moments relative to the change in the
% parameters. Everything below is done in logs.
%
% Then after that we can reorder the "table" as we want...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear

load('cal_baseline_mc.mat')

params = new_cal;

n_params = length(params); % how many paramters we need to do...

eps = 1+0.001; % This is the change. One issue is that some of this stuff was
% not changing that much, this is a question of how accuratly we are
% solving it, here is an area of investigation.

els_moments = zeros(10,10);

for xxx = 1:n_params
    
    disp(xxx)
    
    cal_eps_for = params;
    cal_eps_bak = params;
    
    cal_eps_for(xxx) = params(xxx).*eps; % forward
    cal_eps_bak(xxx) = params(xxx)./eps; % backward
        
    change_cal = log(cal_eps_for(xxx))-log(cal_eps_bak(xxx));
    
    moments_for = calibrate_model(cal_eps_for,[],[],2); % moments forward
    moments_bak = calibrate_model(cal_eps_bak,[],[],2); % moments backward
    
    change_moments = log(moments_for) - log(moments_bak);
    
    els_moments(xxx,:) = change_moments'./change_cal % compute change.
    
% So each row is a parameter, the each column is the moment
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% aggregate_moments = [1.80, 0.63, 0.68, 0.47];
% experiment_hybrid = [0.36, 0.22, 0.092, 0.30, 0.10,  0.40];
% 

% order_table = [2,5,6,7,8,3,1,4];
% order_moments = [5, 6, 7, 9, 8, 1, 2, 4];
% test = els_moments(order_table,order_moments);
% round(test,2)';