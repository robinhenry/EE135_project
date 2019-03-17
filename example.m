clear; close all;

%Load MATPOWER test case.
msc = loadcase('case6ww');

%Extract admittance matrix from test case.
n = size(msc.bus, 1);
Y = makeYbus(msc);
%Y = [2 - 2*1i, 1; 1, 2 - 2*1i];

%Create vectors of constraints.
[P_min, P_max, Q_min, Q_max, V_min, V_max] = get_constraints(msc);

%Compute phi, psi and J, for all j.
[phi, psi, J] = transform_Y(Y);

%Example cost function (sum of |V|^2 of generators).
C = zeros(n);
for j = reshape(msc.gen(:, 1), 1, [])
   C(j, j) = 1; 
end

%SDP optimization.
cvx_begin SDP

    variable W(n,n) complex semidefinite;
    
    minimize( trace(phi(:, :, 1) * W) );
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
        
        %W >= 0;
cvx_end

rank(W)