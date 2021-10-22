function [objective, social_welfare] = compute_fullinsurance(assets, move, cal, tfp, params, specs, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nshocks = specs.n_trans_shocks;
ntypes = specs.n_perm_shocks;
ubar = cal(5);

params.means_test = 0;

cexp = repmat([1;1], nshocks,1);
cnotexp = ((1./ubar).*(cexp).^(-2)).^(-1./2);

for xxx = 1:ntypes
    
    consumption(xxx).rural_not = cexp;
    consumption(xxx).rural_exp = cexp;
    consumption(xxx).seasn_not = cnotexp;
    consumption(xxx).seasn_exp = cexp;
    consumption(xxx).urban_new = cnotexp;
    consumption(xxx).urban_old = cexp;
    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[zurban , ~] = pareto_approx(specs.n_perm_shocks, 1./params.perm_shock_u_std);

types = [ones(specs.n_perm_shocks,1), zurban];

solve_types = [params.rural_tfp.*types(:,1), types(:,2)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[solve_types, ~] = effecient_preamble(cal, tfp, []); 

parfor xxx = 1:ntypes 
      
    [~, ~, vfun(xxx), muc(xxx)] = policy_valuefun_fullinsurance(assets(xxx), move(xxx),...
          params, [], consumption(xxx));
end


[data_panel, params, state_panel] = just_simmulate(params, move, solve_types, assets, specs, vfun, []);

params.means_test = 0; % need to call this bc. in the simmulation call it kicks back the means test
                       % which if not rest, it will simmulate as if it was
                       % relavent. A quirk of using the calibration code in
                       % this part.

[data_panel] = quick_sim_fullinsurance(data_panel, state_panel, muc, consumption, params);

[~, ~, cons_fix] = fullinsurance_aggregate(params,tfp, data_panel, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now rescale things so the resource constraint holds
cexp = repmat(cons_fix, nshocks,1);

cnotexp = ((1./ubar).*(cexp).^(-2)).^(-1./2);

for xxx = 1:ntypes
    
    consumption(xxx).rural_not = cexp;
    consumption(xxx).rural_exp = cexp;
    consumption(xxx).seasn_not = cnotexp;
    consumption(xxx).seasn_exp = cexp;
    consumption(xxx).urban_new = cnotexp;
    consumption(xxx).urban_old = cexp;
    
end 

parfor xxx = 1:ntypes 
      [~, ~, vfun(xxx), muc(xxx)] = policy_valuefun_fullinsurance(assets(xxx), move(xxx),...
          params, [], consumption(xxx));
end

[data_panel, params, state_panel] = just_simmulate(params, move, solve_types, assets, specs, vfun, []);

params.means_test = 0;

[data_panel] = quick_sim_fullinsurance(data_panel, state_panel, muc, consumption, params);

[social_welfare, ~] = fullinsurance_aggregate(params, tfp, data_panel, 1);

objective = 1;