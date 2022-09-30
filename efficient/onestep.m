function [rc, social_welfare, move] = onestep(cons_mpl, weights, params, tfp, solve_types, seed, flag)
% now the setup for pareto weight version is where the consumption part is
% for for the lowest z and by experince.

cons_low = cons_mpl(1:2); % lowest guy consumption

mplscale.raw.rural.notmonga = cons_mpl(3); % no change on mpl
mplscale.raw.rural.monga = cons_mpl(4);

cexp = repmat(cons_low, params.n_shocks/2,1); % experince by trans shock

cnotexp = ((1./params.ubar).*(cexp).^(-2)).^(-1./2); % non-experince by trans shock

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
        
        cexp = ( (weights(xxx) ./ weights(xxx+1) ).*cexp.^(-2) ).^(-1 ./ 2);
        
        cnotexp = ( (weights(xxx) ./ weights(xxx+1) ).*cnotexp.^(-2) ).^(-1 ./ 2);
        
    end
          
end 

if flag == 0.0
    % this is about the part to solve for dynamic multiplier, compute
    % allocation and then check if resource constraint is met or not.
    % here (?) nothing needs to be adjusted re. weights.

    % computes the move policy, per the notes, pareto weights do not enter
    % only need consumption.
    move = efficient_chi_policy(params, mplscale, consumption, solve_types);

    % then simmulate...again here no need to pass the weights through
    [data_panel, params, ~] = efficient_simulate(params, move, consumption, solve_types, [], [], seed);

    % this is the place where weights may be required, but not here since
    % the focus on allocations
    [~, rc, ~, mpl] = efficient_aggregate(params,tfp, data_panel,flag);
    
    rc = [rc ; ( mpl.raw.rural.notmonga - mplscale.raw.rural.notmonga ); ( mpl.raw.rural.monga - mplscale.raw.rural.monga )];
    
else
    % same as above
    move = efficient_chi_policy(params, mplscale, consumption, solve_types);
    
    % pull out value fun and muc
    [vfun, muc] = efficient_policy(params, move, consumption);
    
    % simmulate, not sure why some historical reason, but vfun and muc are
    % not here, do no need to put in the weights.
    [data_panel, params, state_panel] = efficient_simulate(params, move, consumption, solve_types, [], [], seed);
    
    [data_panel] = quick_sim_efficient(data_panel, state_panel, weights, vfun, muc, consumption, params);

    [social_welfare, rc, ~, mpl] = efficient_aggregate(params, tfp, data_panel, flag);
    
    rc = [rc ; mpl.raw.rural.notmonga - mplscale.raw.rural.notmonga; mpl.raw.rural.monga - mplscale.raw.rural.monga];
end
    


