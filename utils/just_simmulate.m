function [big_panel, params, big_state_panel] = just_simmulate(params, move, solve_types, assets, specs, vfun, meanstest, meanstest_cash)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_series = specs.time_series; %100000;
N_obs = specs.N_obs; %25000;

params.N_obs = N_obs;

big_panel = [];
big_state_panel = [];

[~,type_weights] = pareto_approx(specs.n_perm_shocks, 1./params.perm_shock_u_std);


for nmc = 1:specs.Nmontecarlo

    rng(03281978 + specs.seed + nmc)

    [~, shock_states_p] = hmmgenerate(time_series,params.trans_mat,ones(params.n_shocks));

    pref_shocks = rand(time_series,specs.n_perm_shocks);
    move_shocks = rand(time_series,specs.n_perm_shocks);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    sim_panel = zeros(N_obs,15,specs.n_perm_shocks);   
    states = zeros(N_obs,4,specs.n_perm_shocks);  
    
    parfor xxx = 1:specs.n_perm_shocks

    [sim_panel(:,:,xxx), states(:,:,xxx)] = rural_urban_simmulate(...
                                assets(xxx), move(xxx), params, solve_types(xxx,:), shock_states_p,...
                                pref_shocks(:,xxx), move_shocks(:,xxx), vfun(xxx));

    end
    
    
    n_draws = floor(N_obs/max(N_obs*type_weights)); % this computes the number of draws.
    sample = min(n_draws.*round(N_obs*type_weights),N_obs); % Then the number of guys to pull.
    s_count = 1;

    for xxx = 1:specs.n_perm_shocks

        e_count = s_count + sample(xxx)-1;
        
        data_panel(s_count:e_count,:) = sim_panel(N_obs-(sample(xxx)-1):end,:,xxx);
        state_panel(s_count:e_count,:) = [states(N_obs-(sample(xxx)-1):end,:,xxx), xxx.*ones(length(states(N_obs-(sample(xxx)-1):end,:,xxx)),1)];
    % this last value entry in the row indicates the permenant type of the
    % person in the panel. 
    
        s_count = e_count+1;
   
    end

    big_panel = [big_panel ; data_panel];
    big_state_panel = [big_state_panel; state_panel];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
income = 1; consumption = 2; assets = 3; live_rural = 4; work_urban = 5;
move = 6; move_season = 7; movingcosts = 8; season = 9; net_asset = 10;
welfare = 11; experince = 12; fiscalcost = 13; tax = 14; production = 15;

rural_not_monga = (big_panel(:,live_rural)==1 & big_panel(:,season)~=1);

if ( isempty(meanstest) || meanstest == 0)
    % if we have not specify, do this. Or if it's zero, then we are again 
    % just trying to replicate the original economy.
    
    params.means_test = (prctile(big_panel(rural_not_monga,3),55) + prctile(big_panel(rural_not_monga,3),45))./2;
    % This is so we can just replicate the old stuff...
else
    params.means_test = meanstest;
    % Here if we are doing the counterfactuall, we want the "same exact
    % guys", policies may change asset distribtuion, so this holds the
    % asset threshold at whatever it was chosen to be. 
end

if ( isempty(meanstest_cash) || meanstest_cash == 0)
    % if we have not specify, do this. Or if it's zero, then we are again 
    % just trying to replicate the original economy.
    
    params.means_test_cash = (prctile(big_panel(rural_not_monga,3),55) + prctile(big_panel(rural_not_monga,3),45))./2;
    % This is so we can just replicate the old stuff...
else
    params.means_test_cash = meanstest_cash;
    % Here if we are doing the counterfactuall, we want the "same exact
    % guys", policies may change asset distribtuion, so this holds the
    % asset threshold at whatever it was chosen to be. 
end


