function [movepolicy] = make_movepolicy(move_vec,position,params)

n_shocks = params.n_shocks;

if isempty(position)
    for xxx = 1:params.n_perm_shocks

        foo = [reshape(move_vec(1:n_shocks*2),n_shocks,2), 1-sum(reshape(move_vec(1:n_shocks*2),n_shocks,2),2)];
        movepolicy(xxx).rural_not = cumsum(foo,2);

        move_vec(1:n_shocks*2) = [];
    
        foo = [reshape(move_vec(1:n_shocks*2),n_shocks,2), 1-sum(reshape(move_vec(1:n_shocks*2),n_shocks,2),2)];
        movepolicy(xxx).rural_exp = cumsum(foo,2);

    
        move_vec(1:n_shocks*2) = [];
    
        foo = [reshape(move_vec(1:n_shocks),n_shocks,1), 1-sum(reshape(move_vec(1:n_shocks),n_shocks,1),2)];
        movepolicy(xxx).urban_new = cumsum(foo,2);
    
        move_vec(1:n_shocks) = [];
    
        foo = [reshape(move_vec(1:n_shocks),n_shocks,1), 1-sum(reshape(move_vec(1:n_shocks),n_shocks,1),2)];
        movepolicy(xxx).urban_old = cumsum(foo,2);
    
    
        move_vec(1:n_shocks) = [];
        
    end
else
    xxx = position;

        foo = [reshape(move_vec(1:n_shocks*2),n_shocks,2), 1-sum(reshape(move_vec(1:n_shocks*2),n_shocks,2),2)];
        movepolicy(xxx).rural_not = cumsum(foo,2);

        move_vec(1:n_shocks*2) = [];
    
        foo = [reshape(move_vec(1:n_shocks*2),n_shocks,2), 1-sum(reshape(move_vec(1:n_shocks*2),n_shocks,2),2)];
        movepolicy(xxx).rural_exp = cumsum(foo,2);

    
        move_vec(1:n_shocks*2) = [];
    
        foo = [reshape(move_vec(1:n_shocks),n_shocks,1), 1-sum(reshape(move_vec(1:n_shocks),n_shocks,1),2)];
        movepolicy(xxx).urban_new = cumsum(foo,2);
    
        move_vec(1:n_shocks) = [];
    
        foo = [reshape(move_vec(1:n_shocks),n_shocks,1), 1-sum(reshape(move_vec(1:n_shocks),n_shocks,1),2)];
        movepolicy(xxx).urban_old = cumsum(foo,2);
    
    
        move_vec(1:n_shocks) = [];
end