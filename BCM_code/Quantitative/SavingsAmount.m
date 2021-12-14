%creates plots from Master_smallv2

%load the data
clear all;
clear -global;

for j = 1:40;
    disp(j)
        load(sprintf('Data/iteration_RA%1$d',j));

	ppc = spline(parm.x,CV);

	p1_c(1) = parm.p1(1);

	for i = 2: length(parm.p1)
	    p1_c(i) = p1_c(i-1) +parm.p1(i);
	end
	
	p1_c(i) =1;

	for t= 1:1000;
            xx(1) = min(parm.x);
    		yy(1) = min(parm.x);
            shock = rand;
		    index_shock = min(find(p1_c>shock));
		    yy(t+1) = parm.s1(index_shock);
		    cc(t) = ppval(ppc,xx(t));
            aa(t) = xx(t)-cc(t);
            xx(t+1) = parm.R*(xx(t) -cc(t)) + yy(t+1);	  
    end
        mean_assets(j) = mean(aa);
        RA(j) = parm.sigma;
		clear t xx yy cc aa;
        
end

mean_assets = mean_assets*1200

figure = figure();
plot(RA,mean_assets)
axis([0 10 1000 4000])
xlabel('Risk Averesion');
ylabel('Average Savings');
title(sprintf('predicted Average Savings'));
print(figure,'-dpdf',sprintf('Figures/WithSavings_SavingsAmounts.pdf',i)); %note that the title has to be set at the same time as sigma2
clear figure;
	