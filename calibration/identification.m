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

%load('lambda_pi_cal_baseline_s5_1.mat')
load('lambda_pi_cal_baseline_s715.mat')
params = x1_new; % currently has moving cost in there
n_params = length(params); % how many paramters we need to do...

eps = 1 + 0.005; % This is the change. One issue is that some of this stuff was
% not changing that much, this is a question of how accuratly we are
% solving it, here is an area of investigation.

els_moments = zeros(n_params,n_params);
jacobian_moments = zeros(n_params,n_params);

for xxx = 1:n_params
    
    disp(xxx)
    
    cal_eps_for = params;
    cal_eps_bak = params;
    
    cal_eps_for(xxx) = params(xxx).*eps; % forward
    cal_eps_bak(xxx) = params(xxx)./eps; % backward
    
    moments_for = calibrate_model(cal_eps_for,[],[],2); % moments forward
    moments_bak = calibrate_model(cal_eps_bak,[],[],2); % moments backward

    jacobian_moments(xxx,:) = (moments_for - moments_bak)' ./ ( cal_eps_for(xxx) - cal_eps_bak(xxx) );
    els_moments(xxx,:) = (log(moments_for) - log(moments_bak))' ./  ( log(cal_eps_for(xxx))-log(cal_eps_bak(xxx)) ); 
    
    disp(els_moments(xxx,:))
    foo = 1;
    
    
% So each row is a parameter, the each column is the moment
    
end

-0.4789   -0.3701   -3.4752   -0.0423    0.9223    1.2981   -0.3477   -2.0909
%30-7
% -0.4804   -0.3757   -1.0078    0.0511    0.9708    1.8797   -0.5193    1.0241
% -0.4232   -0.3632   -1.5382   -0.0450    0.6899    0.8301    0.4009    1.3511

%30-5
%-0.4787   -0.3716   -2.2841   -0.0637    0.7812    1.2121   -0.2902    0.4535
%-0.4510   -0.3892   -1.5012    0.1891    0.7852    0.7333    0.1222    0.3276

%30-9
%-0.4978   -0.3840   -2.3082    0.1076    0.7531    1.0534   -1.1238   -0.2008
%-0.4616   -0.4084   -0.9837    0.0870    0.8758    0.8855   -0.6679    0.2422

