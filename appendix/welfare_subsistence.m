load('appendix_cal_subsistence_high.mat')

cd('../pe_welfare_analysis')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Subsistence Consumption, PE-WELFARE ANALYSIS')

% IMPORTANT NEED TO GO IN AND MANUALLY CHANGE 
% preamble_welfare_analysis.m 
% cal_params(14) = 0.1756;

analyze_outcomes(x1, [], [], [], [], [], [], 1)

cd('../appendix')