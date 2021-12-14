function V = valueVR(parm, M)


V_mean = 1/(1-parm.beta)*((parm.yhat - parm.sub).^(1-parm.sigma)/(1-parm.sigma)); % a guess at the value function
V = V_mean*ones(1,length(parm.x)); %use the guess
ppV = spline(parm.x,V);

iter = 0; crit = 1; V_new = V; 

while crit > parm.epsilon
    
    for i=1:length(parm.x)
        Value(i) = max((parm.x(i)-parm.sub)^(1-parm.sigma)/(1-parm.sigma) + parm.beta*(interp1(parm.x,V,parm.s1,'linear')*parm.p1),M(i));
    end
    V_new = Value;
    V_equiv = ((1-parm.sigma)*(1-parm.beta)*V).^(1/(1-parm.sigma));
    V_new_equiv = ((1-parm.sigma)*(1-parm.beta)*V_new).^(1/(1-parm.sigma));
    [crit blah] = max(abs(V_equiv - V_new_equiv));
    iter = iter+1;
    disp(iter)
    disp(crit)
    V=V_new;
end

    
        