function [labor, govbc, tfp, wages, welfare_stats] = ge_aggregate(params,data_panel,wages,tfp,flag)

wage.monga = wages(1);
wage.notmonga = wages(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This stuff is to figure out the correct scaling parameter.
% panel = [labor_income, consumption, assets, live_rural, work_urban, move, move_seasn, move_cost, season];

income = 1; consumption = 2; assets = 3; live_rural = 4; work_urban = 5;
move = 6; move_season = 7; movingcosts = 8; season = 9; net_asset = 10;
welfare = 11; experince = 12; fiscalcost = 13; tax = 14; production = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rurual_ind = data_panel(:,live_rural)==1;
rural = data_panel(data_panel(:,live_rural)==1, :);
rural_not_monga = rural(rural(:,season)~=1, :);

all_seasonal_migrants = rural_not_monga(rural_not_monga(:,move_season) ==1, :);
all_seasonal_migrants = length(all_seasonal_migrants)./length(rural_not_monga);

mushfiqs_sample = rural_not_monga(rural_not_monga(:,assets)<= params.means_test,:);

asset_prct = sum(rural_not_monga(:,assets)< params.means_test)./length(rural_not_monga(:,assets));

seasonal_migrants = mushfiqs_sample(mushfiqs_sample(:,move_season) ==1, :);
avg_experince = sum(mushfiqs_sample(:, experince)==1)./length(mushfiqs_sample);

avg_rural = length(rural)./length(data_panel);
musfiq_migrants = length(seasonal_migrants)./length(mushfiqs_sample);

wage_gap = mean((data_panel(~rurual_ind,1)))./mean((data_panel(rurual_ind,1)));

if flag == 1
    
[bin] = report_welfare_quintiles_tax(mushfiqs_sample);
    
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Aggregate Statistics')
disp('')
disp('Average Rural Population')
disp(avg_rural)
disp('Migrants, Mushfiqs Sample')
disp(musfiq_migrants)
disp('Migrants, Whole Population')
disp(all_seasonal_migrants)
disp('Wage Gap')
disp(wage_gap)
disp('Fraction of Rural with Access to Migration Subsity')
disp(asset_prct)
% disp('Experince, Control Group, Mushfiqs Sample')
% disp(avg_experince)
% disp('Consumption, Mushfiqs Sample')
% disp(mean(mushfiqs_sample(:,consumption)))

if min(bin.welfare) < -10
    %I'm proably reporting the value function
    
    disp('Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption')
    disp(([bin.welfare', 100.*bin.migration', 100.*bin.experince', 0.01.*bin.consumption']))
    disp('Mushfiqs Sample, Average Welfare')
    disp(mean(mushfiqs_sample(:,welfare)))
    
else
    disp('Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption')
    disp(round((100.*[bin.welfare', bin.migration', bin.experince', 0.01.*bin.consumption']),2))
    disp('Mushfiqs Sample, Average Welfare')
    disp(round(100.*mean(mushfiqs_sample(:,welfare)),2))
    
end
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
if flag == 1
welfare_stats.all = mean(data_panel(:, welfare));
welfare_stats.rural = mean(data_panel(data_panel(:,live_rural)==1, welfare));
welfare_stats.urban = mean(data_panel(data_panel(:,live_rural)~=1, welfare));

if welfare_stats.all < -10
    %I'm proably reporting the value function
    disp('Social Welfare: All, Rural, Urban')
    disp(round([welfare_stats.all, welfare_stats.rural, welfare_stats.urban],2))

else
    disp('Social Welfare: All, Rural, Urban')
    disp(round(100.*[welfare_stats.all, welfare_stats.rural, welfare_stats.urban],2))
    
end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
location = {'rural'; 'urban';'all'};
acct_measure = {'production','income', 'consumption','movingcosts', 'fiscalcost', 'tax', 'net_asset','welfare'};
acct_measure_var = [production, income, consumption,movingcosts, fiscalcost, tax, net_asset, welfare];
season_lbl = {'monga', 'notmonga'};

for xxx = 1:length(location)
    
    for yyy = 1:length(season_lbl)
        
        for zzz = 1:length(acct_measure)
            
            if xxx == 3
                
                accounting.(location{xxx}).(season_lbl{yyy}).(acct_measure{zzz}) = ...
                    accounting.urban.(season_lbl{yyy}).(acct_measure{zzz}) + accounting.rural.(season_lbl{yyy}).(acct_measure{zzz});
            end
            
            if xxx ~= 3
                
                foo = labor_units.(location{xxx}).(season_lbl{yyy});
           
                accounting.(location{xxx}).(season_lbl{yyy}).(acct_measure{zzz}) = sum(data_panel( foo , acct_measure_var(zzz)))./number_workers;
            
            end
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag == 1
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Accounting: HH Balance Sheet')
disp('')
disp('Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position')
disp(round([accounting.all.monga.production, accounting.all.monga.income, accounting.all.monga.consumption, accounting.all.monga.movingcosts, ...
    accounting.all.monga.fiscalcost, accounting.all.monga.tax, accounting.all.monga.net_asset],2))
disp('Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position')
disp(round([accounting.all.notmonga.production, accounting.all.notmonga.income, accounting.all.notmonga.consumption, accounting.all.notmonga.movingcosts,...
    accounting.all.notmonga.fiscalcost, accounting.all.notmonga.tax, accounting.all.notmonga.net_asset],2))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%labor.supply.monga = sum((1./params.rural_tfp).*data_panel(labor_units.rural.monga,production))./number_workers_monga;

labor.supply.monga = sum((1./(params.rural_tfp.*params.seasonal_factor)).*data_panel(labor_units.rural.monga,production))./number_workers;

%labor.supply.notmonga = sum((1./params.rural_tfp).*data_panel(labor_units.rural.notmonga,production))./number_workers_not_monga; 

labor.supply.notmonga = sum((1./(params.rural_tfp.*(1./params.seasonal_factor))).*data_panel(labor_units.rural.notmonga,production))./number_workers;


if isempty(tfp) 
    
    tfp.monga = (params.seasonal_factor)./(params.alpha.*(labor.supply.monga).^(params.alpha-1));

    tfp.notmonga = (1./params.seasonal_factor)./(params.alpha.*labor.supply.notmonga.^(params.alpha-1));
    
end

labor.demand.monga = (wage.monga./(tfp.monga.*params.alpha)).^(1/(params.alpha-1));

labor.demand.notmonga = (wage.notmonga./(tfp.notmonga.*params.alpha)).^(1/(params.alpha-1));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aggproduction.rural.monga = params.alpha.*tfp.monga.*params.rural_tfp.*(labor.supply.monga).^(params.alpha);

aggproduction.rural.notmonga = params.alpha.*tfp.notmonga.*params.rural_tfp.*(labor.supply.notmonga).^(params.alpha);

mpl.rural.monga = params.alpha.*tfp.monga.*params.rural_tfp.*(labor.supply.monga).^(params.alpha-1);

mpl.rural.notmonga = params.alpha.*tfp.notmonga.*params.rural_tfp.*(labor.supply.notmonga).^(params.alpha-1);

aggproduction.urban.monga = sum(data_panel(labor_units.urban.monga,production))./number_workers;

aggproduction.urban.notmonga = sum(data_panel(labor_units.urban.notmonga,production))./number_workers;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
urban = data_panel(data_panel(:,live_rural)~=1, :);
rural_not_monga_work_rural = rural((rural(:,season)~=1 & rural(:,work_urban)~=1), :);
rural_monga_work_rural = rural((rural(:,season)==1 & rural(:,work_urban)~=1), :);
rural_work_urban = rural(rural(:,work_urban)==1, :);

iwage.rural = (mpl.rural.monga.*sum((1./(params.rural_tfp.*params.seasonal_factor)).*rural_monga_work_rural(:,production)./number_workers) + ...
    mpl.rural.notmonga.*sum((1./(params.rural_tfp.*(1./params.seasonal_factor))).*rural_not_monga_work_rural(:,production)./number_workers) + ...
    sum(rural_work_urban(:,production)./number_workers)) ./ (length(rural)./number_workers);

iwage.urban = sum(urban(:,production)./number_workers)./(length(urban)./number_workers);

%disp('Implied Wage Gap')
%disp(iwage.urban./iwage.rural)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rc_monga = (aggproduction.rural.monga + aggproduction.urban.monga) - (accounting.all.monga.consumption + accounting.all.monga.movingcosts);

rc_not_monga = (aggproduction.rural.notmonga + aggproduction.urban.notmonga) - (accounting.all.notmonga.consumption + accounting.all.notmonga.movingcosts);

govbc = params.R.*(accounting.all.monga.tax - accounting.all.monga.fiscalcost) + (accounting.all.notmonga.tax - accounting.all.notmonga.fiscalcost); 

if flag == 1
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Production Side Accounting: Production, Consumption, Moving Costs')
disp(round([(aggproduction.rural.monga + aggproduction.urban.monga), accounting.all.monga.consumption, accounting.all.monga.movingcosts],2))
disp(round([(aggproduction.rural.notmonga + aggproduction.urban.notmonga), accounting.all.notmonga.consumption, accounting.all.notmonga.movingcosts],2))
disp('Resource Constraint (Production Side): Monga, Non Monga')
disp(round([rc_monga, rc_not_monga],2))
disp('Gov Budget Constraint')
disp(round([govbc],2))
disp('Tax rate in % on labor income')
disp(round([100.*(1-params.tax.rate)],2))

end


% wage_monga = monga_productivity.*alpha.*(rural.labor_units_monga).^(alpha-1);
% 
% wage_not_monga = not_monga_productivity.*alpha.*(rural.labor_units_not_monga).^(alpha-1);





















