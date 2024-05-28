function initial_temp = get_initial_temp()
    % Load or define the necessary variables (M.T_ec, M.rt, M.p) here
    % or make sure they are available in the MATLAB workspace
    script_system_definition
    
    initial_temp = M.T_ec + M.rt * sin(1 * (2*pi) / M.p);
end
