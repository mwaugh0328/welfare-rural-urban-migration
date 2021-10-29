% creates fake data for test of bootstrap


cd('..\calibration')

load('calibrated_baseline.mat')
load('calibrated_valuefunction_guess.mat')

% IMPORTANT 
% must set preamble in clabiration specs.Nmontecarlo = # of simmulated
% moments one wants

fake_data = compute_outcomes(x1, [], 9212016, vguess, 1);

cd('..\bootstrap')

save fake_data fake_data

