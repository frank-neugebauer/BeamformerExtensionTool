function [ kT ] = KurtosisTransferS(L, regularisationParameter)

% computes the kurtosis transfer matrix for a fixes position S.
% leadfieldS= leadfield.leadfield{s}*orientation Sensor*1 matrix

L2=L*L';
L2inv=inv(L2+regularisationParameter*eye(size(L2,1)));
Ls=sqrtm(L2inv);

kT=L'*L2inv*L*Ls*L2*Ls;







end

