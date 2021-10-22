function [move_vec_p, move_vec_all, A] = make_movevec(movepolicy, position, params)

move_vec_p = [];
count = 0;

A = [];
rural_A = [eye(params.n_shocks), eye(params.n_shocks); zeros(params.n_shocks), zeros(params.n_shocks)];
urban_A = zeros(params.n_shocks);

for xxx = 1:params.n_perm_shocks
    
    if isequal(position,xxx)
    
        foo = squeeze(movepolicy(xxx).rural_not(15,:,:));
  
        foo = [foo(:,1),  diff(foo,1,2)];
        foo = foo(:,1:2);

        move_vec_p = [move_vec_p ; foo(:)];
        A = blkdiag(A,rural_A);
    
        foo = squeeze(movepolicy(xxx).rural_exp(79,:,:));
    
        foo = [foo(:,1),  diff(foo,1,2)];
        foo = foo(:,1:2);

        move_vec_p = [move_vec_p ; foo(:)];
        A = blkdiag(A,rural_A);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        foo = squeeze(movepolicy(xxx).urban_new(86,:,:));

        foo = [foo(:,1),  diff(foo,1,2)];
        move_vec_p = [move_vec_p ; foo(:,1)];
        A = blkdiag(A,urban_A);
    
        foo = squeeze(movepolicy(xxx).urban_old(2,:,:));
    
        foo = [foo(:,1),  diff(foo,1,2)];
        move_vec_p = [move_vec_p ; foo(:,1)];
        A = blkdiag(A,urban_A);
    end
    
end

move_vec_all = [];

for xxx = 1:params.n_perm_shocks
    
        foo = squeeze(movepolicy(xxx).rural_not(15,:,:));
  
        foo = [foo(:,1),  diff(foo,1,2)];
        foo = foo(:,1:2);

        move_vec_all = [move_vec_all ; foo(:)];

        foo = squeeze(movepolicy(xxx).rural_exp(79,:,:));
    
        foo = [foo(:,1),  diff(foo,1,2)];
        foo = foo(:,1:2);

        move_vec_all = [move_vec_all ; foo(:)];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        foo = squeeze(movepolicy(xxx).urban_new(86,:,:));

        foo = [foo(:,1),  diff(foo,1,2)];
        move_vec_all = [move_vec_all ; foo(:,1)];

    
        foo = squeeze(movepolicy(xxx).urban_old(2,:,:));
    
        foo = [foo(:,1),  diff(foo,1,2)];
        move_vec_all = [move_vec_all ; foo(:,1)];
    
end