

clear
%parameter values
global V
for j=1:100;
parm.F = 10/4; %cost of migration
parm.piG = 0.5; %probability of being a good migrator
parm.m = 3.5/parm.piG; %the net return to migration
parm.sigma = j*0.1+0.05; %risk aversion
parm.I=8/4; %size of the incentive

parm.beta = 0.99;%discount rate
parm.yhat = 7; % mean of income without migration
parm.sigma2 = 3; %standard deviation of income without migration
parm.states = 21; % number of state in income distribution without migration
parm.truncate = 2; %point at which income distribution is truncated
parm.sub = 4; %subsistence pointç

parm.epsilon = 1e-3; %accuracy for convergence
parm.xgrid = 50;%grid points

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
xhigh = max(parm.s1)+0.1; %maximum asset level
parm.x=(xlow : (xhigh - xlow)/(parm.xgrid-1) :xhigh)'; %asset grid


%value of migration 
G = ((parm.x + parm.m - parm.sub).^(1-parm.sigma))/(1-parm.sigma) + parm.beta*( (((parm.s1+parm.m-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
B = (parm.x -parm.F - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*( (((parm.s1-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
for i=1:length(parm.x);
    if parm.x(i)-parm.F - parm.sub<0
        B(i)= -inf;
    end
end
M = parm.piG*G + (1-parm.piG)*B;

%value of migration with cash incentives
G_I = ((parm.x +parm.I+ parm.m - parm.sub).^(1-parm.sigma))/(1-parm.sigma) + parm.beta*( (((parm.s1+parm.m-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
B_I = (parm.x +parm.I -parm.F - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*( (((parm.s1-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
for i=1:length(parm.x);
    if parm.x(i)+parm.I-parm.F - parm.sub<0
        B_I(i)= -inf;
    end
end
M_I = parm.piG*G_I + (1-parm.piG)*B_I;

%value of migration with credit incentive
G_Credit = ((parm.x + parm.m - parm.sub).^(1-parm.sigma))/(1-parm.sigma) + parm.beta*( (((parm.s1+parm.m-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
B_Credit = (parm.x +parm.I -parm.F - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*( (((parm.s1-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
for i=1:length(parm.x);
    if parm.x(i)+parm.I-parm.F - parm.sub<0
        B_Credit(i)= -inf;
    end
end
M_Credit = parm.piG*G_Credit + (1-parm.piG)*B_Credit;

%value of migration with UCT
G_UCT = ((parm.x +parm.I+ parm.m - parm.sub).^(1-parm.sigma))/(1-parm.sigma) + parm.beta*( (((parm.s1+parm.m-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
B_UCT = (parm.x +parm.I -parm.F - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*( (((parm.s1-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
for i=1:length(parm.x);
    if parm.x(i)+parm.I-parm.F - parm.sub<0
        B_UCT(i)= -inf;
    end
end
M_UCT = parm.piG*G_UCT + (1-parm.piG)*B_UCT;


%Value of Staying at Home
V = valueVR(parm, M);

Z = (parm.x - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*(interp1(parm.x,V,parm.s1,'linear')*parm.p1);
Z_UCT = (parm.x+parm.I - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*(interp1(parm.x,V,parm.s1,'linear')*parm.p1);

for i=1:length(parm.x)
if M(i) ==-inf
M(i)= min(Z) -0.1;
end
end

for i=1:length(parm.x)
if M_I(i) ==-inf
M_I(i)= min(Z) -0.1;
end
end

for i=1:length(parm.x)
if M_Credit(i) ==-inf
M_Credit(i)= min(Z) -0.1;
end
end

for i=1:length(parm.x)
if M_UCT(i) ==-inf
M_UCT(i)= min(Z) -0.1;
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
print(figure,'-dpdf',sprintf('Figures/RepeatMigrationIncentiveHighSub_Cutoffs.pdf'));
clear figure;

figure = figure();
plot(RA,ppval(ppH,cutpoint)-ppval(ppH,cutpoint_I),RA,ppval(ppH,cutpoint)-ppval(ppH,cutpoint_UCT))
hleg1 =  legend('Cash/Credit Incentive','UCT') ; 
xlabel('Risk Aversion')
ylabel('Portion of Households')
title('Portion of Households Induced To Migrate')
print(figure,'-dpdf',sprintf('Figures/RepeatMigrationIncentiveHighSub_Induced.pdf'));
clear figure;

for j = 1:100
for i = 1:20
    if i==1
        induceable(j,i) = (normcdf(cutpoint(j),7,0.7) + 0.5*(1-normcdf(cutpoint(j),7,0.7)));
    else
        induceable(j,i) = induceable(j,i-1)*(normcdf(cutpoint(j),7,0.7) + 0.5*(1-normcdf(cutpoint(j),7,0.7)));
    end
end
end

t=[1:1:20];

figure = figure();
plot(t,induceable(10,:),t,induceable(15,:),t,induceable(20,:))
hleg1 =  legend('RA: 1','RA:1.5','RA:2') ; 
xlabel('Time Periods')
ylabel('Portion of Households Induceable')
title('Induceable Households Over Time')
print(figure,'-dpdf',sprintf('Figures/RepatMigrationIncentiveHighSub_Induceable.pdf'));
clear figure;


