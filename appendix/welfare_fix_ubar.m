load('appendix_fix_ubar.mat')

x1 = [x1(1:4), 1.0 , x1(5:end)];

cd('../pe_welfare_analysis')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('FIX UBAR = 1, PE-WELFARE ANALYSIS')

analyze_outcomes(x1, [], [], [], [], [], 1)

cd('../appendix')