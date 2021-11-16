function [g2p] = g2_3d(x)
% G2P_3D calculates the multivariate kurtosis of a p dimensional random vector with n
% samples. 
% x is a p*n array, output is a scalar.
% The output is scaled so a normal distribution will always have an output
% of zero, independent of dimension p, variance and mean. A normal sample
% will tend to 0 when n is large.
% If p=1, this is equivalent to g2.
% g2p has been introduced by Mardia, "Measures of multivariate skewness and
% kurtosis with applications" 1970

[p, n]=size(x);
xMean=mean(x,2);

g2p=0;
Si=inv(cov(x'));
for i=1:n
    g2p=g2p+((x(:,i)-xMean)'*Si*(x(:,i)-xMean))^2;
end
g2p=g2p/n-p*(p+2);

end

