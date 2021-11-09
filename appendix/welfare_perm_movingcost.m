load('appendix_cal_perm_movingcost.mat')

cd('../pe_welfare_analysis')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Alternative Permanent Moving Cost, PE-WELFARE ANALYSIS')

% IMPORTANT NEED TO GO IN AND MANUALLY CHANGE 
% analyze_outcomes.m 
% params.m = params.m_season; % This is the moving cost. 

analyze_outcomes(x1, [], [], [], [], [], 1)

cd('../appendix')