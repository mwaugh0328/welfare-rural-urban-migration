function [cal_params, specs] = preamble_welfare_analysis(cal_params, specs, seed, R)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cal_params should have the following order
% 1: standard Deviation of shocks (todo, veryfy its stand dev or variance)
% 2: Pareto shape parameter for permenant ability in the urban area.
% 3: Urban TFP
% 4: Persistance of transitory shocks
% 5: Ubar, disutility of being in urban area
% 6: Getting experince 
% 7: Losing it. (TO DO, veryify the 6 and 7 is correct rel. paper)
% 8: Gamma parameter in shock process
% 9: Logit shocks
% 10: Seasonal migration cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Then there are some pre-determined, hand calibrated values...

cal_params(10) = 0.0878; % this is the moving cost. It was hand calibrated to 
% % deliver it being approx 10% of half yearly consumption. Did try internal
% % calibration...does provide better fit actually.

cal_params(11) = 0.55; % This is the seasonal shock. Again, hand calibrated
% to approx match the large drop in income and consumption in Monga from
% the Khandeker paper.

if isempty(R)
    cal_params(12) = 0.95; % This is the gross real interest rate on the riskfree
    %asset/storage technology. Consistent with their primary asset being cash and
    % an annual 10% inflation rate
else
    cal_params(12) = R;
end

cal_params(13) = 0.95; % This is the discount factor. Would be something worth 
%trying to calibratate in the future. 

cal_params(14) = 0.0; % This is the abar...it's set to zero. We are able to 
% to have it be positive. 

cal_params(15) = 1.0; % this value is 1 - the average tax rate

cal_params(16) = 0.0; % this is the tax progresivity

cal_params(17) = 0.845; % this is the extent of decreasing returns in rural area
                        % it was hand calibrated to mach the AKM experiment
                        % 0.845
                        
cal_params(18) = 0.56.*cal_params(10); % cash transfer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(specs)
    grid1 = [30, 0.0, 0.29]; % this is done to overwieght grid at constraint and
                             % moving cost.
    grid2 = [70, 0.30, 2];

    specs.asset_space = [linspace(grid1(2),grid1(3),grid1(1)), linspace(grid2(2),grid2(3),grid2(1))];
    %specs.asset_space = linspace(0,2,200); % this is the equally spaced grid

    specs.n_perm_shocks = 24;
    specs.n_trans_shocks = 7;

    specs.time_series = 100000; % length of the time series for each perm type
    specs.N_obs = 25000; % grab last number of observations
    specs.n_sims = 5000; % given the pannel above how many times to sample for experiment
    
    specs.follow_hh_expr = 11;  % number of time periods to follow a guy, historical was 11;
    specs.exp_index = [1,2,3,4,5,7,11]; % places to capture data (historical code was [1,2,3,4,5,7,11];
    
    specs.Nmontecarlo = 30;
        
end

if isempty(seed)
    specs.seed = 555;
else
    specs.seed = seed;
end
    
    
    