function [objective, social_welfare] = onestep_fullinsurance(cguess, assets, move, tfp, weights, params, solve_types, specs, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.means_test = 0;

cexp = repmat(cguess, params.n_shocks/2,1); % by trans shock

cnotexp = ((1./params.ubar).*(cexp).^(-params.pref_gamma)).^(-1./params.pref_gamma);

for xxx = 1:params.n_perm_shocks
    
    consumption(xxx).rural_not = cexp;
    consumption(xxx).rural_exp = cexp;
    consumption(xxx).seasn_not = cnotexp;
    consumption(xxx).seasn_exp = cexp;
    consumption(xxx).urban_new = cnotexp;
    consumption(xxx).urban_old = cexp;
    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parfor xxx = 1:specs.n_perm_shocks 
      [~, ~, vfun(xxx), muc(xxx)] = policy_valuefun_fullinsurance(assets(xxx), move(xxx),...
          params, [], consumption(xxx));
end

[data_panel, params, state_panel] = just_simulate(params, move, solve_types, assets, specs, weights, vfun, [],[]);

params.means_test = 0;

[data_panel] = quick_sim_fullinsurance(data_panel, state_panel, muc, consumption, params);

if flag == 0.0

    [social_welfare, rc, ~] = fullinsurance_aggregate(params, tfp, data_panel, flag);

    objective = rc;

else 
    
   [social_welfare, rc, ~] = fullinsurance_aggregate(params, tfp, data_panel, flag);

   objective = rc;
   
end
