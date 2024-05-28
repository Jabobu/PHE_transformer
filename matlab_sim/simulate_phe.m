function [new_state, reward] = simulate_phe(predicted_action, current_state, previous_state, new_timestep, k_shifts, M_F_p)
    % NOTE: current = k-1,  new = k

    % script_system_definition_shift;
    script_system_definition;

    % above line overwrites mfp so need to keep track of it as it changes 
    % (tracking done in python, input MFP for every timestep)
    M.F_p = M_F_p;

    T_setpoint = 30;
    threshold = 1.5;
    
    % Retrieve the current temperature and current from the current_state
    current_temp = current_state(1);
    current_current = current_state(2);
    current_d = current_state(3);

    % retrive previous temp for reward calc.
    previous_temp = previous_state(1);
    
    % Update the current based on the predicted action
    new_current = current_current + predicted_action;
    new_current = max(min(new_current, 20), 4);
    
    % Calculate the reward based on the temperature difference
    temp_diff = T_setpoint - current_temp;
    if abs(temp_diff) <= threshold
        reward = 10.0; % High positive reward for being within the desired range
    else
        if new_timestep > 2
            previous_temp_diff = abs(T_setpoint - previous_temp);
            current_temp_diff = abs(temp_diff);
            reward = (previous_temp_diff - current_temp_diff) / previous_temp_diff; % Scaled reward for moving away from the setpoint
        else
            reward = 0; % No reward for the first two timesteps (insufficient history)
        end
    end

    % Check if the current timestep is a shift point
    if any(new_timestep == k_shifts)
        M.F_p = M_F_p; % dis redundant 
        fprintf('Shift at timestep %d: M.F_p set to %f\n', new_timestep, M_F_p);
        script_system_definition_shift;
    end
    
    % Model evaluation
    new_d = M.T_ec + M.rt*sin(new_timestep*(2*pi)/M.p); % Reservoir hot water temperature [°C]
    new_temp = PHE(current_current, current_temp, current_d, M); % Output water temperature [°C] d_new should d_current!
    new_state = [new_temp, new_current, new_d]; % All signals with no sum
    
    % Return the new state (temp, current, d), and reward.
    % the returned reward is for the previous action right?

end