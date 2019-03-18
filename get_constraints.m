function [P_min, P_max, Q_min, Q_max, V_min, V_max] = get_constraints(msc, include_slack)
% This function returns vectors of contraints on P, Q and |V|^2 for a
% given MATPOWER test case. Lower and upper bounds are set to the same
% value for given (constant) variables.
%
% Inputs:
%   msc : MATPOWER case.
%   include_slack : set to true to fix the voltage at the slack bus; false
%                   to ignore it. 
%
% Outputs:
%   (nx1) vectors of contraints, where elem i are the constraints at bus i.

define_constants;

% Set to true to fix real power output at generators (PV buses).
fix_p_pv_bus = false;

% Number of buses.
n = size(msc.bus, 1);

% Vectors of real power constraints.
P_max = zeros(n, 1);
P_min = zeros(n, 1);

% Vectors of reactive power constraints.
Q_max = zeros(n, 1);
Q_min = zeros(n, 1);

% Vectors of squared voltage magnitude constraints.
V_max = msc.bus(:, 12) .^ 2;
V_min = msc.bus(:, 13) .^ 2;
    
%%% REFERENCE BUS: V is fixed. %%%
ref_bus = msc.bus(msc.bus(:, BUS_TYPE) == REF, BUS_I);

% Fixed voltage magnitude.
if include_slack
    v_sq_magn = msc.bus(ref_bus, VM) .^ 2;
    V_max(ref_bus) = v_sq_magn;
    V_min(ref_bus) = v_sq_magn;
end

% Constraints on real power P.
P_min(ref_bus) = msc.gen(ref_bus, PMIN);
P_max(ref_bus) = msc.gen(ref_bus, PMAX);

% Constraints on reactive power Q.
Q_min(ref_bus) = msc.gen(ref_bus, QMIN);
Q_max(ref_bus) = msc.gen(ref_bus, QMAX);


%%% PV (generator) BUS: P, |V| are fixed. %%%
pv_bus = msc.bus(msc.bus(:, BUS_TYPE) == PV, BUS_I);

% Fixed voltage magnitude.
v_sq_magn = msc.bus(pv_bus, VM) .^ 2;
V_max(pv_bus) = v_sq_magn;
V_min(pv_bus) = v_sq_magn;

if fix_p_pv_bus == false
    P_min(pv_bus) = msc.gen(pv_bus, PMIN);
    P_max(pv_bus) = msc.gen(pv_bus, PMAX);
    Q_min(pv_bus) = msc.gen(pv_bus, QMIN);
    Q_max(pv_bus) = msc.gen(pv_bus, QMAX);
else
    % % Fixed real power P and constrained Q.
    for j = reshape(pv_bus, 1, [])

        idx = msc.gen(:, GEN_BUS) == j;

        % Fixed real power P.
        p = msc.gen(idx, PG);
        P_min(j) = p;
        P_max(j) = p;

        % Constraints on reactive power Q.
        Q_min(j) = msc.gen(idx, QMIN);
        Q_max(j) = msc.gen(idx, QMAX);
    end
end

%%% PQ (load) BUS: P, Q fixed. %%%
pq_bus = msc.bus(msc.bus(:, BUS_TYPE) == PQ, BUS_I);

% Fixed P.
P_min(pq_bus) = - msc.bus(pq_bus, PD);
P_max(pq_bus) = - msc.bus(pq_bus, PD);

% Fixed Q.
Q_min(pq_bus) = - msc.bus(pq_bus, QD);
Q_max(pq_bus) = - msc.bus(pq_bus, QD);

end