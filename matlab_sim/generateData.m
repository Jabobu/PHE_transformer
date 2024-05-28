clc; clear all; close all;

script_system_definition

num_simulations = 1000; % Number of simulations to run
total_timesteps = 10000; % Length of each simulation (time steps)

% Create arrays to store data for all simulations
all_u = zeros(num_simulations, total_timesteps);
all_y = zeros(num_simulations, total_timesteps);
all_z = zeros(num_simulations, total_timesteps, 3);
all_discrete_actions_taken = zeros(num_simulations, total_timesteps);
all_rewards = zeros(num_simulations, total_timesteps);

% For PID
integral_sum = 0;
last_error = 0;
Kp = 0.1;  % Example proportional gain
Ki = 0;  % Example integral gain
Kd = 0.05;   % Example derivative gain

for sim = 1:num_simulations
    % Randomly select simulation parameters
    start_current = randi([4, 20]);
    start_temp = (rand() < 0.5) * randi([10, 40]) + (rand() >= 0.5) * randi([41, 70]);
    num_of_shifts = randi([2, 8]);
    k_shifts = sort(randperm(total_timesteps-100, num_of_shifts) + 100);
    M_F_p_values = [0.6, 0.8];
    indices = randi([1, 2], 1, num_of_shifts);
    M_F_p_shifts = M_F_p_values(indices);

    % Initialize variables for each simulation
    u = ones(1, total_timesteps) * start_current;
    y = zeros(1, total_timesteps);
    y(1) = start_temp; % Set initial value for y
    z = zeros(total_timesteps, 3);
    z(1,:) = [start_current, start_temp, 90]; % Set initial values for z
    discrete_actions_taken = zeros(1, total_timesteps);
    rewards = zeros(1, total_timesteps);

    T_setpoint = 30;
    threshold = 1.5;

    % Define the discrete action space
    discrete_actions = [-5, -4.5, -4, -3.5, -3, -2.5, -2, -1.5, -1, -0.5, -0.25, -0.1, 0, 0.1, 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];

    for k = 2:1:total_timesteps
        % Check if the current timestep is a shift point
        if any(k == k_shifts)
            shift_index = find(k == k_shifts);
            M.F_p = M_F_p_shifts(shift_index);
            script_system_definition_shift;
        end
        
        % Calculate the temperature difference between the current temperature and the setpoint
        temp_diff = T_setpoint - y(k-1);
        
        % Adjust the current based on the temperature difference and store discrete action
        if abs(temp_diff) > threshold
            
            integral_sum = integral_sum + temp_diff;  % Update integral sum
            derivative = temp_diff - last_error;  % Derivative term based on rate of change of error
            last_error = temp_diff;  % Update last error for next iteration
            
            current_change = Kp * temp_diff + Ki * integral_sum + Kd * derivative;


            [~, action_index] = min(abs(discrete_actions - current_change));
            discrete_action = discrete_actions(action_index);
            discrete_actions_taken(k) = discrete_action;
            u(k) = u(k-1) + discrete_action;
            u(k) = max(min(u(k), 20), 4);
        else
            discrete_actions_taken(k) = 0;  % No action taken
            u(k) = u(k-1);
        end
        
        % Calculate the reward based on the temperature difference
        if abs(temp_diff) <= threshold
            rewards(k) = 10.0; % High positive reward for being within the desired range
        else
            if k > 2
                previous_temp_diff = abs(T_setpoint - y(k-2));
                current_temp_diff = abs(temp_diff);
                
                rewards(k) = (previous_temp_diff - current_temp_diff) / previous_temp_diff; % Scaled reward for moving away from the setpoint
                
            else
                rewards(k) = 0; % No reward for the first two timesteps (insufficient history)
            end
        end

        % Model evaluation
        d(k) = M.T_ec + M.rt*sin(k*(2*pi)/M.p); % Reservoir hot water temperature [°C]
        y(k) = PHE(u(k-1), y(k-1), d(k-1), M); % Output water temperature [°C]
        z(k,:) = [u(k), y(k) + M.N(u(k-1)), M.T_ec + M.d(k, u(k-1))]; % All signals
    end

    % Store the data for the current simulation
    all_u(sim,:) = u;
    all_y(sim,:) = y;
    all_z(sim,:,:) = z;
    all_discrete_actions_taken(sim,:) = discrete_actions_taken;
    all_rewards(sim,:) = rewards;
end

% Create a CSV file to store the data
csv_filename = 'simulation_dataPID2.csv';
csv_file = fopen(csv_filename, 'w');

% Write the CSV header
fprintf(csv_file, 'Simulation,Timestep,Temperature1,Temperature2,Current,Action,Reward,Terminal\n');

for sim = 1:num_simulations
    for k = 1:total_timesteps
        fprintf(csv_file, '%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%d\n', ...
            sim, k, all_z(sim,k,2),all_z(sim,k,3), all_u(sim,k), all_discrete_actions_taken(sim,k), ...
            all_rewards(sim,k), 0);
    end
    fprintf(csv_file, '%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%d\n', ...
        sim, total_timesteps, all_z(sim,total_timesteps,2),all_z(sim,total_timesteps,3), all_u(sim,total_timesteps), ...
        all_discrete_actions_taken(sim,total_timesteps), all_rewards(sim,total_timesteps), 1);
end

% Close the CSV file
fclose(csv_file);