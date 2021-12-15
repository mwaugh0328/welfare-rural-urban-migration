function [B,CB] = valueB(parm)

B_mean = 1/(1-parm.beta)*((parm.yhat - parm.sub+parm.m).^(1-parm.sigma)/(1-parm.sigma)); % a guess at the value function
B = B_mean*ones(1,length(parm.x)); %use the guess
CB  = parm.x;
ppB = spline(parm.x,B);


iter = 0; crit = 1; B_new = B; CB_new = CB;

while crit > parm.epsilon
    
    for i=1:length(parm.x)
        [CB_new(i),val] = fminbnd(@(c) objB(c,parm.x(i),parm,ppB), parm.sub,parm.x(i));
        B_new(i) = -val;    
    end
    B_equiv = ((1-parm.sigma)*(1-parm.beta)*B).^(1/(1-parm.sigma));
    B_new_equiv = ((1-parm.sigma)*(1-parm.beta)*B_new).^(1/(1-parm.sigma));
    [crit blah] = max(abs(B_equiv - B_new_equiv));
    [crit_c bla2]= max(abs( (CB - CB_new)./CB ));
    iter = iter+1;
    disp('iterating on B')
    disp(B_equiv)
    disp(iter)
    disp(crit)
    B=B_new;
    CB = CB_new;
    ppB = spline(parm.x,B);
    
     %if abs(crit_c*100) < 1e-4
      %disp('howard iteration k=100')
       %  for k=1:100;
        %     G=-objG(CG,parm.x, parm, ppG);  
         %   ppG=spline(parm.x,G);
       %  end
    % end
end
end

    
        