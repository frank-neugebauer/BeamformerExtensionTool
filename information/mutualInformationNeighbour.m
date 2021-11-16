function [ mi] = mutualInformationNeighbour(data1, data2)
% mutualInformationNeighbour uses the "3H" priciple to estimate mutual
% information between data1 and data2, that is Info(data1,
% datat1)=entropy(data1)+entropy(data2)-entropy2(data1, data2), using the
% nearestNeighbour approximation to estimate entropy. See entropyNeighbour,
% entropyNeighbour2 for details.
%Data should be a (1,N)-array



mi=entropyNeighbour(data1)+entropyNeighbour(data2)-entropyNeighbour2([data1;data2]);









end










