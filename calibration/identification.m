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

load('cal_baseline_s730.mat')
params = x1(1:end-1); % currently has moving cost in there
n_params = length(params); % how many paramters we need to do...

eps = 1 + 0.001; % This is the change. One issue is that some of this stuff was
% not changing that much, this is a question of how accuratly we are
% solving it, here is an area of investigation.

els_moments = zeros(9,9);
jacobian_moments = zeros(9,9);

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
    
    
% So each row is a parameter, the each column is the moment
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
old_jac = [    1.3491    0.7596   -0.3048   -3.4347   -0.3967   -1.9827   -0.5888    4.8902    0.3078
   -0.1698   -1.2530   -1.3775    1.1243    1.5290    3.2175   -0.8003   -3.7827   -0.2007
    0.4224    0.4317   14.5192    0.6148    2.5761    7.1597    3.1718    8.2249    2.1432
   -0.0007   -0.5161   -6.9149   -8.2708   -1.3068   -6.9702   -0.5216    2.4513   -1.0740
    0.1707   -0.0279    0.0061   -1.3844    1.1669   -1.4770   -0.1445   -0.6667   -0.0764
    0.0192    0.2014   -0.0352    1.9068   -1.1825    4.0777    0.5181    1.5528   -0.0580
    0.1350    0.0800   -0.2043   -0.9178    0.2481   -5.2909   -0.0999    3.8599    0.5050
   -0.0359    0.0225   -0.0015    0.6198   -0.4580   -0.7203    0.1180    0.2662   -0.0906];
% 
% 
% old_elas = [  -0.3214   -0.2679  -13.0161   -1.6023   -2.1447   -4.7414   -3.4623   -5.6148   -1.5220
%     1.3491    0.7596   -0.3048   -3.4347   -0.3967   -1.9827   -0.5888    4.8902    0.3078
%    -0.1698   -1.2530   -1.3775    1.1243    1.5290    3.2175   -0.8003   -3.7827   -0.2007
%     0.4224    0.4317   14.5192    0.6148    2.5761    7.1597    3.1718    8.2249    2.1432
%    -0.0007   -0.5161   -6.9149   -8.2708   -1.3068   -6.9702   -0.5216    2.4513   -1.0740
%     0.1707   -0.0279    0.0061   -1.3844    1.1669   -1.4770   -0.1445   -0.6667   -0.0764
%     0.0192    0.2014   -0.0352    1.9068   -1.1825    4.0777    0.5181    1.5528   -0.0580
%     0.1350    0.0800   -0.2043   -0.9178    0.2481   -5.2909   -0.0999    3.8599    0.5050
%    -0.0359    0.0225   -0.0015    0.6198   -0.4580   -0.7203    0.1180    0.2662   -0.0906];