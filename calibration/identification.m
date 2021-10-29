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

addpath('../utils')

load('calibrated_baseline.mat')
params = x1;
n_params = length(params); % how many paramters we need to do...

eps = 1 + 0.005; % This is the change. One issue is that some of this stuff was
% not changing that much, this is a question of how accuratly we are
% solving it, here is an area of investigation.

els_moments = zeros(9,10);
load('calibrated_valuefunction_guess.mat')

tic, start_moments = calibrate_model(params,[],[],[],vguess,2); toc

for xxx = 1:n_params
    
    disp(xxx)
    
    cal_eps_for = params;
    cal_eps_bak = params;
    
    cal_eps_for(xxx) = params(xxx).*eps; % forward
    cal_eps_bak(xxx) = params(xxx)./eps; % backward
    
    moments_for = calibrate_model(cal_eps_for,[],[],[],vguess,2); % moments forward
    moments_bak = calibrate_model(cal_eps_bak,[],[],[],vguess,2); % moments backward
    
    

    
    els_moments(xxx,:) = (log(moments_for) - log(moments_bak))' ./  ( log(cal_eps_for(xxx))-log(cal_eps_bak(xxx)) ); 
    
    
% So each row is a parameter, the each column is the moment
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
