

%will you migrate without ongoing incentive (static model)

for j=1:100
F = 10.2/4;%cost of migration
piG = 0.5; %probability of success
m = 3.5/piG; %net return if successful
sigma = j*0.1+0.05; %risk aversion
I = 8/4 ; %size of the incentive
s = 2.5; %subsistence level

x=[s+F:0.01:30];

M = piG*(x-s+m).^(1-sigma)/(1-sigma) + (1-piG)*(x-s-F).^(1-sigma)/(1-sigma); %value of migration
for i=1:length(x);
    if x(i)-s -F <0
        M(i)= -inf;
    end
end
   
H = (x-s).^(1-sigma)/(1-sigma); %value of staying at home

M_I = piG*(x-s+m+I).^(1-sigma)/(1-sigma) + (1-piG)*(x-s-F+I).^(1-sigma)/(1-sigma); %value of migration with incentive
for i=1:length(x);
    if x(i)-s -F + I <0
        M_I(i)= -inf;
    end
end
M_Credit = piG*(x+m-s).^(1-sigma)/(1-sigma) + (1-piG)*(x-s-F+I).^(1-sigma)/(1-sigma); %value of migration with credit incentive
for i=1:length(x);
    if x(i)-s -F + I <0
        M_Credit(i)= -inf;
    end
end
M_UCT = piG*(x-s+m+I).^(1-sigma)/(1-sigma) + (1-piG)*(x-s-F+I).^(1-sigma)/(1-sigma); %value of migration with UCT
for i=1:length(x);
    if x(i)-s -F + I <0
        M_UCT(i)= -inf;
    end
end
H_UCT = (x-s+I).^(1-sigma)/(1-sigma); %value of staying at home with UCT

Z = (M>=H); %Z =1 if the household migrates at that level of cash
Z_I = (M_I>=H); %Z =1 if the household migrates at that level of cash with incentive
Z_Credit = (M_Credit>=H); %Z =1 if the household migrates at that level of cash with Credit incentive
Z_UCT = (M_UCT>=H_UCT); %Z =1 if the household migrates at that level of cash with UCT

%calculate level of cash required to migrate
if isempty(find(Z)) == 0; %%% note that this may be problematic if the matrix is empty.
    cutpoint(j) = (x(min(find(Z)))); %+ x(min(find(M))-1))/2;
else min(Z) ==0;
    cutpoint(j) =max(x);
end

if isempty(find(Z_I)) == 0; %%% note that this may be problematic if the matrix is empty.
    cutpoint_I(j) = (x(min(find(Z_I)))); %+ x(min(find(M))-1))/2;
else min(Z_I) ==0;
    cutpoint_I(j) =max(x);
end


if isempty(find(Z_Credit)) == 0; %%% note that this may be problematic if the matrix is empty.
    cutpoint_Credit(j) = (x(min(find(Z_Credit)))); %+ x(min(find(M))-1))/2;
else min(Z_Credit) ==0;
    cutpoint_Credit (j) =max(x);
end

if isempty(find(Z_UCT)) == 0; %%% note that this may be problematic if the matrix is empty.
    cutpoint_UCT(j) = (x(min(find(Z_UCT)))); %+ x(min(find(M))-1))/2;
else min(Z_UCT) ==0;
    cutpoint_UCT (j) =max(x);
end

RA(j) = sigma;
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
print(figure,'-dpdf',sprintf('Figures/Static_SubsistenceLow_Cutoffs.pdf'));
clear figure;

figure = figure();
plot(RA,ppval(ppH,cutpoint)-ppval(ppH,cutpoint_I),RA,ppval(ppH,cutpoint)-ppval(ppH,cutpoint_UCT),RA,100-ppval(ppH,cutpoint))
axis([0 5 0 90])
hleg1 =  legend('Cash/Credit Incentive','UCT','Background Migration') ; 
xlabel('Risk Aversion')
ylabel('Portion of Households')
title('Portion of Households Induced To Migrate')
print(figure,'-dpdf',sprintf('Figures/Static_SubsistenceLow_Induced.pdf'));
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
plot(t,induceable(1,:),t,induceable(3,:),t,induceable(6,:),t,induceable(9,:),'blue',t,induceable(12,:),t,induceable(15,:),t,induceable(18,:))
axis([0 20 0 1.1])
hleg1 =  legend('RA: 0.1','RA:0.3','RA:0.6','RA:0.9','RA:1.2','RA:1.5','RA:1.8') ; 
xlabel('Time Periods')
ylabel('Portion of Households Induceable')
title('Induceable Households Over Time')
print(figure,'-dpdf',sprintf('Figures/Static__SubsistenceLow_Induceable.pdf'));
clear figure;

