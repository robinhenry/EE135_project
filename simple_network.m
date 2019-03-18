% This script compute the SDP convex relaxation of a  
% simple 2-bus power grid.

clear; close all;

% Load MATPOWER test case.
msc = loadcase('case6ww');

% Keep only 2 buses.
n = 2;
new_msc = msc;

% Create simple 2-bus network.
new_msc.bus = [1, 3, 0, 0, 0, 0, 1, 1.05, 0., 230, 1, 10, 0 ;
               2, 1, 5, 5, 0, 0, 1, 1., 0., 230, 1, 10, 0 ];
new_msc.gen = [1, 0, 0, 100, -100, 1.05, 100, 1, 100, 0];
new_msc.branch = [1, 2, 1, 0, 0, 60, 60, 60, 0, 0, 1, -360, 360];
new_msc.gencost = [2, 0, 0, 1, 1, 0];

% Get admittance matrix
Y = makeYbus(new_msc);

% Create vectors of constraints.
[P_min, P_max, Q_min, Q_max, V_min, V_max] = get_constraints(new_msc, false);

% Compute phi, psi and J, for all j.
[phi, psi, J] = transform_Y(Y);

% SDP optimization.
cvx_begin SDP

    variable W(n,n) complex semidefinite;
    
    % Cost function is p_1 + p_2 (total real power loss).
    minimize( trace(phi(:, :, 1) * W) + trace(phi(:, :, 2) * W) );
    subject to
        for j = 1:n
            p_j = trace(phi(:, :, j) * W);
            q_j = trace(psi(:, :, j) * W);
            v_j = trace(J(:, :, j) * W);
            
            p(j) = p_j;
            q(j) = q_j;
            v(j) = v_j;
            
            % Constraints
            p_j   <= P_max(j);
            - p_j <= - P_min(j);
            q_j   <= Q_max(j);
            - q_j <= - Q_min(j);
            v_j   <= V_max(j);
            - v_j <= - V_min(j);
            
        end
        
cvx_end

rank(W)