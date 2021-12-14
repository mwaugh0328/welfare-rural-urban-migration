function f=obj(c,x1, parm, V)

u = (c-parm.sub).^(1-parm.sigma)/(1-parm.sigma);
x_prime = parm.R*(x1-c)*ones(1,length(parm.s)) + ones(length(c),1)*parm.s;
fi= parm.beta*[interp1(parm.x,V,x_prime,'linear')*parm.p];
ff = u + fi;
f = -ff;

