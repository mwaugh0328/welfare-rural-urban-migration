

clear
%parameter values
q=20% maximum number of Risk aversion levels.
for j=1:q;
disp(j)
parm.F = 10/4; %cost of migration
parm.piG = 0.5; %probability of being a good migrator
parm.m = (3.5/parm.piG - parm.F)*0.5; %the net return to migration
parm.sigma = j+1.5; %risk aversion
parm.I=8/4; %size of the incentive
parm.R = 1;% interest rate on savings

parm.beta = 0.99;%discount rate
parm.yhat = 7; % mean of income without migration
parm.sigma2 = 0.7; %standard deviation of income without migration
parm.states = 21; % number of state in income distribution without migration
parm.truncate = 2.6; %point at which income distribution is truncated
parm.sub = 2.5; %subsistence pointç

parm.epsilon = 1e-5; %accuracy for convergence
parm.xgrid = 300;%grid points

% generate income distribution
[s,p] = tauch_huss(parm.yhat, 0 , parm.sigma2, parm.states); % note that when we do this we have to make sure tha thte lowest income is greater than zero.
      parm.s1 = s'; 
      parm.p1 = p(1,:)';
     
      
% truncate income distribution
      
for i=1:parm.states;
    if parm.s1(i) >parm.truncate;
        s_check(i) = parm.s1(i);
    elseif parm.s1(i) <= parm.truncate;
    s_check(i) = parm.truncate;
    end
end
parm.s1= s_check;
clear s_check;

xlow = parm.truncate-0.05; %minimum asset level
xhigh = max(parm.s1)*4; %maximum asset level
parm.x=(xlow : (xhigh - xlow)/(parm.xgrid-1) :xhigh)'; %asset grid


%get the basic value functions
[G CG] = valueGSave(parm);
[B CB] = valueBSave(parm);
[V CV Z] = valueVSave(parm,B,G); %V is the value of not having migrated, Z is the value of not migrating

%now define the value of migrating
for i =1:length(parm.x);
    if parm.x(i) - parm.F > min(parm.x)
       M(i) = parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i) - parm.F,'linear'));      
    elseif parm.x(i) - parm.F > parm.sub
       M(i) = parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i) - parm.F,'spline'));    
    else
       M(i) = -inf;
end
end


%Value of Migration with teh Cash Incentive
for i =1:length(parm.x)
    if parm.x(i) - parm.F + parm.I > min(parm.x) & parm.x(i) + parm.I < max(parm.x)
       M_I(i) = parm.piG*(interp1(parm.x,G,parm.x(i)+parm.I,'linear')) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i)+parm.I - parm.F,'linear'));      
    elseif parm.x(i) - parm.F + parm.I > parm.sub
       M_I(i) = parm.piG*(interp1(parm.x,B,parm.x(i)+parm.I - parm.F,'spline')) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i)+parm.I - parm.F,'spline'));    
    else
       M_I(i) = -inf;
    end
end

%value of migrating with the Credit incentive.
for i =1:length(parm.x)
    if parm.x(i) - parm.F + parm.I > min(parm.x)
       M_Credit(i) = parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i)+parm.I - parm.F,'linear'));      
    elseif parm.x(i) - parm.F + parm.I > parm.sub
       M_Credit(i) = parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i)+parm.I - parm.F,'spline'));    
    else
       M_Credit(i) = -inf;
    end
end

M_UCT = M_I;
for i =1:length(parm.x)
    if parm.x(i) + parm.I < max(parm.x)
Z_UCT(i) = interp1(parm.x,Z,parm.x(i) + parm.I,'linear');
    else
Z_UCT(i) = interp1(parm.x,Z,parm.x(i) + parm.I,'spline','extrap');
    end
end

Migrate = (M >=Z);
if isempty(find(Migrate))==0;
cutpoint(j) = (parm.x(min(find(Migrate))))';
else 
    cutpoint(j) =0;
end

Migrate_I = (M_I >=Z);
if isempty(find(Migrate_I))==0;
cutpoint_I(j) = (parm.x(min(find(Migrate_I))))';
else 
    cutpoint_I(j) =0;
end


Migrate_Credit = (M_Credit >=Z);
if isempty(find(Migrate_Credit))==0;
cutpoint_Credit(j) = (parm.x(min(find(Migrate_Credit))))';
else 
    cutpoint_Credit(j) =0;
end

Migrate_UCT = (M_UCT >=Z_UCT);
if isempty(find(Migrate_UCT))==0;
cutpoint_UCT(j) = (parm.x(min(find(Migrate_UCT))))';
else 
    cutpoint_UCT(j) =0;
end


RA(j)=parm.sigma;
save (sprintf('Data/UtilityCostiteration_RA%1$d',j));

end


H = [0	0.34	2.02	6.38	15.93	26.15	40.22	53.12	66.02	75.57	83.78	87.63	89.98	92.66	95.01	95.85	96.69	97.53	97.87	98.54	98.54	98.71	99.05	99.22	99.39	99.39	99.56	99.73	99.73	99.9	99.9	99.9	100.07]; %histogram from control group
Y = [1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	32	33	34	35];
ppH = spline(Y,H);

figure = figure();
plot(RA,cutpoint,'blue', RA,cutpoint_I,'yellow',RA, cutpoint_Credit,'red',RA, cutpoint_UCT,'green');
hleg1 =  legend('No Incentive','Cash Incentive','Credit Incentive', 'UCT') ; 
xlabel('Risk Aversion')
ylabel('Assets Required to Migrate')
title('Asset Cutoff Point for Migration')
print(figure,'-dpdf',sprintf('Figures/WithSavingsUtiltyCost_Cutoffs.pdf'));
clear figure;

figure = figure();
plot(RA,ppval(ppH,cutpoint)-ppval(ppH,cutpoint_I),RA,ppval(ppH,cutpoint)-ppval(ppH,cutpoint_UCT))
hleg1 =  legend('Cash/Credit Incentive','UCT') ; 
xlabel('Risk Aversion')
ylabel('Portion of Households')
title('Portion of Households Induced To Migrate')
print(figure,'-dpdf',sprintf('Figures/WithSavingsUtilityCost_Induced.pdf'));
clear figure;

for j = 1:q
for i = 1:20
    if i==1
        induceable(j,i) = (normcdf(cutpoint(j),7,0.7) + 0.5*(1-normcdf(cutpoint(j),7,0.7)));
    else
        induceable(j,i) = induceable(j,i-1)*(normcdf(cutpoint(j),7,0.7) + 0.5*(1-normcdf(cutpoint(j),7,0.7)));
    end
end
end

t=[1:1:20];


WithSavingsPlotsUtilityCost;

% figure = figure();
% plot(t,induceable(1,:),t,induceable(2,:),t,induceable(3,:),t,induceable(4,:),t,induceable(5,:),t,induceable(6,:),t,induceable(7,:),t,induceable(8,:),t,induceable(9,:),t,induceable(10,:))
% hleg1 =  legend('RA:2.5','RA:3.5','RA: 4.5','RA:5.5','RA:6.5','RA:7.5','RA: 8.5','RA:9.5','RA:10.5','RA:11.5') ; 
% xlabel('Time Periods')
% ylabel('Portion of Households Induceable')
% title('Induceable Households Over Time')
% print(figure,'-dpdf',sprintf('Figures/WithSavings_Induceable.pdf'));
% clear figure;


