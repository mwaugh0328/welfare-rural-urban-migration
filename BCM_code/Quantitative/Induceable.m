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

clearvars -global
clear
for stdev = 1:4;
for j = 1:10;
 display(j);
global sigma beta yl yh R ppG ppB ppV s1 p1 m F piG sub look look2; 

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
 
sigma= j -0.6; 
beta=.98;
R=1;
piG=0.5;
F=10.2/4; 
m = 3.5-F; 
sub = 2;
xhat = 7;
sigma2 = 0.4+0.1*stdev;
states = 25;
truncate = 2.5;
epsilon = 1e-5;
lognormal = 0;
xgrid= 300; 
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
xhigh= 4*yh; xlow = max(sub,min(s1)); %need to think about the upper bound ...
x=(xlow : (xhigh - xlow)/(xgrid-1) :xhigh)';
parm.x=x;

% calculate the value function G

[G,c_G,ppc_G,ppG] = valuegv2(parm, x, epsilon, ymean,yl, xgrid);

% Calculate the value function B

[B,c_B,ppc_B,ppB] = valueb(parm, x, epsilon, ymean,yl, xgrid);

% Calculate the value function V

[V,c,ppc,ppV, V_no] = valuev(parm, x, epsilon, ymean,yl, xgrid, ppG, ppB, G, B);

% deermine whether migration takes place
ppV_no = spline(x,V_no);
M = ((parm.piG*ppval(ppG,x) + (1-parm.piG)*(ppval(ppB,x-parm.F))-parm.UC)  > V_no');
 M_Incentive = ((parm.piG*ppval(ppG,x +parm.I) + (1-parm.piG)*(ppval(ppB,x-parm.F +parm.I))-parm.UC)  > V_no');
 M_Credit = ((parm.piG*ppval(ppG,x) + (1-parm.piG)*(ppval(ppB,x-parm.F +parm.Cond))-parm.UC)  > V_no');
 M_UCT = ((parm.piG*ppval(ppG,x+parm.Cash) + (1-parm.piG)*(ppval(ppB,x-parm.F +parm.Cash))-parm.UC)  > ppval(ppV_no,x+parm.Cash));

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


% Work out how many time periods it takes, on average, to get over
% cutpoint.

for z= 1:10000;
    t=0;
    xx(1) = min(x);
    yy(1) = min(x);
    xcount = 0;
    while xcount <=cutpoint;
        t=t+1;
        shock = rand;
        index_shock = min(find(p1_c>shock));
        yy(t+1) = s1(index_shock);
        cc(t) = ppval(ppc,xx(t));
        xx(t+1) = R*(xx(t) -cc(t)) + yy(t+1);
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
%prop_athome(:,:,length(athome)) = 0;
%athome(size(prop_athome,3)) = 0;
prop_athome = athome/length(periods); %proportion of people left at home.
clear periods departed C IA IC;


xxq(1) = min(x);
yyq(1) = min(x);
for q=1:1000;
    shock = rand;
    index_shock = min(find(p1_c>shock));
    yyq(q+1) = s1(index_shock);
    ccq(q) = ppval(ppc,xxq(q)); %might want to think about what do do if we are out of x range.
    xxq(q+1) = R*(xxq(q) - ccq(q)) + yyq(q+1);   
end

q=q+1;
 ccq(q) = ppval(ppc,xxq(q));
 xx_mean(j,stdev) = mean(xxq);
 xx_iqr(j,stdev) = iqr(xxq);
 xx_std(j,stdev) = std(xxq);
 xx_min(j,stdev) = min(xxq);
 xx_max(j,stdev) = max(xxq);
 Sigma(j) = sigma;
 
 %save the data
 
save (sprintf('Data/iteration_RA%1$d_Stdev%2$d',j,stdev));
clear cutpoint;
clear prop_athome;

end
end

Cutoffs
