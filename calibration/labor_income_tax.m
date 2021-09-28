function [aftertax, taxout, production] = labor_income_tax(laborincome, tax, location)

% if location == 1 %ubran guys pay the tax

if isequal(tax.location,'all')
    
    production = laborincome;

    aftertax = tax.rate.*(laborincome).^(1-tax.prog);

    taxout = laborincome - aftertax;
end

if isequal(tax.location, 'urban')
    
    if isequal(location,'urban')
        
        production = laborincome;

        aftertax = tax.rate.*(laborincome).^(1-tax.prog);

        taxout = laborincome - aftertax;
    else
        production = laborincome;
 
        aftertax = laborincome;

        taxout = 0;
    end
end
        
    
% else %rural guys DONT pay the tax
%     

% end

