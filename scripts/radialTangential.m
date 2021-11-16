function [out] = radialTangential( lead)

[~, ~, V]=svd(lead);
tangential=V(:,1);
radial=V(:,3);
out=[radial, tangential];
end

