load('appendix_fix_rho.mat')

x1 = [x1(1:3), 0.0 , x1(4:end)];

cd('../pe_welfare_analysis')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('FIX rho = 0, PE-WELFARE ANALYSIS')

analyze_outcomes(x1, [], [], [], [], [], 1)

cd('../appendix')