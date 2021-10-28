% creates fake data for test of bootstrap
% must set preamble in clabiration Nmontecarlo = # of simmulations

cd('..\calibration')
load('calibrated_baseline.mat')
load('calibrated_valuefunction_guess.mat')

fake_data = compute_outcomes(x1, [], 9212016, vguess, 1);

cd('..\bootstrap')

save fake_data fake_data

