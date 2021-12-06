clear
warning('off','stats:regress:RankDefDesignMat');

addpath('../utils')

load('../calibration/calibrated_baseline.mat')
load('wages.mat')

wages = [wages.monga, wages.notmonga];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code computes and presents the results from the GE reduction in
% seasonal migraiton costs funded by a distrotionary tax on labor income.
% Main pieces of code are called from the calibration file. 
% It does work a bit different since it alows for the policy fixing
% allocations, so no behavioral response. This will become clearer below.

disp('-----------------------------------------------------------------------------------------------------')
disp(datetime(now,'ConvertFrom','datenum'))
disp(' ')
ver
disp('-----------------------------------------------------------------------------------------------------')
disp(' ')
disp(' ')
disp('-----------------------------------------------------------------------------------------------------')
disp(' ')
disp('Replicate Baseline')
disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First is just to replicate the equillibrium of the calibrated economy.
% The output here should look just like the results from say
% ``analyze_outcomes''

[move, solve_types, assets, params, specs, vfun, ce] = just_policy(x1, wages, [], [], [], [], []);

[data_panel, params] = just_simmulate(params, move, solve_types, assets, specs, ce, [],[]);

[labor, govbc, tfp] = ge_aggregate(params, data_panel, wages, [], 'baseline', 1);

taxprog = 0.0;
% The tax code can do progressivity.

disp(' ')
disp('-----------------------------------------------------------------------------------------------------')
disp(' ')
disp('Permanent Unconditional Cash Transfer to Rural Poor + Endogenous Migration GE + Tax Financed')
disp(' ')
disp(' ')
disp('Solve for wages and tax rate')
disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we let everything change. Guys can change moving and asset choices,
% the moving cost is financed, and rural labor markets clear

options = optimoptions('fsolve', 'Display','iter','MaxFunEvals',2000,'MaxIter',20,...
'TolX',1e-3,'Algorithm','trust-region-reflective','FiniteDifferenceType','central',...
'FiniteDifferenceStepSize', 10^-3);

guess = [wages, 1.0];

tic
[wageseq, ~, ~] = fsolve(@(xxx) compute_eq((xxx), x1, tfp, [], params.means_test_cash, [], taxprog,[], 'cash', 0), guess,options);

toc

disp(wageseq)

compute_eq([wageseq], x1, tfp, [], params.means_test_cash, vfun, taxprog, [], 'cash', 1);