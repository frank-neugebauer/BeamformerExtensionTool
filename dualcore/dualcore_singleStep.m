function [P,Q] = dualcore_singleStep(lead1, lead2, Ci)

%This function applies a dualcore beamformer to the data, using the given
%leadfield. See "Dual-Core Beamformer for obtaining highly correlated
%neuronal networks in MEG"
%by Mithun Diwakar et al.

% make combined leadfield Ldual=[L1 l2]
%compute output matrix Kdual
% compute Zdual with Kdual
%compute optimal orientation Qdual
%compute Power Pdual

% lead
% L
% K
% C
% Ci
% eps
% P
% Q
% Z
% O







L=horzcat(lead1, lead2);
%K=inv(L'*Ci*L)*(L'*(Ci*eps*Ci)*L);
Q=L'*Ci*L;

[Vectors,Values] = eig(Q);
[val, ind]=min(Values);
P=1/val;
O=Vectors(:,ind);

































end