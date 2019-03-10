clear; close all;

% Load MATPOWER test case.
msc = loadcase('case4gs');

% Extract admittance matrix from test case.
n = size(msc.bus, 1);
Y = makeYbus(msc);

% Create vectors of constraints.
[P_min, P_max, Q_min, Q_max, V_min, V_max] = get_constraints(msc);

% Compute phi, psi and J, for all j.
[phi, psi, J] = transform_Y(Y);

% Example cost function (sum of |V|^2 of generators).
C = zeros(n);
for j = reshape(msc.gen(:, 1), 1, [])
   C(j, j) = 1; 
end

% SDP optimization.
cvx_begin sdp

    variable W(n,n) semidefinite;
    expression p(n);
    expression q(n);
    expression v(n);
        
    for j = 1:n
       p(j, 1) = trace(squeeze(phi(j, :, :)) * W);
       q(j, 1) = trace(squeeze(psi(j, :, :)) * W);
       v(j, 1) = trace(squeeze(J(j, :, :)) * W);
    end
  
    minimize( trace(C * W) );
    subject to
        p   <= P_max;
        - p <= - P_min;
        q   <= Q_max;
        - q <= - Q_min;
        v   <= V_max;
        - v <= - V_min;
        W >= 0;
cvx_end

