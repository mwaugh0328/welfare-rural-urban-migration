
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First add some paths as some code will be called from other folders, then
% add the calibration. Note the -r2 is in levels not logs and is called
% new_cal, so just comment out the line below.

addpath('../calibration')
addpath('../ge_taxation')

load calibration_final
new_cal = exp(new_val);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now let's run the main file, this creates the wages for the decentralized
% equillibrium

[targets, wage] = analyze_outcomes(new_cal, [], [], [], [], 1);

cd('..\effecient')

wage_de = [wage.monga, wage.notmonga];
%These are teh wages in the decentralized equillibrium, then we are going
%to pass this through one last time to get policy functions and the
%primitive TFP. The move policy function below is used to construct a good
%initial guess for the optimization and bounds on the problem.

[move_de, solve_types, assets, params, specs, vfun, ce] = just_policy(new_cal, wage_de, [], [], [], []);
% What this does is construct the policy functions and value functions
% given the wage.

[data_panel, params] = just_simmulate(params, move_de, solve_types, assets, specs, vfun, []);
% this then simmulates the economy

[labor, govbc, tfp, ~, welfare_decentralized] = aggregate(params, data_panel, wage_de, [], 1);
% then aggregates.

% The key here is the results should be exactly the same as the
% analyze_outcomes code. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
[~, fullinsruance_welfare] = compute_fullinsurance(assets, move_de, new_cal, tfp, params, specs, 1);

cons_eqiv.all = ((fullinsruance_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
% This is just the standard thing. Think of guys behind the vale, so social
% welfare in the effecient allocation relative to decentralized. This is
% what each should recive (expost paths and outcomes may be different) but
% this is again a behind the vale calcuation.

% you could also compute, take this compared to a rural guy, what would he
% get in expectation if living in the effecient world or urban.
cons_eqiv.rural = ((fullinsruance_welfare.all ./ welfare_decentralized.rural)).^(1./(1-params.pref_gamma)) - 1;
cons_eqiv.urban = ((fullinsruance_welfare.all ./ welfare_decentralized.urban)).^(1./(1-params.pref_gamma)) - 1;

disp("Al, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
disp(100.*cons_eqiv.all)
% disp("Rural, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
% disp(100.*cons_eqiv.rural)
% disp("Urban, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
% disp(100.*cons_eqiv.urban)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Now Compute the Effecient Allocation...')



% load move_fminsearch
% tic
% compute_effecient(x1, new_cal, tfp, 1);
% toc

tic
% load move_fminsearch_alpha LB UB A b
% load move_fminsearch_alpha_70
%load move_psearch_best_rents x1 LB UB A b
%load move_fminsearch_rents_85 x1 LB UB A b

% tic
% gthone = A*x1 > 1;
% x1(gthone) = x1(gthone) - 10^-3;

tic 

opts = optimoptions('patternsearch','Display','iter','UseParallel',true,'MaxFunEvals',100000,'PollMethod','GSSPositiveBasis2N');

x1 = patternsearch(@(xxx) compute_effecient(xxx, new_cal, tfp, 0),x1, A,b,[],[],(LB),(UB),[],opts);

%save move_psearch_best_rents_85 x1 LB UB A b

toc

load move_psearch_best_rents_85 

gthone = A*x1 > 1;
x1(gthone) = x1(gthone) - 10^-3;

for zzz = 1:20

tic

opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',3000,'TolFun',10^-3,'TolX',10^-3);
 
x1 = fminsearchcon(@(xxx) compute_effecient(xxx, new_cal, tfp, 0), x1,LB, UB,A,b,[],opts);

[social_welfare] = compute_effecient(x1, new_cal, tfp, 1);

%save move_fminsearch_rents_85 x1 LB UB A b

toc

end


% opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter',...
% 'UseParallel',true,'FiniteDifferenceType','central',...
% 'FiniteDifferenceStepSize', 10^-4,'TolX',1e-3,'TolFun',10^-4,'MaxFunEvals',20000,...
% 'ConstraintTolerance',10^-3);
% 
% load move_fminsearch_alpha
% 
% [x1] = fmincon(@(xxx) compute_effecient(xxx, exp(new_val), tfp, 0), x1, A,b,[],[],(LB)-10^-10,(UB )+10^-10,[],opts);




% ntypes = 24;
% n_shocks = 5*2;
% 
% asset_loc = 15;
% 
% move_vec = [];
% count = 0;
% 
% A = [];
% rural_A = [eye(10), eye(10); zeros(10), zeros(10)];
% urban_A = zeros(10);
% 
% %14.0000   76.0000   12.0000    1.0000   
% %15.0000   79.0000   86.0000    2.0000
% %12.0000   92.0000   35.0000    3.0000 
% for xxx = 1:ntypes
%     
%     foo = squeeze(move_de(xxx).rural_not(12,:,:));
%   
%     foo = [foo(:,1),  diff(foo,1,2)];
%     foo = foo(:,1:2);
% 
%     move_vec = [move_vec ; foo(:)];
%     A = blkdiag(A,rural_A);
%     
%     foo = squeeze(move_de(xxx).rural_exp(92,:,:));
%     
%     foo = [foo(:,1),  diff(foo,1,2)];
%     foo = foo(:,1:2);
% 
%     move_vec = [move_vec ; foo(:)];
%     A = blkdiag(A,rural_A);
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     foo = squeeze(move_de(xxx).urban_new(35,:,:));
% 
%     foo = [foo(:,1),  diff(foo,1,2)];
%     move_vec = [move_vec ; foo(:,1)];
%     A = blkdiag(A,urban_A);
%     
%     foo = squeeze(move_de(xxx).urban_old(3,:,:));
%     
%     foo = [foo(:,1),  diff(foo,1,2)];
%     move_vec = [move_vec ; foo(:,1)];
%     A = blkdiag(A,urban_A);
%     bar = 1;
%     
% end
% x0 = move_vec;
% x1 = max(x0-10^-5,0);
% 
% LB = (zeros(length(x0),1));
% UB = (ones(length(x0),1));
% b = ones(length(x0),1);

% move_planner = make_movepolicy(best.x1, params.n_shocks, params.n_perm_shocks);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % cd('..\plotting')
% % 
% % seasont = repmat([0,1],1,params.n_shocks/2);
% % 
% % foo = move_planner(4).rural_not(:,2)' - move_planner(4).rural_not(:,1)'; 
% % % this is pobaility of staying...in planner
% % 
% % foo = repmat(foo,length(params.asset_space),1);
% % 
% % lowz_planner = flipud(foo(:,seasont==1));
% % 
% % foo = move_planner(6).rural_not(:,2)' - move_planner(6).rural_not(:,1)'; 
% % % this is pobaility of staying...in planner
% % 
% % foo = repmat(foo,length(params.asset_space),1);
% % 
% % medz_planner = flipud(foo(:,seasont==1));
% % 
% % lowz_ce = flipud(move_de(4).rural_not(:,seasont==1,2) - move_de(4).rural_not(:,seasont==1,1));
% % medz_ce = flipud(move_de(6).rural_not(:,seasont==1,2) - move_de(6).rural_not(:,seasont==1,1));
% % 
% % 
% % save movepolicy_planner.mat lowz_planner lowz_ce medz_planner medz_ce
% % 
% % cd('..\effecient')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% tic
% [~, social_welfare] = compute_effecient(best.x1,  new_cal, tfp, 1);
% toc
% 
% cons_eqiv.all = ((social_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
% % This is just the standard thing. Think of guys behind the vale, so social
% % welfare in the effecient allocation relative to decentralized. This is
% % what each should recive (expost paths and outcomes may be different) but
% % this is again a behind the vale calcuation.
% 
% % you could also compute, take this compared to a rural guy, what would he
% % get in expectation if living in the effecient world or urban.
% cons_eqiv.rural = ((social_welfare.all ./ welfare_decentralized.rural)).^(1./(1-params.pref_gamma)) - 1;
% cons_eqiv.urban = ((social_welfare.all ./ welfare_decentralized.urban)).^(1./(1-params.pref_gamma)) - 1;
% 
% disp("Al, Welfare Gain in %: From Decentralized to Centralized/Effecient Allocaiton")
% disp(100.*cons_eqiv.all)
% % disp("Rural, Welfare Gain in %: From Decentralized to Centralized/Effecient Allocaiton")
% % disp(100.*cons_eqiv.rural)
% % disp("Urban, Welfare Gain in %: From Decentralized to Centralized/Effecient Allocaiton")
% % disp(100.*cons_eqiv.urban)
% 
% x1 = best.x1;
% 
% load bounds



%rmpath('../calibration')
%rmpath('../ge_taxation')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All this stuff below is to solve for the effecient allocation, not just
% compute it given a solution which is what it does above.

%tic
%[social_welfare] = compute_effecient(x0, new_cal, tfp, 1);
%toc


% 

% two = load('move_psearch_best2.mat','x1');
% thr = load('move_psearch_best3.mat','x1');
% xinit = [x0'; one.x1';two.x1';thr.x1'];

% tic
% 
% opts = optimoptions('ga','Display','iter','UseParallel',true,'MaxGenerations',100,'TolFun',10^-3);
% 
% [x1] = ga(@(xxx) compute_effecient(xxx, exp(new_val), tfp, 0),length(x0), A,b,[],[],(LB),(UB),[],opts);
% 
% x1 = x1';
% 
% toc
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% 
% tic
% 
% opts = optimoptions('patternsearch','Display','iter','UseParallel',true,'MaxFunEvals',10000,'TolFun',10^-3,'TolX',10^-3);
% 
% x1 = patternsearch(@(xxx) compute_effecient(xxx, exp(new_val), tfp, 0),x1, A,b,[],[],(LB),(UB),[],opts);
% 
% save move_psearch_best7 x1
% 
% toc
% tic 
% 
% opts = optimset('Display','iter','UseParallel',true,'MaxFunEvals',50000,'TolFun',10^-3,'TolX',10^-3);
% 
% x1 = fminsearchcon(@(xxx) compute_effecient(xxx, exp(new_val), tfp, 0), best.x1,LB,UB,A,b,[],opts);
% 
% save move_fminsearch_surf x1
% 
% toc

















