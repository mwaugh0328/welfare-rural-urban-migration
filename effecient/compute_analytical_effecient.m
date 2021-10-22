function [social_welfare, move] = compute_analytical_effecient(cal, tfp, seed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[solve_types, params] = effecient_preamble(cal, tfp, []); 

% mplscale.raw.rural.notmonga = 1.0;
% mplscale.raw.rural.monga  = 1.0;



options = optimoptions('fsolve', 'Display','iter','MaxFunEvals',50,'MaxIter',20,...
'TolX',1e-8,'Algorithm','trust-region-reflective','FiniteDifferenceType','central',...
'FiniteDifferenceStepSize', 10^-3);

guess = [1.0; 1.3; 0.90; 0.90];

tic
[cons, ~, ~] = fsolve(@(xxx) onestep(xxx, params, tfp, solve_types, seed, 0), guess,options);
toc

[rc, social_welfare, move] = onestep(cons, params, tfp, solve_types, seed, 1.0);

% disp(cons)
% disp(rc)