function [move, solve_types, assets, params, specs, vfun, ce] = just_policy...
    (cal_params, wages, vft_fun, meanstest, meanstest_cash, tax, policyfun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[cal_params, specs] = tax_eq_preamble(cal_params, [], [], []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.rural_options = 3;
params.urban_options = 2;

if isempty(tax) 
    
    params.tax.rate = cal_params(15);
    params.tax.prog = cal_params(16);
   
else
    params.tax.rate = tax(1);
    params.tax.prog = tax(2);
end

params.tax.location = 'all';
params.alpha = cal_params(17);

%Preferences
params.sigma_nu_not = cal_params(9); %These are the logit shocks
params.sigma_nu_exp = cal_params(9);

params.R = cal_params(12);  %The storage technology

params.beta = cal_params(13);  % The discount factor

params.abar = cal_params(14); % The discount factor

params.ubar = cal_params(5);   % ubar, disutility of being in urban area

params.lambda = cal_params(6); % getting experince and losing it

params.pi_prob = cal_params(7);

params.pref_gamma = 2; % Riskaversion (need to look at paper and change name)

params.A = (1-params.pref_gamma).^-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Shocks...

shock_rho = cal_params(4); % Persistance of shocks

shock_std = cal_params(1).*sqrt((1-shock_rho).^2); % Standard Deviation of shocks

params.perm_shock_u_std = cal_params(2); % Permenant ability differs in the urban area.

params.urban_tfp = cal_params(3); 

params.rural_tfp = 1./params.urban_tfp; % Urban TFP

params.seasonal_factor = cal_params(11); % The seasonal fluctuation part. 

params.m_season = cal_params(10); % This is the bus ticket

params.m = 2*params.m_season; % This is the moving cost. 

gamma_urban = cal_params(8); % Gamma parameter (set to 1?)

% Number of permenant and transitory types. 
params.n_perm_shocks = specs.n_perm_shocks; %36; %48
n_tran_shocks = specs.n_trans_shocks; %15; %30

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % This first sets up the transitory shocks. 

m_adjust_rural = -1./(1-shock_rho.^2).*(shock_std.^2).*(1/2);

m_adjust_urban = -1./(1-shock_rho.^2).*(shock_std.^2).*(1/2).*(gamma_urban);
% This here should set the shocks so that in levels, the mean value is one.
% thus changes in std or gamma only affect variances. 

%[shocks_trans,trans_mat] = tauchen(n_tran_shocks,0,shock_rho,shock_std,2.5);

[shocks_trans,trans_mat_temp] = rouwenhorst(n_tran_shocks,shock_rho,shock_std);

seasonal_trans_mat = [0 , 1 ; 1, 0]; 

if isempty(wages) 
    seasonal_shocks = [log(params.seasonal_factor); log(1./params.seasonal_factor)];
else
    seasonal_shocks = [log(wages(1)); log(wages(2))];
end

params.trans_mat = kron(trans_mat_temp, seasonal_trans_mat);

shocks_trans_temp = repmat(shocks_trans',2,1);

seasonal_shocks_temp = repmat(seasonal_shocks,1,n_tran_shocks);

shocks_trans_r = shocks_trans_temp(:) + seasonal_shocks_temp(:) + m_adjust_rural ;
shocks_trans_u = gamma_urban.*(shocks_trans_temp(:) + m_adjust_urban);

params.trans_shocks = [exp(shocks_trans_r),exp(shocks_trans_u)];

params.n_shocks = length(shocks_trans_u);


% Note: Seasonality will only show up in odd periods. Even periods are the
% good season...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This sets up the permenant type of shocks...for now, I'm just going to
% use this tauchen method which with no persistance will correspond with a
% normal distribution and then the transition matrix will determine the
% relative weights of the guys in the population. 

[zurban , ~] = pareto_approx(params.n_perm_shocks, 1./params.perm_shock_u_std);

types = [ones(params.n_perm_shocks,1), zurban];

[n_types , ~] = size(types);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up asset space and parameters to pass to the value function itteration.
% This is the new grid setup. It places a finer grid near the constraint
% and moving cost...

params.asset_space = specs.asset_space;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the policy functions and then simmulate the time paths. See the
% routines below for details.

% Note depending on the computer you have (and toolboxes with Matlab) using
% the parfor command here does help. It distributes the instructions within
% the for loop across different cores. It this case it leads to a big speed
% up. 

solve_types = [params.rural_tfp.*types(:,1), types(:,2)];

% The counterfactual is a means tested moving cost removal. if it's zero,
% this is the baseline model. Otherwise, it;s the means tested value...
if isempty(meanstest) 
    
    params.means_test = 0;
    
else
    
    params.means_test = meanstest;

end

if isempty(meanstest_cash) 
    
    params.means_test_cash = 0;
    
else
    
    params.means_test_cash = meanstest_cash;

end

% Then here is the value function stuff, again depends if there is the
% means test. Also, the final imput can be a value function. This is used
% to compute welfare...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% consumption.rural_not = ones(n_shocks);
% consumption.rural_exp = ones(n_shocks);
% consumption.seasn_not = ones(n_shocks);
% consumption.seasn_exp = ones(n_shocks);
% consumption.urban_new = ones(n_shocks);
% consumption.urban_old = ones(n_shocks);
% 
% move.rural_not = cumsum((1./3).*ones(n_shocks,3),2);
% move.rural_exp = cumsum((1./3).*ones(n_shocks,3),2);
% move.urban_new = cumsum((1./2).*ones(n_shocks,2),2);
% move.urban_old = cumsum((1./2).*ones(n_shocks,2),2);
% 
% [move, vfinal, ~] = effecient_valuefun(consumption, move, params, solve_types(1,:), trans_shocks, trans_mat,[])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if isempty(vft_fun) 
    
    if isempty(policyfun)
        
        parfor xxx = 1:n_types 
        
        [assets(xxx), move(xxx), vfun(xxx), ce(xxx)] = ...
            rural_urban_value(params, solve_types(xxx,:),[],[]);
        
        end
    else
        parfor xxx = 1:n_types 
                [assets(xxx), move(xxx), vfun(xxx), ce(xxx)] = ...
                    policy_valuefun(policyfun.assets(xxx), policyfun.move(xxx), params, solve_types(xxx,:), []);

        end
    end
        

else
    if isempty(policyfun)
        
        parfor xxx = 1:n_types 
        
        [assets(xxx), move(xxx), vfun(xxx), ce(xxx)] = ...
            rural_urban_value(params, solve_types(xxx,:), vft_fun(xxx),[]);
        
        end
    else
        parfor xxx = 1:n_types 
                [assets(xxx), move(xxx), vfun(xxx), ce(xxx)] = ...
                    policy_valuefun(policyfun.assets(xxx), policyfun.move(xxx), params, solve_types(xxx,:), vft_fun(xxx));
        end
    end
    
end
