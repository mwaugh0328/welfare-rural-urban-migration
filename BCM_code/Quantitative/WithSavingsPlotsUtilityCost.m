%creates plots from Master_smallv2

%load the data
clear all;
clear -global;

for j = 1:14;
        load(sprintf('Data/UtilityCostiteration_RA%1$d',j));

	ppc = spline(parm.x,CV);

	p1_c(1) = parm.p1(1);

	for i = 2: length(parm.p1)
	    p1_c(i) = p1_c(i-1) +parm.p1(i);
	end
	
	p1_c(i) =1;

	for z= 1:10000;
   		t=0;
   		xx(1) = min(parm.x);
    		yy(1) = min(parm.x);
    		xcount = 0;
    		while xcount <=cutpoint(j);
        		t=t+1;
		        shock = rand;
		        index_shock = min(find(p1_c>shock));
		        yy(t+1) = parm.s1(index_shock);
		        cc(t) = ppval(ppc,xx(t));
      			xx(t+1) = parm.R*(xx(t) -cc(t)) + yy(t+1);
		        xcount = xx(t+1); %this implies that you will migrate in the next period, so if period =10 ten you save for 10 periods and migrate in the 11th.
    		end
    		periods(z) = t+1; %you migrate in the t+1st period.
		clear t xx yy cc xcount;
	end

	%count the portion of people that are still at home in any period.
	periods = sort(periods);
	[C,IA,IC] = unique(periods, 'last');

	for i = 1:length(C);
		departed(C(i)) = IA(i);
	end

	for i=2:max(periods);
		if departed(i) == 0;
			departed(i) = departed(i-1);
   		 end 
	end
	
	athome = length(periods) - departed;
	prop_athome = athome/length(periods); %proportion of people left at home.
	clear periods departed C IA IC;
 	if j ==1;
	        Prop_athome(j,:) = prop_athome;
        elseif size(Prop_athome,2) < length(prop_athome);
        	Prop_athome(:,length(prop_athome)) = 0;
        elseif length(prop_athome) < size(Prop_athome,2);
        	prop_athome(size(Prop_athome,2)) = 0;
        end
        Prop_athome(j,:) = prop_athome;
        Sigma(j) = parm.sigma;
end


prop_left = Prop_athome; %prop_left is a 3d array with first dimension for ra second for stdev and third for days.

%plots of migration probabilities
clear figure;

t=[1:1:length(prop_left(1,:))];
figure = figure();
plot(t,prop_left(1,:),t,prop_left(2,:),t,prop_left(3,:),t,prop_left(4,:),t,prop_left(5,:),t,prop_left(6,:),t,prop_left(7,:),t,prop_left(8,:),t,prop_left(9,:),t,prop_left(10,:),t,prop_left(11,:),t,prop_left(12,:),t,prop_left(13,:),t,prop_left(14,:));
axis([2 20 0 1.005]);
hleg1 =  legend('RA:2.5','RA:3.5','RA: 4.5','RA:5.5','RA:6.5','RA:7.5','RA: 8.5','RA:9.5','RA:10.5','RA:11.5','RA: 12.5','RA:13.5','RA:14.5','RA:15.5') ; 
xlabel('Time Periods');
ylabel('Portion of Population Induceable');
title(sprintf('Portion of Population Induceable'));
print(figure,'-dpdf',sprintf('Figures/WithSavingsUtilityCost_Induceable2.pdf',i)); %note that the title has to be set at the same time as sigma2
clear figure;






