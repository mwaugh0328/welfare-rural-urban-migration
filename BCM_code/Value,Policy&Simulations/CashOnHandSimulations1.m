% Draws Value Functions for first revision of Monga paper for Econometrica.

% Models buffer stock/ investment decision for monga paper.


%   Strategy:  The value functoin is
%       V(x) = \{ max_{c} u(c) + \beta E V(R(x-c) + y(s)) , \pi_G G(x+m - F) + (1-\pi_G) B (x-F)\}   
%
%   where:
%       
%       G(x) = \max_{c} u(c) + \beta E G(R(x-c -F + m) + y(s))
% and
%       B(x) = \max_{c} u (c) + \beta E B(R(x-c)+ y(s))
% 
%   Strategy is to compute G and B and then to simply plug them in.
%
%define the parameters
%clear
%clearvars -global


global sigma beta yl yh R ppG ppB ppV s1 p1 m F piG sub; 

% sigma: risk aversion
% beta: discount rate
% yl: lowest possible income 
% R: = gross return on savings
% ppg: is the value function in the good state (on a spline)
% ppb: is the value function in the bad state (on a spline)
% s1: set of labor income states
% p1: probabilities of labor income states
% m: is how much more you earn each period if you discover that you are
% good at migrating - it is a certain return
% pig: probability of realizing the good state
% F: is the cost of migrating
% we assume a nomrally distributed income process.
% xhat: mean of the labor income
% sigma2 : standard deviation of labor income
% states: number of states
%sub: subsistence requirement
% set the parameters: make sure beta*R <1 (recall this is a buffer stock model)
%lognormal: = 1 if we want a log normal distribution
%xgrid: how many points in the asset grid.
%UC: utility cost of migrating - this is very hard to define because it
%will depend, by in large on the utility function - we can try to define
%it as the solution to an equation?
% I : incentive size
%Cond: size of credit transfer - i.e. conditional on having a bad state.
%cash: the size of the cash bonus.
%truncate is teh point at whic the distribution is truncated.
 
sigma= 4; 
beta=.8;
R=1;
piG=0.5;
F=10.5/4; 
m = 2; 
sub = 0;
xhat = 4.5;
sigma2 = 0.3;
states = 25;
truncate = 1
epsilon = 1e-5;
lognormal = 0;
xgrid= 50; 
DollarCost = 0; %dollar cost of the utility cost
z=sym('z','real');
UC = 0 %solve((xhat + DollarCost)^(1-sigma)/(1-sigma) - z == (xhat)^(1-sigma)/(1-sigma), z); 
%UC = double(UC); 
I = 6/4;
Cond = 6/4; %note that this should not be positive at the same time as I.
Cash = 6/4; % this also should never be positive at the same time as I and Cond.



%calculate states

if lognormal == 1;
    [s,p] = tauch_huss(log(xhat- sigma2^2/2), 0 , sigma2, states); % note that when we do this we have to make sure tha thte lowest income is greater than zero.
    s1 = exp(s');
    p1 = p(1,:)';
else
     [s,p] = tauch_huss(xhat, 0 , sigma2, states); % note that when we do this we have to make sure tha thte lowest income is greater than zero.
      s1 = s'; 
      p1 = p(1,:)';
end

%truncate the distribution
for i=1:states;
    if s1(i) >truncate;
        s_check(i) = s1(i);
    elseif s1(i) <= truncate;
    s_check(i) = truncate;
end
end
s1= s_check;
clear s_check p_check; 

%create parameter space


parm.R = R;
parm.beta = beta;
parm.sigma = sigma;
parm.p = p1;
parm.s=s1;
parm.sub = sub;
parm.F = F;
parm.m=m;
parm.piG = piG;
parm.UC = UC;
parm.I = I;
parm.Cond = Cond; 
parm.Cash = Cash;

ymean=s1*p1; %for later use
yl=min(s1); yh=max(s1);  % to determine the bounds on teh asset grid
xhigh= 20; xlow = max(sub,min(s1)); %need to think about the upper bound ...
x=(xlow : (xhigh - xlow)/(xgrid-1) :xhigh)';

% calculate the value function G

[G,c_G,ppc_G,ppG] = valuegv2(parm, x, epsilon, ymean,yl, xgrid);

% Calculate the value function B

[B,c_B,ppc_B,ppB] = valueb(parm, x, epsilon, ymean,yl, xgrid);

% Calculate the value function V

[V,c,ppc,ppV, V_no] = valuev(parm, x, epsilon, ymean,yl, xgrid, ppG, ppB);

% deermine whether migration takes place
ppV_no = spline(x,V_no);
M = ((parm.piG*ppval(ppG,x) + (1-parm.piG)*(ppval(ppB,x-parm.F))-parm.UC)  > V_no');
   
% calculate the interpolated value of cash on hand for which migration
% takes place

if isempty(find(M)) == 0; %%% note that this may be problematic if the matrix is empty.
    cutpoint = (x(min(find(M)))); %+ x(min(find(M))-1))/2;
elseif min(M) ==0;
    cutpoint =0;
else
    cutpoint = max(x) + 10; %% not sure where to put cutpoint if it is that you never go in the set of values of x.
end



p1_c(1) = p1(1);

for i = 2: length(p1)
    p1_c(i) = p1_c(i-1) +p1(i);
end
p1_c(i) =1;

%we simulate three things.  The time series of cash on hand, assuming that
%you can migrate but never.  The time series assuming that migration is not
%an option.  Finally, the full model.

%initial cash on hand



xx_CB(1) = 5;
xx_CG(1) = 5;
yy(1) = min(x);
CG_t(1) = 0;
CB_t(1) = 0;
 CB = 0;
    CG=0;


xxH_CB(1) = 5.5;
xxH_CG(1) = 5.5;
CGH_t(1) = 0;
CBH_t(1) = 0;
 CBH = 0;
    CGH=0;    

for t=1:50;
    
    shock = rand;
    index_shock = min(find(p1_c>shock));
    yy(t+1) = s1(index_shock);

    
    if CB ==1;
        cc_CB(t) = ppval(ppc_B,xx_CB(t));
        xx_CB(t+1) = R*(xx_CB(t) - cc_CB(t)) + yy(t+1);
    elseif CB ==0 & xx_CB(t) < cutpoint;
        cc_CB(t) = ppval(ppc,xx_CB(t));
        xx_CB(t+1) =  R*(xx_CB(t) - cc_CB(t)) + yy(t+1);
    else 
        cc_CB(t) = ppval(ppc_B,xx_CB(t)-parm.F);
        xx_CB(t+1) = R*(xx_CB(t) - parm.F - cc_CB(t)) + yy(t+1);
        CB =1;
    end
    CB_t(t+1) = CB;
    
    if CG ==1;
        cc_CG(t) = ppval(ppc_G,xx_CG(t));
        xx_CG(t+1) = R*(xx_CG(t) + parm.m - cc_CG(t)) + yy(t+1);
    elseif CG ==0 & xx_CG(t) < cutpoint;
        cc_CG(t) = ppval(ppc,xx_CG(t));
        xx_CG(t+1) =  R*(xx_CG(t) - cc_CG(t)) + yy(t+1);
    else 
        cc_CG(t) = ppval(ppc_G,xx_CG(t));
        xx_CG(t+1) = R*(xx_CB(t)+parm.m  - cc_CB(t)) + yy(t+1);
        CG =1;
    end
     CG_t(t+1) = CG;
    

    if CBH ==1;
        ccH_CB(t) = ppval(ppc_B,xxH_CB(t));
        xxH_CB(t+1) = R*(xxH_CB(t) - ccH_CB(t)) + yy(t+1);
    elseif CBH ==0 & xxH_CB(t) < cutpoint;
        ccH_CB(t) = ppval(ppc,xxH_CB(t));
        xxH_CB(t+1) =  R*(xxH_CB(t) - ccH_CB(t)) + yy(t+1);
    else 
        ccH_CB(t) = ppval(ppc_B,xxH_CB(t)-parm.F);
        xxH_CB(t+1) = R*(xxH_CB(t) - parm.F - ccH_CB(t)) + yy(t+1);
        CBH =1;
    end
    CBH_t(t+1) = CBH;
    
    if CGH ==1;
        ccH_CG(t) = ppval(ppc_G,xxH_CG(t));
        xxH_CG(t+1) = R*(xxH_CG(t) + parm.m - ccH_CG(t)) + yy(t+1);
    elseif CGH ==0 & xxH_CG(t) < cutpoint;
        ccH_CG(t) = ppval(ppc,xxH_CG(t));
        xxH_CG(t+1) =  R*(xxH_CG(t) - ccH_CG(t)) + yy(t+1);
    else 
        ccH_CG(t) = ppval(ppc_G,xxH_CG(t));
        xxH_CG(t+1) = R*(xxH_CB(t)+ parm.m - ccH_CB(t)) + yy(t+1);
        CGH =1;
    end
     CGH_t(t+1) = CGH;
    
    
end

t=t+1;
cc_CB(t) = ppval(ppc_B,xx_CB(t));
if CG == 1;
cc_CG(t) = ppval(ppc_G,xx_CG(t));
else
    cc_CG(t) = ppval(ppc_B,xx_CG(t));
end
if CGH==1;    
ccH_CG(t) = ppval(ppc_G,xxH_CG(t));
else
    ccH_CG(t) = ppval(ppc_B,xxH_CG(t));
end


%now plot the series

z=[1:1:t];
cutpoint = cutpoint*ones(t,1);

figure = figure();
plot(z,xx_CG,'blue',z,xxH_CG,'red',z,cutpoint,'black');
hleg1 =  legend('COH Low Wealth', 'COH High Wealth','Migration Cutoff') ; grid
title('Simulated Cash On Hand');
xlabel('Time Period');
ylabel('Cash On Hand');
print(figure,'-dpdf',sprintf('Figures/Simulation_COH.pdf'));
clear figure

figure = figure();
plot(z,cc_CG,'blue',z,ccH_CG,'red')
hleg1 =  legend('COH Low Wealth', 'COH High Wealth') ; grid
title('Simulated Consumption');
xlabel('Time Period');
ylabel('Consumption');
print(figure,'-dpdf',sprintf('Figures/Simulation_Consumption.pdf'));
clear figure

