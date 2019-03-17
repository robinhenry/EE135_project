clear; close all;
n=10;
% SDP optimization.
cvx_begin SDP
    variable W(n,n) semidefinite;
    minimize( trace(W) );
    subject to
        for j = 1:n
            W(j,j) >= 1; 
        end
        W >= 0;
cvx_end
