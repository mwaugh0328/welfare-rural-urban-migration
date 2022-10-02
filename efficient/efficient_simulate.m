function [big_panel, params, big_state_panel] = efficient_simulate(params, specs, move_policy, cons_policy, solve_types, vfun, muc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simmulates stuff so aggregates can be constructed...
% if vfun or muc are empty, then the panel just has zeros in the place.

time_series = specs.time_series;
N_obs = specs.N_obs;

% time_series = 100000;
% N_obs = 50000;

params.N_obs = N_obs;

big_panel = [];
big_state_panel = [];

[~, type_weights] = pareto_approx(params.n_perm_shocks, 1./params.perm_shock_u_std);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(vfun) 
    for xxx = 1:params.n_types
        
        vfun(xxx).rural_not = zeros(params.n_shocks,1);
        vfun(xxx).rural_exp = zeros(params.n_shocks,1);
        vfun(xxx).seasn_not = zeros(params.n_shocks,1);
        vfun(xxx).seasn_exp = zeros(params.n_shocks,1);
        vfun(xxx).urban_new = zeros(params.n_shocks,1);
        vfun(xxx).urban_old = zeros(params.n_shocks,1);

        muc(xxx).rural_not = zeros(params.n_shocks,1);
        muc(xxx).rural_exp = zeros(params.n_shocks,1);
        muc(xxx).seasn_not = zeros(params.n_shocks,1);
        muc(xxx).seasn_exp = zeros(params.n_shocks,1);
        muc(xxx).urban_new = zeros(params.n_shocks,1);
        muc(xxx).urban_old = zeros(params.n_shocks,1); 
    end
end

for nmc = 1:specs.Nmontecarlo

    rng(03281978 + specs.seed + nmc)

    [~, shock_states_p] = hmmgenerate(time_series,params.trans_mat,ones(params.n_shocks));

    pref_shocks = rand(time_series,specs.n_perm_shocks);
    move_shocks = rand(time_series,specs.n_perm_shocks);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sim_panel = zeros(N_obs,11,params.n_types);
    states = zeros(N_obs,3,params.n_types); 
    
    parfor xxx = 1:params.n_types 

        [sim_panel(:,:,xxx), states(:,:,xxx)] = simulate_efficient(cons_policy(xxx), move_policy(xxx), ...
                    params, solve_types(xxx,:), params.trans_shocks, shock_states_p, pref_shocks(:,xxx), move_shocks(:,xxx), vfun(xxx), muc(xxx));

    end
    
    
    n_draws = floor(N_obs/max(N_obs*type_weights)); % this computes the number of draws.
    sample = min(n_draws.*round(N_obs*type_weights),N_obs); % Then the number of guys to pull.
    s_count = 1;

    for xxx = 1:params.n_types

        e_count = s_count + sample(xxx)-1;
        
        data_panel(s_count:e_count,:) = sim_panel(N_obs-(sample(xxx)-1):end,:,xxx);
    
        state_panel(s_count:e_count,:) = [states(N_obs-(sample(xxx)-1):end,:,xxx), xxx.*ones(length(states(N_obs-(sample(xxx)-1):end,:,xxx)),1)];
    
        s_count = e_count+1;
   
    end
    
    big_panel = [big_panel ; data_panel];
    
    big_state_panel = [big_state_panel; state_panel];

end

big_panel = [big_panel, zeros(length(big_panel),1)];


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% income = 1; consumption = 2; assets = 3; live_rural = 4; work_urban = 5;
% move = 6; move_season = 7; movingcosts = 8; season = 9; net_asset = 10;
% welfare = 11; experince = 12; fiscalcost = 13; tax = 14; production = 15;
% 
% rural_not_monga = (data_panel(:,live_rural)==1 & data_panel(:,season)~=1);
% 
% if ( isempty(cft_params) || cft_params == 0)
%     % if we have not specify, do this. Or if it's zero, then we are again 
%     % just trying to replicate the original economy.
%     
%     params.means_test = (prctile(data_panel(rural_not_monga,3),55) + prctile(data_panel(rural_not_monga,3),45))./2;
%     % This is so we can just replicate the old stuff...
% else
%     params.means_test = cft_params;
%     % Here if we are doing the counterfactuall, we want the "same exact
%     % guys", policies may change asset distribtuion, so this holds the
%     % asset threshold at whatever it was chosen to be. 
% end



