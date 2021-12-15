function f=obj(c,x, parm, ppG)
u = (c-parm.sub).^(1-parm.sigma)/(1-parm.sigma);
x_prime = parm.R*(x-c+ parm.m)*ones(1,length(parm.s1)) + ones(length(c),1)*(parm.s1); %ones gives a vecotr of ones of length the same as s1 first one is a column second one a row
fi= parm.beta*[ppval(ppG,x_prime)*parm.p1]; %% ppval returns the values of the spline along the points of x_prime%
ff = u + fi;
f = -ff;

