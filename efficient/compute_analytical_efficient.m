function [social_welfare, move] = compute_analytical_efficient(cal, specs, tfp, weights)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[solve_types, params] = efficient_preamble(cal, tfp, specs); 

%[weights] = make_weights(0, solve_types);

% mplscale.raw.rural.notmonga = 1.0;
% mplscale.raw.rural.monga  = 1.0;

options = optimoptions('fsolve', 'Display','iter','MaxFunEvals',50,'MaxIter',20,...
'TolX',1e-8,'Algorithm','trust-region-reflective','FiniteDifferenceType','central',...
'FiniteDifferenceStepSize', 10^-3);

guess = [2.5; 2.5; 0.90; 0.90];

tic
[cons, ~, ~] = fsolve(@(xxx) onestep(xxx, weights, params, specs, tfp, solve_types, 0), guess,options);
toc

[rc, social_welfare, move] = onestep(cons, weights, params, specs, tfp, solve_types, 1.0);

%disp(specs)

% disp(cons)
% disp(rc)