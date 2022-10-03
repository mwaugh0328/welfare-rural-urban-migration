function [objective, social_welfare] = onestep_fullinsurance(cguess, assets, move, tfp, weights, params, solve_types, specs, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.means_test = 0;

cons_low = cguess(1:2); % lowest guy consumption, experince, by season

cexp = repmat(cons_low, params.n_shocks/2,1); % by trans shock

cnotexp = ((1./params.ubar).*(cexp).^(-params.pref_gamma)).^(-1./params.pref_gamma); % non-experince by trans shock

for xxx = 1:params.n_perm_shocks
    % assign the consumption level by permanent shock
    
    consumption(xxx).rural_not = cexp;
    
    consumption(xxx).rural_exp = cexp;
    
    consumption(xxx).seasn_not = cnotexp;
    
    consumption(xxx).seasn_exp = cexp;
    
    consumption(xxx).urban_new = cnotexp;
    
    consumption(xxx).urban_old = cexp;
    
    % Now update the cexp and cnotexp reflectin the pareto weights
    
    if xxx < params.n_perm_shocks
        
        cexp = ( (weights(xxx) ./ weights(xxx+1) ).*cexp.^(-params.pref_gamma) ).^(-1 ./ params.pref_gamma);
        
        cnotexp = ( (weights(xxx) ./ weights(xxx+1) ).*cnotexp.^(-params.pref_gamma) ).^(-1 ./ params.pref_gamma);
        
        % the check on this is that the standard deviation of weight*muc in
        % cross section should be zero.
        
    end
          
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parfor xxx = 1:specs.n_perm_shocks 
      [~, ~, vfun(xxx), muc(xxx)] = policy_valuefun_fullinsurance(assets(xxx), move(xxx),...
          params, [], consumption(xxx));
end

[data_panel, params, state_panel] = just_simulate(params, move, solve_types, assets, specs, weights, vfun, [],[]);

params.means_test = 0;

[data_panel] = quick_sim_fullinsurance(data_panel, state_panel, weights, muc, consumption, params);

if flag == 0.0

    [social_welfare, rc, ~] = fullinsurance_aggregate(params, tfp, data_panel, flag);

    objective = rc;

else 
    
   [social_welfare, rc, ~] = fullinsurance_aggregate(params, tfp, data_panel, flag);

   objective = rc;
   
end
