function [panel, states] = cal_rural_urban_simmulate(assets_policy, move_policy, ...
                    params, perm_types, shock_states, pref_shock, moveshock)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This simmulates a time series/cross section of variables that we can map
% to data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unpack parameters

asset_space = params.asset_space;

R = params.R; 

m = params.m;

m_seasn = params.m_season;

mtest = asset_space < params.means_test;
% this is the mass of people that don't have to pay
mtest_move_cost = m_seasn.*(~mtest)';
move_fiscal_cost = m_seasn - mtest_move_cost;

lambda = params.lambda;

pi_prob = params.pi_prob;

r_shocks = params.trans_shocks(:,1);
u_shocks = params.trans_shocks(:,2);

N_obs = params.N_obs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expr_shock = pref_shock;

z_rural = perm_types(1); z_urban = perm_types(2); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_series = length(shock_states);

shock_states = shock_states(1:end);

asset_state = 8; 
% The initial asset state....this should not matter as long as everything
% is ergodic.
asset_state_p = asset_state;

% The initial location state...
location = zeros(time_series+1,1); 
location(1) = 1;
% This will start the person in rural area, so 2 = urban, 1 = rural. This
% should not matter either. 

move = zeros(time_series,1);
move_seasn = zeros(time_series,1);
move_cost = zeros(time_series,1);
fiscal_cost = zeros(time_series,1);

labor_income = zeros(time_series,1);

consumption = zeros(time_series,1);
net_asset = zeros(time_series,1);
assets = zeros(time_series+1,1);
season = zeros(time_series,1);

assets(1,1) = asset_space(asset_state);

rec_asset_states = zeros(time_series+1,1); 
rec_asset_states(1,1) = asset_state;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin simmulation...

hard_rural_choice = cast([1,2,3],'uint8');
hard_urban_choice = cast([1,2],'uint8');

for xxx = 1:time_series
    
    logit_shock = moveshock(xxx); % this is the logit shock, each period.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Work through stuff conditional on a location....

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rural NO-EXPERIENCE

    if location(xxx) == 1 % rural area
        
        % first figure out where they are going        
        choice = hard_rural_choice(move_policy.rural_not(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
        % given the logit shock above, we just find which choice this guy
        % will make. 
        
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.

        %[labor_income(xxx,1), tax(xxx,1), production(xxx,1)] =...
        %    labor_income_tax(z_rural.*r_shocks(shock_states(xxx)), params.tax, 'rural');
        labor_income(xxx,1) = z_rural.*r_shocks(shock_states(xxx));
   
        asset_state_p = assets_policy.rural_not(asset_state,shock_states(xxx),choice);
        % asset state is policy, location (rural, not experinced), asset
        % state, shock state, then the choice from above. 
        
        location(xxx+1) = location(xxx);
                    
        if move_seasn(xxx,1) == 1
            location(xxx+1) = 2;
            move_cost(xxx,1) = mtest_move_cost(asset_state);
            fiscal_cost(xxx,1) = move_fiscal_cost(asset_state);
        elseif move(xxx,1) == 1
            location(xxx+1) = 5;
            move_cost(xxx,1) = m;            
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these are the seasonal moves with no experince.
        
    elseif location(xxx) == 2 % seasonal movers....

       
        %[labor_income(xxx,1), tax(xxx,1), production(xxx,1)] ...
        %    = labor_income_tax(z_urban.*u_shocks(shock_states(xxx)), params.tax, 'urban');
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        asset_state_p = assets_policy.seasn_not(asset_state,shock_states(xxx));
                
       if pref_shock(xxx) < (1-lambda)
           
            location(xxx+1,1) = 3; % back in rural, but get experince, 
            
       else 
            location(xxx+1,1) = 1; % go back to rural, no experince
       end
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RURAL EXPERIENCE

    elseif location(xxx) == 3

        choice = hard_rural_choice(move_policy.rural_exp(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
                
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.

        %[labor_income(xxx,1), tax(xxx,1), production(xxx,1)] =...
        %    labor_income_tax(z_rural.*r_shocks(shock_states(xxx)), params.tax, 'rural');
        labor_income(xxx,1) = z_rural.*r_shocks(shock_states(xxx));
        
        asset_state_p = assets_policy.rural_exp(asset_state,shock_states(xxx),choice);
        
        location(xxx+1) = location(xxx);
        
        if expr_shock(xxx) < (1-pi_prob)
            
            location(xxx+1) = 1; % loose experince
            % then check if they are moving and adjust. 
            
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 2; %Non experinced season (you lost it)
                move_cost(xxx,1) = mtest_move_cost(asset_state);
                fiscal_cost(xxx,1) = move_fiscal_cost(asset_state);
                
            elseif move(xxx,1) == 1
                location(xxx+1) = 5; % non experinces perm moves (you lost it)
                move_cost(xxx,1) = m;
            end
            
        else 
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 4; % retain experince, season move
                move_cost(xxx,1) = mtest_move_cost(asset_state);
                fiscal_cost(xxx,1) = move_fiscal_cost(asset_state);
                
            elseif move(xxx,1) == 1
                location(xxx+1) = 6; % retain experince perm move.
                move_cost(xxx,1) = m;
            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Experinced Seaonsal movers...

    elseif location(xxx) == 4
        
        %[labor_income(xxx,1), tax(xxx,1), production(xxx,1)] =...
        %    labor_income_tax(z_urban.*u_shocks(shock_states(xxx)), params.tax, 'urban');
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        asset_state_p = assets_policy.seasn_exp(asset_state,shock_states(xxx));
        
        location(xxx+1) = 3;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% URBAN GUYS...

    elseif location(xxx) == 5

        choice = hard_urban_choice(move_policy.urban_new(asset_state,shock_states(xxx),:) > logit_shock);
        choice = choice(1);
       
        move(xxx,1) = (choice == 2);
        % If choice equals 2, then move back.

        %[labor_income(xxx,1), tax(xxx,1), production(xxx,1)] =...
        %    labor_income_tax(z_urban.*u_shocks(shock_states(xxx)), params.tax, 'urban');
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        asset_state_p = assets_policy.urban_new(asset_state,shock_states(xxx),choice);

        location(xxx+1) = location(xxx);
        
        if move(xxx,1) == 1 
            location(xxx+1,1) = 1; % Return to being rural...
            move_cost(xxx,1) = m;
        end
        
        if pref_shock(xxx) < (1-lambda)
            
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

        %[labor_income(xxx,1), tax(xxx,1), production(xxx,1)] =...
        %    labor_income_tax(z_urban.*u_shocks(shock_states(xxx)), params.tax, 'urban');
        
        labor_income(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        asset_state_p = assets_policy.urban_old(asset_state,shock_states(xxx),choice);
        % asset state is policy, location (urban, EXPERINCE), asset
        % state, shock state, then the choice from above. 
        
        location(xxx+1) = location(xxx);
        
        if move(xxx,1) == 1 
            location(xxx+1,1) = 3; % Return to being rural...
            move_cost(xxx,1) = m;
        end      
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Record stuf to move to the next state!

    asset_state = asset_state_p;
    
    assets(xxx+1,1) = asset_space(asset_state_p);
    
    rec_asset_states(xxx+1,1) = asset_state_p;
        
    consumption(xxx,1) = labor_income(xxx,1) + R.*assets(xxx,1) - assets(xxx+1,1) - move_cost(xxx,1);
    
    net_asset(xxx,1) = R.*assets(xxx,1) - assets(xxx+1,1);
        
    season(xxx,1) = mod(shock_states(xxx),2);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Record the stuff....
% trans_shocks(shock_states,:); This is a way to see how transitory shocks
% matter. 
location = location(1:end-1,1);
assets = assets(1:end-1,1); 
rec_asset_states = rec_asset_states(1:end-1,1);

% This is important. So this now generates assets
% held at date t (not chosen). So one can construce the budget constraint.

live_rural = location == 1 | location == 2 | location == 3 | location == 4;

% live_rural asksi, if anyof these situations are true, then you live in
% the rural area, note 1-4 are rural guys who litterally are their or are
% out on a seaonsal move. 

% The work_urban, if any of these situations are true, then you are working
% in the urban area. Note location 2 and 4, these are rural guys on
% seasonal moves. 

panel = [labor_income, consumption, assets, live_rural, move_seasn, season];

states = [rec_asset_states, location, season, shock_states'];

panel = panel(time_series-(N_obs-1):end,:);
states = states(time_series-(N_obs-1):end,:);


