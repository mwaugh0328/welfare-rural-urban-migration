function [data_panel, params, sim_panel] = effecient_simmulate(params, move_policy,...
                cons_policy, solve_types, vfun, muc, sim_panel, position)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_sims = 5000;
time_series = 100000;
N_obs = 50000;

params.N_obs = N_obs;

rng(03281978)

[~, shock_states_p] = hmmgenerate(time_series,params.trans_mat,ones(params.n_shocks));

pref_shocks = rand(time_series,params.n_perm_shocks);

move_shocks = rand(time_series,params.n_perm_shocks);

% states_panel = zeros(N_obs,4,params.n_types);

[~,type_weights] = pareto_approx(params.n_perm_shocks, 1./params.perm_shock_u_std);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(sim_panel)
    
    sim_panel = zeros(N_obs,11,params.n_types);   
    
    parfor xxx = 1:params.n_types 

    [sim_panel(:,:,xxx), ~] = simmulate_effecient(cons_policy(xxx), move_policy(xxx), ...
                    params, solve_types(xxx,:), params.trans_shocks, shock_states_p, pref_shocks(:,xxx), move_shocks(:,xxx), vfun(xxx), muc(xxx));
                
    % This is the same one as in baseline model
    end
else
    
    [sim_panel(:,:,position), ~] = simmulate_effecient(cons_policy(position), move_policy(position), ...
                    params, solve_types(position,:), params.trans_shocks, shock_states_p, pref_shocks(:,position), move_shocks(:,position), vfun(position), muc(position));

end
    
n_draws = floor(N_obs/max(N_obs*type_weights)); % this computes the number of draws.
sample = min(n_draws.*round(N_obs*type_weights),N_obs); % Then the number of guys to pull.
s_count = 1;

for xxx = 1:params.n_types

    e_count = s_count + sample(xxx)-1;
        
    data_panel(s_count:e_count,:) = sim_panel(N_obs-(sample(xxx)-1):end,:,xxx);
    
    s_count = e_count+1;
   
end

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



