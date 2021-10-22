function [social_welfare, rc, cfix] = effecient_aggregate(params,tfp,data_panel,flag)

params.alpha = 0.845;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This stuff is to figure out the correct scaling parameter.
% panel = [labor_income, consumption, assets, live_rural, work_urban, move, move_seasn, move_cost, season];

consumption = 1; live_rural = 2; work_urban = 3; move = 4;
move_season  = 5; movingcosts = 6; season = 7; welfare = 8; experince = 9; production = 10;
maringal_utility = 11;

% income = 1; consumption = 2; assets = 3; live_rural = 4; work_urban = 5;
% move = 6; move_season = 7; movingcosts = 8; season = 9; net_asset = 10;
% welfare = 11; experince = 12; fiscalcost = 13; tax = 14; production = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rural = data_panel(data_panel(:,live_rural)==1, :);
rural_not_monga = rural(rural(:,season)~=1, :);

seasonal_migrants = rural_not_monga(rural_not_monga(:,move_season) ==1, :);
avg_experince = sum(rural_not_monga(:, experince)==1)./length(rural_not_monga);

avg_rural = length(rural)./length(data_panel);
migrants = length(seasonal_migrants)./length(rural_not_monga);

if flag == 1
    
% [bin] = report_welfare_quintiles(mushfiqs_sample);
    
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Aggregate Statistics')
disp('')
disp('Average Rural Population')
disp(avg_rural)
disp('Seasonal Migrants')
disp(migrants)
disp('Experince')
disp(avg_experince)


% disp('Control Group, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption')
% disp((100.*[bin.welfare', bin.migration', bin.experince', 0.01.*bin.consumption']))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labor_units.rural.monga = (data_panel(:,work_urban)~=1 & data_panel(:,season)==1);
% this says, in monga, I'm working in rural area

labor_units.urban.monga = (data_panel(:,work_urban)==1 & data_panel(:,season)==1);
% this says, in monga, I'm working in urban area

labor_units.rural.notmonga = (data_panel(:,work_urban)~=1 & data_panel(:,season)==0);
% this says, NOT monga, I'm working in rural area

labor_units.urban.notmonga = (data_panel(:,work_urban)==1 & data_panel(:,season)==0);
% this says, NOT monga, I'm working in urban area

number_workers = sum(labor_units.rural.monga) + sum(labor_units.urban.monga);
% In the monga, this is the number of guys in total...


% outside of monga, number of guys in total...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
social_welfare = mean(data_panel(:, welfare));
rural_welfare = mean(data_panel(data_panel(:,live_rural)==1, welfare));
urban_welfare = mean(data_panel(data_panel(:,live_rural)~=1, welfare));

std_maringal_u.monga = std(data_panel(data_panel(:,season)==1, maringal_utility));
std_maringal_u.notmonga = std(data_panel(data_panel(:,season)~=1, maringal_utility));

if flag == 1

disp('Social Welfare: All, Rural, Urban')
disp([social_welfare, rural_welfare, urban_welfare])
disp('Standard Deviation of Marginal Utility')
disp([std_maringal_u.monga, std_maringal_u.notmonga])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
location = {'rural'; 'urban';'all'};
acct_measure = {'production', 'consumption','movingcosts','welfare'};
acct_measure_var = [production, consumption, movingcosts, welfare];
season = {'monga', 'notmonga'};

for xxx = 1:length(location)
    
    for yyy = 1:length(season)
        
        for zzz = 1:length(acct_measure)
            
            if xxx == 3
                
                accounting.(location{xxx}).(season{yyy}).(acct_measure{zzz}) = ...
                    accounting.urban.(season{yyy}).(acct_measure{zzz}) + accounting.rural.(season{yyy}).(acct_measure{zzz});
            end
            
            if xxx ~= 3
                
                foo = labor_units.(location{xxx}).(season{yyy});
           
                accounting.(location{xxx}).(season{yyy}).(acct_measure{zzz}) = sum(data_panel( foo, acct_measure_var(zzz)))./number_workers;
            
            end
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labor.supply.monga = sum((1./(params.rural_tfp.*tfp.monga)).*data_panel(labor_units.rural.monga, production))./number_workers;
% What is important here is embeded in the production measure is rural tfp
% and tfp in season. So net those out and that gives pure labor
% productivity.

labor.supply.notmonga = sum((1./(params.rural_tfp.*tfp.notmonga)).*data_panel(labor_units.rural.notmonga, production))./number_workers;

aggproduction.rural.monga = params.alpha.*tfp.monga.*params.rural_tfp.*(labor.supply.monga).^(params.alpha);
% Now given labor supply, just plug into the production function, with the
% factor share alpha in front. This is the absentee landlord model, so land
% rents are off some place, not redistributed. 

aggproduction.rural.notmonga = params.alpha.*tfp.notmonga.*params.rural_tfp.*(labor.supply.notmonga).^(params.alpha);
% same deal here.

aggproduction.urban.monga = sum(data_panel(labor_units.urban.monga,production))./number_workers;


aggproduction.urban.notmonga = sum(data_panel(labor_units.urban.notmonga,production))./number_workers;
% Urban stuff in the code is normalized to one. So just by adding up the
% guys we get production. 

resource_constriant.monga =  (accounting.all.monga.consumption + accounting.all.monga.movingcosts) - (aggproduction.rural.monga + aggproduction.urban.monga);

resource_constriant.notmonga = (accounting.all.notmonga.consumption + accounting.all.notmonga.movingcosts) - (aggproduction.rural.notmonga + aggproduction.urban.notmonga);

rc = [resource_constriant.monga ; resource_constriant.notmonga];

cfix = [((aggproduction.rural.monga + aggproduction.urban.monga) - accounting.all.monga.movingcosts)/accounting.all.monga.consumption; ...
        ((aggproduction.rural.notmonga + aggproduction.urban.notmonga) - accounting.all.notmonga.movingcosts)/accounting.all.notmonga.consumption];
    


if flag == 1
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Accounting')
disp('')
disp('Monga: Production, Consumption, Moving Costs')
disp([(aggproduction.rural.monga + aggproduction.urban.monga), accounting.all.monga.consumption, accounting.all.monga.movingcosts])
disp('Not Monga: Production, Consumption, Moving Costs')
disp([(aggproduction.rural.notmonga + aggproduction.urban.notmonga), accounting.all.notmonga.consumption, accounting.all.notmonga.movingcosts])
disp('Resource Constraint: Monga, Non Monga')
disp([resource_constriant.monga, resource_constriant.notmonga])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% labor.supply.monga = sum((1./params.rural_tfp).*data_panel(labor_units.rural.monga,production))./number_workers_monga;
% 
% labor.supply.notmonga = sum((1./params.rural_tfp).*data_panel(labor_units.rural.notmonga,production))./number_workers_not_monga; 
% 
% 
% if isempty(tfp) 
%     
%     tfp.monga = (params.seasonal_factor)./(params.alpha.*(labor.supply.monga).^(params.alpha-1));
% 
%     tfp.notmonga = (1./params.seasonal_factor)./(params.alpha.*labor.supply.notmonga.^(params.alpha-1));
% 
% end
% 
% 
% 
% labor.demand.monga = (wage.monga./(tfp.monga.*params.alpha)).^(1/(params.alpha-1));
% 
% labor.demand.notmonga = (wage.notmonga./(tfp.notmonga.*params.alpha)).^(1/(params.alpha-1));


% wage_monga = monga_productivity.*alpha.*(rural.labor_units_monga).^(alpha-1);
% 
% wage_not_monga = not_monga_productivity.*alpha.*(rural.labor_units_not_monga).^(alpha-1);





















