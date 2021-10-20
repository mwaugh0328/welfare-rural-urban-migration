function [bin] = report_welfare_quintiles(income_assets,urban_prd,expr_prd)

income_assets(:,[1,2]) = income_assets(:,[1,2]) + .0001.*randn(size(income_assets(:,[1,2])));
% Add just a bit of noise to smooth stuf out...

income_prct = 20:20:80;
edges_income = prctile(income_assets(:,1),income_prct);
edges_income = [0, edges_income, 10];

bin.welfare = zeros(length(edges_income)-1,1);

bin.migration = zeros(length(edges_income)-1,1);
counts = zeros(length(edges_income)-1,1);

bin.urban = zeros(length(edges_income)-1,1);
bin.expr = zeros(length(edges_income)-1,1);

for xxx = 1:length(edges_income)-1
        
        income_yes = edges_income(xxx) <= income_assets(:,1) & ... 
        income_assets(:,1) < edges_income(xxx+1) ;        
        
        test = (income_yes == 1 );
        %test_migrate = (test ==1) & (income_assets(:,4) == 1);
        
        counts(xxx) = sum(test);
        
        bin.welfare(xxx) = mean(income_assets(test,3));
        bin.migration(xxx) = mean(income_assets(test,4));

        bin.urban(xxx) = mean(urban_prd(test));
        bin.expr(xxx) = mean(expr_prd(test));

end

%disp(sum(counts(:)))
%disp('Welfare by Income Quintile')
%disp(100.*welfare_bin)
