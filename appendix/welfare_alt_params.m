load('../calibration/calibrated_baseline.mat')

cd('../pe_welfare_analysis')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Baseline')

analyze_outcomes(x1, [], [], [], [], [], 1)

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Larger Gamma = 1.5')

x1(8) = 1.5;

analyze_outcomes(x1, [], [], [], [], [], 1)

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('+ ubar = 1')

x1(5) = 1.0;

analyze_outcomes(x1, [], [], [], [], [], 1)

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('+ Urban TFP doubled')

x1(3) = x1(3)*2;

analyze_outcomes(x1, [], [], [], [], [], 1)

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('+ 5X Migration cost')
disp('Need to manually go into preamble_welfare.m')
disp('set cal_params(10) = 2.12*0.0878;')
disp('Then run: analyze_outcomes(x1, [], [], [], [], [], 1)')

cd('../appendix')