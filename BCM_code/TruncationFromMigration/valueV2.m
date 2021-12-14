function [V,CV,VN,VM] = valueV(parm, ppB, ppG)

V_mean = 1/(1-parm.beta)*((parm.yhat - parm.sub+parm.m).^(1-parm.sigma)/(1-parm.sigma)); % a guess at the value function
V = V_mean*ones(1,length(parm.x)); %use the guess
VN = V;
VM = V;
CV  = parm.x;
ppV = spline(parm.x,V);


iter = 0; crit = 1; V_new = V; CV_new = CV; VN_new = VN; VM_new = VM;

while crit > parm.epsilon
    
    for i=1:length(parm.x)
        [CV_new(i),val] = fminbnd(@(c) objV(c,parm.x(i),parm,ppV), parm.sub,parm.x(i));
        if parm.x(i) - parm.F > parm.sub
        V_new(i) = max((parm.piG*ppval(ppG,parm.x(i)) + (1-parm.piG)*(ppval(ppB,parm.x(i)-parm.F))),-val);      
        else
            V_new(i) = -val;
        end
        VN_new(i) = -val;
        if parm.x(i) - parm.F > parm.sub
        VM_new(i) = (parm.piG*ppval(ppG,parm.x(i)) + (1-parm.piG)*(ppval(ppB,parm.x(i)-parm.F)));      
        else
            VM_new(i) = -inf;
        end
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
    VN = VN_new;
    VM= VM_new;
    ppV = spline(parm.x,V);
    
     %if abs(crit_c*100) < 1e-4
      %disp('howard iteration k=100')
       %  for k=1:100;
        %     G=-objG(CG,parm.x, parm, ppG);  
         %   ppG=spline(parm.x,G);
       %  end
    % end
end
end

    
        