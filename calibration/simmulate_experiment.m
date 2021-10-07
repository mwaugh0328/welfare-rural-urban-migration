function [panel_expr] = simmulate_experiment...
    (assets_policy, move_policy, assets_temp, move_temp, cons_eqiv, params, perm_type,...
    state_at_expr, shock_states, pref_shock, move_shock)%#codegen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up grid for asset holdings. 

means_test = params.means_test;

asset_space = params.asset_space;

R = params.R; 
z_rural = perm_type(1); z_urban = perm_type(2);
% These are the permanent shocks. 

m = params.m;
m_seasn = params.m_season;
lambda = params.lambda;
pi_prob = params.pi_prob;

r_shocks = params.trans_shocks(:,1);
u_shocks = params.trans_shocks(:,2);

expr_shock = pref_shock;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_series = length(shock_states);

% The initial location state...
location = zeros(time_series+1,1); 

move = zeros(time_series,1);
move_seasn = zeros(time_series,1);
move_cost = zeros(time_series,1);

experiment_flag = zeros(time_series,1);
welfare = zeros(time_series,1);

labor_income = zeros(time_series,1);

consumption = zeros(time_series,1);
assets = zeros(time_series+1,1);
season = zeros(time_series,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the way it will work, we will run this out some time say 1000
% periods. The implement the experiment. Then run it out 10 more periods to
% see what happens. 

asset_state_at_expr = state_at_expr(1);
asset_state_p = asset_state_at_expr;

location(1) = state_at_expr(2);
experiment_flag(1) = 1;
 
assets(1,1) = asset_space(asset_state_at_expr);

hard_rural_choice = cast([1,2,3],'uint8');
hard_urban_choice = cast([1,2],'uint8');

xxx = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Urban located guys are not in the sample....
if location(xxx) == 2 || location(xxx) == 4 || location(xxx) == 5 || location(xxx) == 6
    
location = location(1:end-1,1);
assets = assets(1:end-1,1); 
% This is important. So this now generates assets
% % held at date t (not chosen). So one can construce the budget constraint.

live_rural = location == 1 | location == 2 | location == 3 | location == 4;
work_urban = location == 2 | location == 4 | location == 5 | location == 6;
experince = location == 3;

experiment_flag(1) = 0;
welfare(1) = 0;

    season(xxx,1) = mod(shock_states(xxx),2); 
    urban_skill = z_urban.*ones(length(labor_income),1);
%     panel_expr = [labor_income, consumption, assets, live_rural, work_urban,...
%         move, move_seasn, move_cost, season, welfare, experiment_flag];
    
     panel_expr = [labor_income, consumption, assets, live_rural, work_urban, move,...
     move_seasn, move_cost, season, welfare, urban_skill, experince, experiment_flag];
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Rural guys that have too much wealth, not in the sample.
if assets(1,1) > means_test

location = location(1:end-1,1);
assets = assets(1:end-1,1); 
% This is important. So this now generates assets
% % held at date t (not chosen). So one can construce the budget constraint.

live_rural = location == 1 | location == 2 | location == 3 | location == 4;
work_urban = location == 2 | location == 4 | location == 5 | location == 6;
experince = location == 3;

experiment_flag(1) = 0;
welfare(1) = 0;
    
    season(xxx,1) = mod(shock_states(xxx),2); 
    
    urban_skill = z_urban.*ones(length(labor_income),1);
%     panel_expr = [labor_income, consumption, assets, live_rural, work_urban,...
%         move, move_seasn, move_cost, season, welfare, experiment_flag];
    
     panel_expr = [labor_income, consumption, assets, live_rural, work_urban, move,...
     move_seasn, move_cost, season, welfare, urban_skill, experince, experiment_flag];
    return
end    


experiment_flag(1) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This means perform the experiment....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logit_shock = move_shock(xxx); 

if location(xxx) == 1 % in rural area
    
        choice = hard_rural_choice(move_temp.rural_not(asset_state_at_expr,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
        % this does a lot...so for the move policy, grab the values of matrix for
        % location rural, not experinced, then asset state, shock state.
        % this will return the cumulative probabilities greather than logit
        % shock. The first value is the choice this guy
        % will make. ALL with experiment!!!
        
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.
                    
        welfare(xxx,1) = cons_eqiv.rural_not(asset_state_at_expr,shock_states(xxx));
        % NEED to THINK ABOUT THIS. This is expected value, not of just who
        % move which will depend on shock. 
        
        labor_income(xxx,1) = z_rural.*r_shocks(shock_states(xxx));
        
        asset_state_p = assets_temp.rural_not(asset_state_at_expr,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
                    
        if move_seasn(xxx,1) == 1
            location(xxx+1) = 2;
            move_cost(xxx,1) = 0 ; % Mushfiq paid this!
        elseif move(xxx,1) == 1
            location(xxx+1) = 3;
            move_cost(xxx,1) = m;            
        end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if location(xxx) == 3 % in rural area
            
        choice = hard_rural_choice(move_temp.rural_exp(asset_state_at_expr,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
        % this does a lot...so for the move policy, grab the values of matrix for
        % location rural, experinced, then asset state, shock state.
        % this will return the cumulative probabilities greather than logit
        % shock. The first value is the choice this guy
        % will make. ALL with experiment!!!
     
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.
        
        welfare(xxx,1) = cons_eqiv.rural_exp(asset_state_at_expr,shock_states(xxx));
                
        labor_income(xxx,1) = z_rural.*r_shocks(shock_states(xxx));
        
        asset_state_p = assets_temp.rural_exp(asset_state_at_expr,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
                    
        if expr_shock(xxx) < (1-pi_prob)
            
            location(xxx+1) = 1; % loose experince
            % then check if they are moving and adjust. 
            
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 2;  
                move_cost(xxx,1) = 0; % Mushfiq paid this!
            elseif move(xxx,1) == 1
                location(xxx+1) = 5;
                move_cost(xxx,1) = m;
            end
        else 
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 4;  
                move_cost(xxx,1) = 0; % Mushfiq paid this!
            elseif move(xxx,1) == 1
                location(xxx+1) = 6;
                move_cost(xxx,1) = m;
            end
        end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

asset_state = asset_state_p;
    
assets(xxx+1,1) = asset_space(asset_state_p);
        
consumption(xxx,1) = labor_income(xxx,1) + R.*assets(xxx,1) - assets(xxx+1,1) - move_cost(xxx,1);

season(xxx,1) = mod(shock_states(xxx),2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for xxx = 2:length(shock_states)
    
    logit_shock = move_shock(xxx); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Work through stuff conditional on a location....
    %
    %                       NO-EXPERIENCE
    %
    if location(xxx) == 1 % rural area
        
        choice = hard_rural_choice(move_policy.rural_not(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
        % given the logit shock above, we just find which choice this guy
        % will make. 
        
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.
                
        labor_income(xxx,1) = z_rural.*r_shocks(shock_states(xxx));        
        asset_state_p = assets_policy.rural_not(asset_state,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
                    
        if move_seasn(xxx,1) == 1
            location(xxx+1) = 2;
            move_cost(xxx,1) = m_seasn;
        elseif move(xxx,1) == 1
            location(xxx+1) = 5;
            move_cost(xxx,1) = m;            
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    elseif location(xxx) == 2 % seasonal movers....
       
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
 
        asset_state_p = assets_policy.seasn_not(asset_state,shock_states(xxx));
                
       if pref_shock(xxx) < (1-lambda)
            location(xxx+1,1) = 3; % get experince
       else 
            location(xxx+1,1) = 1; 
       end
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       EXPERIENCE
    elseif location(xxx) == 3
        
        choice = hard_rural_choice(move_policy.rural_exp(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);       
        
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.
                
        labor_income(xxx,1) = z_rural.*r_shocks(shock_states(xxx));        
        asset_state_p = assets_policy.rural_exp(asset_state,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
        
        if expr_shock(xxx) < (1-pi_prob)
            
            location(xxx+1) = 1; % loose experince
            % then check if they are moving and adjust. 
            
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 2;  
                move_cost(xxx,1) = m_seasn;
            elseif move(xxx,1) == 1
                location(xxx+1) = 5;
                move_cost(xxx,1) = m;
            end
        else 
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 4; % 
                move_cost(xxx,1) = m_seasn;
            elseif move(xxx,1) == 1
                location(xxx+1) = 6;
                move_cost(xxx,1) = m;
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    
    elseif location(xxx) == 4
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
 
        asset_state_p = assets_policy.seasn_exp(asset_state,shock_states(xxx));
        
        location(xxx+1) = 3;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% URBAN GUYS!!!
    
    elseif location(xxx) == 5
        
        choice = hard_urban_choice(move_policy.urban_new(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
     
        move(xxx,1) = (choice == 2);
        move(xxx,1) = (choice == 2);
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
 
        asset_state_p = assets_policy.urban_new(asset_state,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
        
        if move(xxx,1) == 1 
            location(xxx+1,1) = 1; % Return to being rural...
            move_cost(xxx,1) = m;
        elseif pref_shock(xxx) < (1-lambda)
            location(xxx+1,1) = 6; % Lose the aversion to urban area
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% URBAN Experince GUYS....

    elseif location(xxx) == 6
        
        choice = hard_urban_choice(move_policy.urban_old(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);        
        
        move(xxx,1) = (choice == 2);
        % If choice equals 2, then move back.
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
 
        asset_state_p = assets_policy.urban_old(asset_state,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
        
        if move(xxx,1) == 1 
            location(xxx+1,1) = 3; % Return to being rural...
            move_cost(xxx,1) = m;
        end      
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    asset_state = asset_state_p;
    
    assets(xxx+1,1) = asset_space(asset_state_p);
            
    consumption(xxx,1) = labor_income(xxx,1) + R.*assets(xxx,1) - assets(xxx+1,1) - move_cost(xxx,1);
        
    season(xxx,1) = mod(shock_states(xxx),2);     
end

location = location(1:end-1,1);
assets = assets(1:end-1,1); 
% This is important. So this now generates assets
% % held at date t (not chosen). So one can construce the budget constraint.

live_rural = location == 1 | location == 2 | location == 3 | location == 4;
work_urban = location == 2 | location == 4 | location == 5 | location == 6;
experince = location == 3;

urban_skill = z_urban.*ones(length(labor_income),1);

 panel_expr = [labor_income, consumption, assets, live_rural, work_urban, move,...
     move_seasn, move_cost, season, welfare, urban_skill, experince, experiment_flag];

