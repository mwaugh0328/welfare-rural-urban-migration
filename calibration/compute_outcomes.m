function [moments] = compute_outcomes(cal_params, specs, seed, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the driver file for the code which is consistent with RR2 paper at
% Econometrica (late 2020-on)
% NOTE This is primariy used for calibration. The other
% set of code, analyze_outcomes is for used for plotting and welfare analysis
% (does more stuff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The flie preable loads any fixed parameters (eg discount rate) and the
% specs on the computation, grid, number of simmulations. It's intended to
% be common to all code. So one place is changed all other code will
% inherti the change...

if isempty(specs)
    [cal_params, specs] = preamble(cal_params, [], seed,[]);
else
    [cal_params, ~] = preamble(cal_params, [], seed,[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now everything below is just organization till around like 150 or so...

params.rural_options = 3;
params.urban_options = 2;

params.hard_rural_choice = cast([1,2,3], 'uint8');
params.hard_urban_choice = cast([1,2], 'uint8');

params.tax.rate = cal_params(15);
params.tax.prog = cal_params(16);
params.tax.location = 'all';

params.means_test = 0;
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

urban_tfp = cal_params(3); 

rural_tfp = 1./urban_tfp; % Urban TFP

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

seasonal_shocks = [log(params.seasonal_factor); log(1./params.seasonal_factor)];

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

params.asset_space = specs.asset_space;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre generate the shocks
n_sims = specs.n_sims; %10000;
time_series = specs.time_series; %100000;
N_obs = specs.N_obs; %25000;

params.N_obs = N_obs;
params.follow_hh_expr = specs.follow_hh_expr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the policy functions and then simmulate the time paths. See the
% routines below for details.

% Note depending on the computer you have (and toolboxes with Matlab) using
% the parfor command here does help. It distributes the instructions within
% the for loop across different cores. It this case it leads to a big speed
% up. 

solve_types = [rural_tfp.*types(:,1), types(:,2)];

tic

parfor xxx = 1:n_types 

    [assets(xxx), move(xxx), vguess(xxx)] = ...
        rural_urban_value(params, solve_types(xxx,:),[]);
    
end

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%perform the field experiment...
parfor xxx = 1:n_types 
    
    [assets_temp(xxx), move_temp(xxx), cons_eqiv(xxx)] = field_experiment_welfare(params, solve_types(xxx,:), vguess(xxx));
    % This generates an alternative policy function for rural households associated with a
    % the field experiment of paying for a temporary move. The asset_temp
    % provides the asset policy conditional on a temporary move. 

end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now simulate the model...

Nmontecarlo = specs.Nmontecarlo;
moments = zeros(Nmontecarlo,specs.nmoments);

tic
for nmc = 1:Nmontecarlo

    rng(03281978 + specs.seed + nmc)

    [~, shock_states_p] = hmmgenerate(time_series,params.trans_mat,ones(params.n_shocks));

    pref_shocks = rand(time_series,n_perm_shocks);
    move_shocks = rand(time_series,n_perm_shocks);

    sim_panel = zeros(N_obs,6,n_types);
    states_panel = zeros(N_obs,4,n_types);
    
    
    parfor xxx = 1:n_types 

            [sim_panel(:,:,xxx), states_panel(:,:,xxx)] = cal_rural_urban_simmulate(...
                assets(xxx), move(xxx), params, solve_types(xxx,:), shock_states_p,...
                pref_shocks(:,xxx), move_shocks(:,xxx),vguess(xxx));

    end 
    
% Now record the data. What we are doing here is creating a
% cross-section/pannel of guys that are taken in porportion to their
% distributed weights. 

    n_draws = floor(N_obs/max(N_obs*type_weights)); % this computes the number of draws.
    sample = min(n_draws.*round(N_obs*type_weights),N_obs); % Then the number of guys to pull.
    s_count = 1;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This then pulls from the simmulation to construct the correct pannel, why
% bc we need the appropriate number of high type relative to low type guys
% in there. 
    for xxx = 1:n_types 

        e_count = s_count + sample(xxx)-1;
        
        data_panel(s_count:e_count,:) = sim_panel(N_obs-(sample(xxx)-1):end,:,xxx);
    
        s_count = e_count+1;
   
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [labor_income, consumption, assets, live_rural, move_seasn, season, experince, experiment_flag]
% Here is the means test for Mushfiq's expr...the latter is to smooth
% things

    rural_not_monga = data_panel(:,4)==1 & data_panel(:,6)~=1;
%params.means_test = median(data_panel(rural_not_monga,3));


    params.means_test = (prctile(data_panel(rural_not_monga,3),55) + prctile(data_panel(rural_not_monga,3),45))./2;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % This section of the code now performs the expirements. 
 
    sim_expr_panel = zeros(n_sims, size(data_panel,2) + 1, params.follow_hh_expr,n_types);
    sim_cntr_panel = zeros(n_sims, size(data_panel,2), params.follow_hh_expr,n_types);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    periods = 1:length(states_panel(:,:,1))-20;
    monga = periods(rem(periods,2)==0)-1;

    fooseed = specs.seed;

    parfor xxx = 1:n_types     
       
        rng(02071983 + fooseed + xxx + nmc)
        
        monga_index = monga(randi(length(monga),1,n_sims))';
                
        [sim_expr_panel(:,:,:,xxx), sim_cntr_panel(:,:,:,xxx)]...
        = cal_experiment_driver(assets(xxx), move(xxx), assets_temp(xxx), move_temp(xxx), ...
          params, solve_types(xxx,:), monga_index, states_panel(:,:,xxx), pref_shocks((N_obs+1):end,xxx), move_shocks((N_obs+1):end,xxx), sim_panel(:,:,xxx));
        
    % This then takes the policy functions, simmulates the model, then
    % after a period of time, implements the experirment.     
    end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
        end
                            
        s_expr_count = e_expr_count + 1;
                
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we are done. Everything else below is accounting and measurment. 
% panel = [labor_income, consumption, assets, live_rural, move_seasn, season, experince, experiment_flag]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First devine some indicator variables...

    rural = data_panel(:,4)==1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This part just focuses on the entire sample...

% Income earned by rural residents relative to urban...
    m_income = [mean((data_panel(rural,1))), mean((data_panel(~rural,1)))];

% Fraction of residents residing in the rural area...
    avg_rural = sum(rural)./length(data_panel);

   std_income = [std(log(data_panel(rural,1))), std(log(data_panel(~rural,1)))];
% No emasurment error here, we add it on expost. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now use the control and expirement stuff...
% [labor_income, consumption, assets, live_rural, work_urban, move, move_seasn, move_cost, season, experiment_flag];

% First drop people that did not have the experiment performed on them....
    rural_cntr = data_panel_cntr(:,4,1)==1 & data_panel_expr(:,end,1)==1;

    control_data = data_panel_cntr(rural_cntr,:,:);
    expermt_data = data_panel_expr(rural_cntr,:,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Migration Elasticity

    temp_migrate_cntr = control_data(:,5,1) == 1;
    temp_migrate_expr = expermt_data(:,5,1) == 1;

    temp_migration = sum(temp_migrate_cntr)./sum(rural_cntr);

    temp_expr_migration = sum(temp_migrate_expr)./sum(rural_cntr);

    migration_elasticity = temp_expr_migration - temp_migration;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Migration Elasticity Year 2

    temp_migrate_cntr_y2 = control_data(:,5,3) == 1;
    temp_migrate_expr_y2 = expermt_data(:,5,3) == 1;

    temp_migration_y2 = sum(temp_migrate_cntr_y2)./sum(rural_cntr);

    temp_expr_migration_y2 = sum(temp_migrate_expr_y2)./sum(rural_cntr);

    migration_elasticity_y2 = temp_expr_migration_y2 - temp_migration_y2;

    cont_y2 = control_data(:,5,1) == 1 & control_data(:,5,3) == 1;
    
    control_migration_cont_y2 = sum(cont_y2)./sum(rural_cntr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the LATE estimate in the model, the same way as in the
% data...so first stack stuff the way we want it....

    all_migration = [temp_migrate_cntr; temp_migrate_expr];

    not_control = [zeros(length(temp_migrate_cntr),1); ones(length(temp_migrate_expr),1)];

    first_stage_b = regress(all_migration, [ones(length(not_control),1), not_control]);

    predic_migration = first_stage_b(1) + first_stage_b(2).*not_control;

    consumption_noerror = [control_data(:,2,2); expermt_data(:,2,2)];

    AVG_C = mean(consumption_noerror);

    OLS_beta = regress(consumption_noerror, [ones(length(predic_migration),1), all_migration]);
    OLS = OLS_beta(2)./AVG_C;

    LATE_beta = regress(consumption_noerror, [ones(length(predic_migration),1), predic_migration]);
    LATE = LATE_beta(2)./AVG_C ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cons_data_no_error_r1 = [control_data(:,2,1); expermt_data(:,2,1)];
    cons_data_no_error_r2 = [control_data(:,2,2); expermt_data(:,2,2)];

% cons_data_r1 = exp(log(cons_data_no_error_r1) + m_error.*randn(length(cons_data_no_error_r1),1)); 
% cons_data_r2 = exp(log(cons_data_no_error_r2) + m_error.*randn(length(cons_data_no_error_r2),1));
% 
% cons_model = [ [temp_migrate_cntr; temp_migrate_expr], [zeros(length(temp_migrate_cntr),1); ...
%                 ones(length(temp_migrate_expr),1)], log(cons_data_r1), log(cons_data_r2)];
            
    cons_model_growth = log(cons_data_no_error_r1) - log(cons_data_no_error_r2);
    std_cons_growth = std(cons_model_growth);
% Again, no measurment error here, we can add it on expost. Need
% consistency in language. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assets...
%frac_no_assets = sum(control_data(:,3,1) < params.asset_space(2))./sum(rural_cntr);

    frac_no_assets = 0.95*(sum(control_data(:,3,1) == params.asset_space(1)))/sum(rural_cntr) + 0.05*(sum(control_data(:,3,1) == params.asset_space(2)))/sum(rural_cntr);
% Trying to smmoth this thing out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    aggregate_moments = [m_income(2)./m_income(1), avg_rural, std_income(2), frac_no_assets];

    experiment_moments = [temp_migration, migration_elasticity, migration_elasticity_y2, LATE, OLS, control_migration_cont_y2./temp_migration, std_cons_growth];

% (1) Wage gap
% (2) The rural share
% (3) The urban variance... note that this is position number 3 (see below)
% (4) Fraction with no liquid assets
% (5) seasonal migration in control
% (6) increase in r1 (22 percent)
% (7) increase in r2 (9.2 percent)
% (8) LATE estiamte
% (9) LATE - OLS estimate
% (10) Control repeat migration rate 
% (12) Standard deviation of consumption growth. 


% (11) moving cost / average consumption params.m_season./mean(AVG_C)

    moments(nmc,:)  = [aggregate_moments, experiment_moments] ;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc

if flag == 1
    
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
disp('OLS Estimate')
disp(mean(moments(:,9)))
    
end









