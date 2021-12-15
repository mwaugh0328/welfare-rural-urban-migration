function [rc, social_welfare, move] = onestep(cons_mpl, params, tfp, solve_types, seed, flag)

consfix = cons_mpl(1:2);
mplscale.raw.rural.notmonga = cons_mpl(3);
mplscale.raw.rural.monga = cons_mpl(4);

cexp = repmat(consfix, params.n_shocks/2,1);

cnotexp = ((1./params.ubar).*(cexp).^(-2)).^(-1./2);

for xxx = 1:params.n_perm_shocks
    
    consumption(xxx).rural_not = cexp;
    consumption(xxx).rural_exp = cexp;
    consumption(xxx).seasn_not = cnotexp;
    consumption(xxx).seasn_exp = cexp;
    consumption(xxx).urban_new = cnotexp;
    consumption(xxx).urban_old = cexp;
    
end 

if flag == 0.0

    move = efficient_chi_policy(params, mplscale, consumption, solve_types);

    [data_panel, params, ~] = efficient_simulate(params, move, consumption, solve_types, [], [], seed);

    [social_welfare, rc, ~, mpl] = efficient_aggregate(params,tfp, data_panel,flag);
    
    rc = [rc ; ( mpl.raw.rural.notmonga - mplscale.raw.rural.notmonga ); ( mpl.raw.rural.monga - mplscale.raw.rural.monga )];
    
else
    
    move = efficient_chi_policy(params, mplscale, consumption, solve_types);
    
    [vfun, muc] = efficient_policy(params, move, consumption);

    [data_panel, params, state_panel] = efficient_simulate(params, move, consumption, solve_types, [], [], seed);
    
    [data_panel] = quick_sim_efficient(data_panel, state_panel, vfun, muc, consumption, params);

    [social_welfare, rc, ~, mpl] = efficient_aggregate(params, tfp, data_panel, flag);
    
    rc = [rc ; mpl.raw.rural.notmonga - mplscale.raw.rural.notmonga; mpl.raw.rural.monga - mplscale.raw.rural.monga];
end
    


