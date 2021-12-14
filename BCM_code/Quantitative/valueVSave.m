function [V,CV,Z] = valueV(parm, B, G)

V_mean = 1/(1-parm.beta)*((parm.yhat - parm.sub).^(1-parm.sigma)/(1-parm.sigma)); % a guess at the value function
V = V_mean*ones(1,length(parm.x)); %use the guess
VN = V;
VM = V;
CV  = parm.yhat;
ppV = spline(parm.x,V);


iter = 0; crit = 1; V_new = V; CV_new = CV; VN_new = VN; VM_new = VM;

while crit > parm.epsilon
    
    for i=1:length(parm.x)
        [CV_new(i),val] = fminbnd(@(c) objVSave(c,parm.x(i),parm,V), parm.sub,parm.x(i));
        if parm.x(i) - parm.F > min(parm.x)
        V_new(i) = max((parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i) - parm.F,'linear'))),-val);      
        elseif parm.x(i) - parm.F > parm.sub
             V_new(i) = max((parm.piG*G(i) + (1-parm.piG)*(interp1(parm.x,B,parm.x(i) - parm.F,'spline'))),-val);    
        else
            V_new(i) = -val;
        end
        Z(i) = -val;
    end
    V_equiv = ((1-parm.sigma)*(1-parm.beta)*V).^(1/(1-parm.sigma));
    V_new_equiv = ((1-parm.sigma)*(1-parm.beta)*V_new).^(1/(1-parm.sigma));
    [crit blah] = max(abs(V_equiv - V_new_equiv));
    [crit_c bla2]= max(abs( (CV - CV_new)./CV ));
    iter = iter+1;
    disp('iterating on V')
    disp(iter)
    disp(crit)
    V=V_new;
    CV = CV_new;
    ppV = spline(parm.x,V);
    
end
end

    
        