clear
warning('off','stats:regress:RankDefDesignMat');

addpath('../calibration')

load calibration_final
load wages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code computes and presents the results from the GE reduction in
% seasonal migraiton costs funded by a distrotionary tax on labor income.
% Main pieces of code are called from the calibration file. 
% It does work a bit different since it alows for the policy fixing
% allocations, so no behavioral response. This will become clearer below.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First is just to replicate the equillibrium of the calibrated economy.
% The output here should look just like the results from say
% ``analyze_outcomes''

[move, solve_types, assets, params, specs, vfun, ce] = just_policy(exp(new_val), testwage, [], [], [], []);

[data_panel, params] = just_simmulate(params, move, solve_types, assets, specs, ce, []);

[labor, govbc, tfp] = aggregate(params, data_panel, testwage, [], 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now let's add in the free money to move.

cft = params.means_test; % this is the means test, like in mushfiqu's world
% only about 50 percent of the rural are eligble. We are keeping the number
% fixed. 

taxprog = 0.0;
% The tax code can do progressivity.

disp('Location of Taxation')
disp(params.tax.location)
disp('')

policyfun.move = move;
policyfun.assets = assets;
% Here is the key. The code is setup to compute stuff given policy
% functions assets and moving (which may not be optimal). So the idea here is fix
% actions/behavior...and compute welfare. Note in this case the number of
% people eliglble should be the same as above...why? actions did not
% change.

compute_eq([testwage; 1.0], exp(new_val), tfp, cft, vfun, taxprog, policyfun, 1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we want to make sure we have the money to pay for things...so we are
% going to find a tax rate that sets the government budget constraint
% equall to zero

options = optimoptions('fsolve', 'Display','iter','MaxFunEvals',2000,'MaxIter',20,...
'TolX',1e-3,'Algorithm','trust-region-reflective','FiniteDifferenceType','central',...
'FiniteDifferenceStepSize', 10^-3);

guess = [testwage; 1.0];

tic
[wageseq, ~, ~] = fsolve(@(xxx) compute_eq((xxx), exp(new_val), tfp, cft, [], taxprog, policyfun, 0), guess,options);
toc

disp(wageseq)

compute_eq([wageseq], exp(new_val), tfp, cft, vfun, taxprog, policyfun, 1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we let everything change. Guys can change moving and asset choices,
% the moving cost is financed, and rural labor markets clear

guess = [testwage; 1.0];

tic
[wageseq, ~, ~] = fsolve(@(xxx) compute_eq((xxx), exp(new_val), tfp, cft, [], taxprog,[], 0), guess,options);
toc

disp(wageseq)

compute_eq([wageseq], exp(new_val), tfp, cft, vfun, taxprog, [], 1)