function [migration] = report_experiment(control_data, expermt_data, exprtype)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Migration Elasticity

if isequal(exprtype,'bus')

    N_obs = length(control_data);
    exp_index = [1,3,7,11];
    year = {'y1'; 'y2'; 'y4'; 'y5'};

    for xxx = 1:length(exp_index)
        
        temp_migrate_cntr = control_data(:,7,exp_index(xxx)) == 1;
        temp_migrate_expr = expermt_data(:,7,exp_index(xxx)) == 1;
        
        if xxx == 1
            migration.control_indicator.(year{xxx}) = temp_migrate_cntr;
            migration.experiment_indicator.(year{xxx}) = temp_migrate_expr;
        end
            

        migration.control.(year{xxx}) = sum(temp_migrate_cntr)./N_obs;

        migration.experiment.(year{xxx}) = sum(temp_migrate_expr)./N_obs;

        migration.elasticity.(year{xxx}) = migration.experiment.(year{xxx}) - migration.control.(year{xxx});
    
        if xxx > 1
        
            conditional_migr = control_data(:,7,1) == 1 & control_data(:,7,exp_index(xxx)) == 1;
        
            migration.control_cont.(year{xxx}) = sum(conditional_migr)./N_obs;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    migrate_year = 1;
    consume_year = 2;
    consumption = 2;

    temp_migrate_cntr = control_data(:,7,migrate_year) == 1;
    temp_migrate_expr = expermt_data(:,7,migrate_year) == 1;

    all_migration = [temp_migrate_cntr; temp_migrate_expr];

    not_control = [zeros(length(temp_migrate_cntr),1); ones(length(temp_migrate_expr),1)];

    first_stage_b = regress(all_migration, [ones(length(not_control),1), not_control]);

    predic_migration = first_stage_b(1) + first_stage_b(2).*not_control;

    consumption_noerror = [control_data(:,consumption,consume_year); expermt_data(:,consumption,consume_year)];

    migration.AVG_C = mean(consumption_noerror);

    OLS_beta = regress(consumption_noerror, [ones(length(predic_migration),1), all_migration]);
    migration.OLS = OLS_beta(2)./migration.AVG_C;

    LATE_beta = regress(consumption_noerror, [ones(length(predic_migration),1), predic_migration]);
    migration.LATE = LATE_beta(2)./migration.AVG_C ;

else
    
    N_obs = length(control_data);
    exp_index = [1,3];
    year = {'y1'; 'y2'};

    for xxx = 1:length(exp_index)
    
        temp_migrate_cntr = control_data(:,7,exp_index(xxx)) == 1;
        temp_migrate_expr = expermt_data(:,7,exp_index(xxx)) == 1;

        migration.control.(year{xxx}) = sum(temp_migrate_cntr)./N_obs;

        migration.experiment.(year{xxx}) = sum(temp_migrate_expr)./N_obs;

        migration.elasticity.(year{xxx}) = migration.experiment.(year{xxx}) - migration.control.(year{xxx});
    
    end
    
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%