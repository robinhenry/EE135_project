# EE135_project
Project on Optimal Power Flow for EE135 class at Caltech (Winter 2019).

Files explanation:
- get_constraints.m         : function that returns vectors of constraints, given a MATPOWER msc test case.
- transform_Y.m             : function that returns \Phi_j, \Psi_j and J_j matrices for each bus j.
- simple_network.m          : computes the SDP convex relaxation of a 2-bus power grid.
- simple_network_matpower.m : solves the OPF problem for the same 2-bus network, using MATPOWER.
