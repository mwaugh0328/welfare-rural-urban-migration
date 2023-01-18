function [social_welfare] = compute_fullinsurance(assets, move, tfp, weights, params, specs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[zurban , ~] = pareto_approx(specs.n_perm_shocks, 1./params.perm_shock_u_std);

types = [ones(specs.n_perm_shocks,1), zurban];

solve_types = [params.rural_tfp.*types(:,1), types(:,2)];

options = optimoptions('fsolve', 'Display','iter','MaxFunEvals',50,'MaxIter',20,...
'TolX',1e-8,'Algorithm','trust-region-reflective','FiniteDifferenceType','central',...
'FiniteDifferenceStepSize', 10^-3);

guess = [1.0; 1.0];

tic
[cons, ~, ~] = fsolve(@(xxx) onestep_fullinsurance(xxx, assets, move, tfp, weights, params, solve_types, specs, 0.0) , guess, options);
toc

[rc, social_welfare] = onestep_fullinsurance(cons, assets, move, tfp, weights, params, solve_types, specs, 1.0);

%disp(specs)
