function [V,c,ppc,ppV, V_no] = valuev(parm, x, epsilon, ymean, yl, xgrid, ppG, ppB, G, B);


%returns the value of being able to migrate, but never having migrated
%before.  V is the value, c the policy functoin.  ppV is a splined version
%of V. M is a zero one indicating whether migration occurs and ppm is a
%plined versoin. V_no is the value of not being able to migrate.
c = min((parm.R-1)/parm.R*x + yl/parm.R,x);
V_mean = 1/(1-parm.beta)*((parm.R-1)/parm.R*x + ymean).^(1-parm.sigma)/(1-parm.sigma);

%use the guesses
V = V_mean;
ppV = spline(x,V);

%iterate until convergence
iter = 0; crit = 1; c_new = c; V_new = V;
while crit > epsilon
    for i = 1: xgrid
      [c_new(i), val] = fminbnd(@(c) objV(c,x(i),parm, V), parm.sub, x(i));
      if x(i) - parm.F < min(x)
      V_new(i) = max((parm.piG*G(i) + (1-parm.piG)*(ppval(ppB,x(i)-parm.F))-parm.UC),-val); %i am not 100% on what this should be - should it inlcude the cost and benefit of migration or not.  Incentive enters here conceptually.
      else
      V_new(i) = max((parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,x(i)-parm.F,'linear'))-parm.UC),-val);    
      end
      %M_new(i) = ((parm.piG*ppval(ppG,x(i)) + (1-parm.piG)*(ppval(ppB,x(i)-parm.F))-parm.UC)  > -val); %what guarantees that this is on the appropraite grid? 
      %M_new_I(i) = ((parm.piG*ppval(ppG,x(i)+parm.I) + (1-parm.piG)*(ppval(ppB,x(i)-parm.F+parm.I))-parm.UC)  > -val); 
      %M_new_Cond(i) = ((parm.piG*ppval(ppG,x(i)) + (1-parm.piG)*(ppval(ppB,x(i)-parm.F+parm.Cond))-parm.UC)  > -val); 
      %M_new_Cash(i) = ((parm.piG*ppval(ppG,x(i)+parm.Cash) + (1-parm.piG)*(ppval(ppB,x(i)-parm.F+parm.Cash))-parm.UC)  > -val); 
      V_no_new(i) = -val;
      
    end
    
    V_equiv     = ((1-parm.sigma)*(1-parm.beta)*V).^(1/(1-parm.sigma));
    V_new_equiv = ((1-parm.sigma)*(1-parm.beta)*V_new).^(1/(1-parm.sigma));
    [crit bla1]= max(abs( V_equiv - V_new_equiv ));
    [crit_c bla2]= max(abs( (c - c_new)./c )); crit_c= 100*(c_new(bla2) - c(bla2))/c(bla2);
    crit_percent= [V_new_equiv(bla1) - V_equiv(bla1)]*100/ymean;
    iter=iter+1;
    disp('iter on V')
    disp(iter)
    disp([crit_percent , crit_c*100]) ; % display iteration statissavetics in percentage + or -
        disp([x(bla1) , x(bla2)])  ; %displays where the action is on x-grid

    V=V_new; c=c_new; V_no = V_no_new; ppV=spline(x,V); % updates information after iteration
   
end

ppc = spline(x,c); % splines policy function%
%ppm = spline(x,M);