function [phi, psi, J] = transform_Y(Y)
% This function transforms an admittance matrix Y 
% into its skew Hermitian components.
%
% Inputs:
%   Y   : (nxn) admittance matrix.
%
% Outputs:
%   phi : (nxnxn) matrix, where phi(j) is \phi_j = (Y_j^H + Y_j) / 2.
%   psi : (nxnxn) matrix, where psi(j) is \psi_j = (Y_j^H - Y_H) / (2i).
%   J   : (nxnxn) matrix, where J(j, j, j) = 1.

n = size(Y, 1);

phi = zeros(n, n, n);
psi = zeros(n, n, n);
J = zeros(n, n, n);

for j = 1:n
    e_j = zeros(n, 1);
    e_j(j, 1) = 1;
    
    Y_j = e_j * e_j' * Y;
   

    phi(:, :, j) = (Y_j' + Y_j) / 2;
    psi(:, :, j) = (Y_j' - Y_j) / (2 * 1i);
    J(:, :, j) = e_j * e_j';
end
end