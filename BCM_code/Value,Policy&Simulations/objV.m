function f=obj(c,x, parm, ppV)

u = (c-parm.sub).^(1-parm.sigma)/(1-parm.sigma);
x_prime = parm.R*(x-c)*ones(1,length(parm.s)) + ones(length(c),1)*parm.s;
fi= parm.beta*[ppval(ppV,x_prime)*parm.p];
ff = u + fi;
f = -ff;

