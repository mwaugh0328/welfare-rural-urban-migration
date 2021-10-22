function [targets, wages] = analyze_outcomes(cal_params, specs, wages, meanstest, vft_fun, R, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the driver file for the code which is consistent with RR2 paper at
% Econometrica (late 2020-on).
% NOTE This is primariy used for plotting and welfare analysis. The other
% set of code, compute_outcomes is for calibration purposes (faster, more
% striped down)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The flie preable loads any fixed parameters (eg discount rate) and the
% specs on the computation, grid, number of simmulations. It's intended to
% be common to all code. So one place is changed all other code will
% inherti the change...

addpath('../utils')

if isempty(specs)
    [cal_params, specs] = preamble_welfare_analysis(cal_params, [], [], R);
else
    [cal_params, ~] = preamble_welfare_analysis(cal_params, [], [], R);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now everything below is just organization till around like 150 or so...
params.rural_options = 3;
params.urban_options = 2;

params.tax.rate = cal_params(15);
params.tax.prog = cal_params(16);
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

perm_shock_u_std = cal_params(2); % Permenant ability differs in the urban area.

params.urban_tfp = cal_params(3); 

params.rural_tfp = 1./params.urban_tfp; % Urban TFP

params.seasonal_factor = cal_params(11); % The seasonal fluctuation part. 

params.m_season = cal_params(10); % This is the bus ticket

params.m = 2*params.m_season; % This is the moving cost. 

gamma_urban = cal_params(8); % Gamma parameter (set to 1?)

% Number of permenant and transitory types. 
n_perm_shocks = specs.n_perm_shocks; %36; %48
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

[zurban , zurban_prob] = pareto_approx(n_perm_shocks, 1./perm_shock_u_std);

types = [ones(n_perm_shocks,1), zurban];

type_weights = zurban_prob;

[n_types , ~] = size(types);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up asset space and parameters to pass to the value function itteration.
% This is the new grid setup. It places a finer grid near the constraint
% and moving cost...

params.asset_space = specs.asset_space;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre generate the shocks
n_sims = specs.n_sims; %10000;
time_series = specs.time_series; %100000;
N_obs = specs.N_obs; %25000;

params.N_obs = N_obs;
params.follow_hh_expr = specs.follow_hh_expr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the policy functionsSee the
% routines below for details.

if isempty(meanstest) 
    
    params.means_test = 0;
else
    
    params.means_test = meanstest;

end

solve_types = [params.rural_tfp.*types(:,1), types(:,2)];

if isempty(vft_fun) 
    
    parfor xxx = 1:n_types 
        
        [assets(xxx), move(xxx), vguess(xxx)] = ...
            rural_urban_value(params, solve_types(xxx,:),[]);
    
    end
else
    
    parfor xxx = 1:n_types 
        
        [assets(xxx), move(xxx), vguess(xxx),~] = ...
            rural_urban_value(params, solve_types(xxx,:), vft_fun(xxx));
        
    end

end


parfor xxx = 1:n_types     
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, perform the field experiment...

    [assets_temp(xxx), move_temp(xxx), cons_eqiv(xxx)] = field_experiment_welfare(params, solve_types(xxx,:),  vguess(xxx));

    [assets_temp_cash(xxx), move_temp_cash(xxx),... 
       cons_eqiv_cash(xxx)] = cash_experiment_welfare(params, solve_types(xxx,:), vguess(xxx));
   
   [assets_fix(xxx), move_fix(xxx), cons_eqiv_fix(xxx)] = fix_allocations_experiment_welfare(assets(xxx), move(xxx), params, solve_types(xxx,:),  vguess(xxx));
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

seasont = repmat([0,1],1,n_tran_shocks);

lowz = flipud(move(4).rural_not(:,seasont==1,1));
medz = flipud(move(6).rural_not(:,seasont==1,1));
lowz_exp = flipud(move(4).rural_exp(:,seasont==1,1));
% visually, it's better to run this on the equally spaced grid.

cd('..\plotting')

%save movepolicy_ols_late.mat lowz medz lowz_exp
save movepolicy.mat lowz medz lowz_exp

lowz_expr = flipud(move_temp(4).rural_not(:,seasont==1,1));
medz_expr  = flipud(move_temp(6).rural_not(:,seasont==1,1));
lowz_exp_expr  = flipud(move_temp(4).rural_exp(:,seasont==1,1));
% visually, it's better to run this on the equally spaced grid.

%save movepolicy_exp_ols_late.mat lowz_expr medz_expr lowz_exp_expr 
save movepolicy_exp.mat lowz_expr medz_expr lowz_exp_expr 

cd('..\pe_welfare_analysis')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now simulate the model...

Nmontecarlo = specs.Nmontecarlo;

for nmc = 1:Nmontecarlo

    rng(03281978 + specs.seed + nmc)

    [~, shock_states_p] = hmmgenerate(time_series,params.trans_mat,ones(params.n_shocks));

    pref_shocks = rand(time_series,n_perm_shocks);
    move_shocks = rand(time_series,n_perm_shocks);

    sim_panel = zeros(N_obs,15,n_types);
    states_panel = zeros(N_obs,4,n_types);


    parfor xxx = 1:n_types 
% Interestingly, this is not a good part of the code to use parfor... it
% runs much faster with just a for loop.
       
    [sim_panel(:,:,xxx), states_panel(:,:,xxx)] = rural_urban_simmulate(...
        assets(xxx), move(xxx), params, solve_types(xxx,:), shock_states_p,...
        pref_shocks(:,xxx),move_shocks(:,xxx),vguess(xxx));
    
    end 

% Now record the data. What we are doing here is creating a
% cross-section/pannel of guys that are taken in porportion to their
% distributed weights. 

    n_draws = floor(N_obs/max(N_obs*type_weights)); % this computes the number of draws.
    sample = min(n_draws.*round(N_obs*type_weights),N_obs); % Then the number of guys to pull.
    s_count = 1;

    for xxx = 1:n_types 

        e_count = s_count + sample(xxx)-1;
        
        data_panel(s_count:e_count,:) = sim_panel(N_obs-(sample(xxx)-1):end,:,xxx);
    
        s_count = e_count+1;
   
    end

    rural_not_monga = data_panel(:,4)==1 & data_panel(:,9)~=1;

    params.means_test = (prctile(data_panel(rural_not_monga,3),55) + prctile(data_panel(rural_not_monga,3),45))./2;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % This section of the code now performs the expirements. 

    sim_expr_panel = zeros(n_sims,13,params.follow_hh_expr,n_types);
    sim_cash_panel = zeros(n_sims,13,params.follow_hh_expr,n_types);
    sim_fix_panel = zeros(n_sims,13,params.follow_hh_expr,n_types);
    sim_cntr_panel = zeros(n_sims,15,params.follow_hh_expr,n_types);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    periods = 1:length(states_panel(:,:,1))-20;
    monga = periods(rem(periods,2)==0)-1;
    
    fooseed = specs.seed;

    parfor xxx = 1:n_types     
        
        rng(02071983 + fooseed + xxx + nmc)

        monga_index = monga(randi(length(monga),1,n_sims))';

        [sim_expr_panel(:,:,:,xxx), sim_cntr_panel(:,:,:,xxx)]...
            = experiment_driver(assets(xxx), move(xxx), assets_temp(xxx), move_temp(xxx), cons_eqiv(xxx),...
            params, solve_types(xxx,:), monga_index, states_panel(:,:,xxx), pref_shocks((N_obs+1):end,xxx), move_shocks((N_obs+1):end,xxx), sim_panel(:,:,xxx));
      
        [sim_cash_panel(:,:,:,xxx), ~]...
            = experiment_driver(assets(xxx), move(xxx), assets_temp_cash(xxx),move_temp_cash(xxx), cons_eqiv_cash(xxx),...
            params, solve_types(xxx,:), monga_index, states_panel(:,:,xxx), pref_shocks((N_obs+1):end,xxx), move_shocks((N_obs+1):end,xxx), sim_panel(:,:,xxx));
    
    
       [sim_fix_panel(:,:,:,xxx), ~]...
            = experiment_driver(assets(xxx), move(xxx), assets_fix(xxx),move_fix(xxx), cons_eqiv_fix(xxx),...
            params, solve_types(xxx,:), monga_index, states_panel(:,:,xxx), pref_shocks((N_obs+1):end,xxx), move_shocks((N_obs+1):end,xxx), sim_panel(:,:,xxx));
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Now the code below constructs a panel so the approriate types are where
% % they should be....

    n_draws = floor(n_sims/max(n_sims*type_weights));
    sample_expr = min(n_draws.*round(n_sims*type_weights),n_sims);
    s_expr_count = 1;

    exp_index = specs.exp_index;

    for xxx = 1:n_types
        
        e_expr_count = s_expr_count + sample_expr(xxx)-1;
    
        for zzz = 1:length(exp_index)
    
            data_panel_expr(s_expr_count:e_expr_count,:,exp_index(zzz)) = sim_expr_panel(n_sims-(sample_expr(xxx)-1):end,:,exp_index(zzz),xxx);

            data_panel_cntr(s_expr_count:e_expr_count,:,exp_index(zzz)) = sim_cntr_panel(n_sims-(sample_expr(xxx)-1):end,:,exp_index(zzz),xxx);
        
            data_panel_cash(s_expr_count:e_expr_count,:,exp_index(zzz)) = sim_cash_panel(n_sims-(sample_expr(xxx)-1):end,:,exp_index(zzz),xxx);
            
            data_panel_fix(s_expr_count:e_expr_count,:,exp_index(zzz)) = sim_fix_panel(n_sims-(sample_expr(xxx)-1):end,:,exp_index(zzz),xxx);
        end
                        
        s_expr_count = e_expr_count + 1;
                
    end
    
    
    [~, ~, ~, wagestats(nmc), aggstats] = just_aggregate(params,data_panel,[],[],0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    rural_cntr = data_panel_cntr(:,4,1)==1 & data_panel_expr(:,13,1)==1;

    control_data = data_panel_cntr(rural_cntr,:,:);
    expermt_data = data_panel_expr(rural_cntr,:,:);
    cash_data = data_panel_cash(rural_cntr,:,:);
    fix_data = data_panel_fix(rural_cntr,:,:);
    
    
    [migration] = report_experiment(control_data, expermt_data, 'bus');
    
    frac_no_assets = 0.95*(sum(control_data(:,3,1) == params.asset_space(1)))/sum(rural_cntr)...
    + 0.05*(sum(control_data(:,3,1) == params.asset_space(2)))/sum(rural_cntr);
    
    aggregate_moments = [aggstats.income.urban./aggstats.income.rural, aggstats.avg_rural, aggstats.var_income.urban, frac_no_assets];

    experiment_moments = [migration.control.y1, migration.elasticity.y1, migration.elasticity.y2, migration.LATE, migration.LATE- migration.OLS,...
        migration.control_cont.y2];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    moments(nmc,:)  = [aggregate_moments, experiment_moments] ;
    
    m_rates(nmc,:) = [migration.elasticity.y1, migration.elasticity.y2, NaN, migration.elasticity.y4, NaN, migration.elasticity.y5];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    income_assets = [fix_data(:,1,1), fix_data(:,3,1), fix_data(:,10,1), fix_data(:,7,1)];

    urban_prd = expermt_data(:,11,2);
    expr_prd = expermt_data(:,12,1);

    [fix_policy_bin(nmc)] = report_welfare_quintiles(income_assets, urban_prd, expr_prd);
    
    fix_policy_avg(nmc,:) = [mean(fix_data(:,10,1)),mean(fix_data(:,7,1)),mean(expr_prd)];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    income_assets = [control_data(:,1,1), control_data(:,3,1), expermt_data(:,10,1), migration.experiment_indicator.y1];

    urban_prd = expermt_data(:,11,2);
    expr_prd = expermt_data(:,12,1);

    [conditional_ticket_bin(nmc)] = report_welfare_quintiles(income_assets, urban_prd, expr_prd);
    
    conditional_ticket_avg(nmc,:) = [mean(expermt_data(:,10,1)),mean(expermt_data(:,7,1)),mean(expr_prd)];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    income_assets = [control_data(:,1,1), control_data(:,3,1), cash_data(:,10,1), cash_data(:,7,1)];

    [unconditional_cash_bin(nmc)] = report_welfare_quintiles(income_assets,urban_prd,expr_prd);
    
    [cash(nmc)] = report_experiment(control_data, cash_data, 'cash');
    
    unconditional_cash_avg(nmc,:) = [mean(cash_data(:,10,1)),mean(cash_data(:,7,1))];
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we are done. Everything else below is accounting and measurment. 
% TODO: setup simmilar to GE, TAX, Effecient, accounting framework.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This part just focuses on the entire sample...

wages.monga = mean([wagestats.monga]);
wages.notmonga = mean([wagestats.notmonga]);

targets = mean(moments, 1);

% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('Policy : Welfare by Income Quintile: Welfare, Migration Rate, Z, Experience')
disp(round(100.*[mean([fix_policy_bin.welfare],2), mean([fix_policy_bin.migration],2), mean([fix_policy_bin.urban],2)./100,...
    mean([fix_policy_bin.expr],2)],2))
disp('Averages: Welfare, Migration Rate, Experince')
disp(round(100.*[mean(fix_policy_avg,1)],2))


% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('PE Conditional Migration Transfer: Welfare by Income Quintile: Welfare, Migration Rate, Z , Experience ')
disp(round(100.*[mean([conditional_ticket_bin.welfare],2), mean([conditional_ticket_bin.migration],2), mean([conditional_ticket_bin.urban],2)./100,...
    mean([conditional_ticket_bin.expr],2)],2))
disp('Averages: Welfare, Migration Rate, Experince')
disp(round(100.*[mean(conditional_ticket_avg,1)],2))

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % The unconditional cash transfer
% 
% 
disp('')
disp('PE Unconditional Cash Transfer: Welfare and Migration by Income Quintile ')
disp(round(100.*[mean([unconditional_cash_bin.welfare],2), mean([unconditional_cash_bin.migration],2),],2))
disp('PE Unconditional Cash Transfer: Average Welfare Gain, Migration Rate')
disp(round(100.*[mean(unconditional_cash_avg,1)],2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('')
disp('')
disp('Wage Gap')
disp(mean(moments(:,1)))
disp('Average Rural Population')
disp(mean(moments(:,2)))
disp('Fraction of Rural with No Assets')
disp(mean(moments(:,4)))
disp('Expr Elasticity: Year One, Two')
disp([mean(moments(:,6)), mean(moments(:,7))])
disp('Control: Year One, Repeat Two')
disp([mean(moments(:,5)), mean(moments(:,10))])
disp('LATE Estimate')
disp(mean(moments(:,8)))
disp('LATE - OLS Estimate')
disp(mean(moments(:,9)))

cd('..\plotting')

m_rates_model = 100.*mean(m_rates,1)';

save migration_model m_rates_model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This just works of the last run...fix at some point?

cons_data_no_error_r1 = [control_data(:,2,1); expermt_data(:,2,1)];
cons_data_no_error_r2 = [control_data(:,2,2); expermt_data(:,2,2)];

cons_model_growth = log(cons_data_no_error_r1) - log(cons_data_no_error_r2);
var_cons_growth = std(cons_model_growth);

m_error = (0.1783 - var(cons_model_growth)).^.5;

cons_model_growth = cons_model_growth + m_error.*randn(length(cons_model_growth),1);

cons_model = [ [migration.control_indicator.y1; migration.experiment_indicator.y1],...
                [zeros(length(migration.control_indicator.y1),1); ...
                ones(length(migration.experiment_indicator.y1),1)], cons_model_growth];
            
save cons_model_set cons_model 

cd('..\pe_welfare_analysis')
    
end









