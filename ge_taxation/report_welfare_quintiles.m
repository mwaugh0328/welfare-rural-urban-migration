function [bin] = report_welfare_quintiles_tax(data_panel)

% income_assets = [control_data(:,1,1), control_data(:,3,1), control_data(:,8,1), control_data(:,7,1), control_data(:,9,1), control_data(:,10,1)];
% 
% report_welfare_quintiles_GE
% 
% disp('Control Group, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Moving Cost')
% disp(round(100.*[welfare_bin, migration_bin, expr_bin, moving_cost_bin],2))

income = 1; consumption = 2; assets = 3; live_rural = 4; work_urban = 5;
move = 6; move_season = 7; movingcosts = 8; season = 9; net_asset = 10;
welfare = 11; experince = 12; fiscalcost = 13; tax = 14;



data_panel(:,[income,assets]) = data_panel(:,[income,assets]) + .0001.*randn(size(data_panel(:,[income,assets])));
% Add just a bit of noise to smooth stuf out...


income_prct = 20:20:80;
edges_income = prctile(data_panel(:,[income]),income_prct);
edges_income = [0, edges_income, 10];


welfare_bin = zeros(length(edges_income)-1,1);
migration_bin = zeros(length(edges_income)-1,1);
moving_cost_bin = zeros(length(edges_income)-1,1);
counts = zeros(length(edges_income)-1,1);

% income_gain_bin = zeros(length(edges_income)-1,1);
% cons_gain_bin = zeros(length(edges_income)-1,1);
% urban_bin = zeros(length(edges_income)-1,1);
expr_bin = zeros(length(edges_income)-1,1);

for xxx = 1:length(edges_income)-1
        
        income_yes = edges_income(xxx) <= data_panel(:,income) & ... 
        data_panel(:,income) < edges_income(xxx+1) ;        
        
        test = (income_yes == 1 );
%         test_migrate = (test ==1) & (income_assets(:,4) == 1);
        
        counts(xxx) = sum(test);
        
        bin.welfare(xxx) = mean(data_panel(test, welfare));
        
        bin.migration(xxx) = mean(data_panel(test,move_season));
        
        bin.movingcosts(xxx) = mean(data_panel(test,movingcosts));
        
        bin.consumption(xxx) = mean(data_panel(test,consumption));

        bin.experince(xxx) = mean(data_panel(test,experince));

end

test = 1;

%disp(sum(counts(:)))
%disp('Welfare by Income Quintile')
%disp(100.*welfare_bin)
