function [g2pK] = g2_3d_alt(x)
% g2pK calculates a variant of the multivariate kurtosis of a p dimensional random vector with n
% samples. 
% x is a p*n array, output is a scalar.
% If p=1, this is equivalent to g2.
% g2pK has been introduced by Koziol, "A Note on Measures of
% Multivariate Kurtosis" 1989

%The output should be scaled, so a normal distribution has a g2pK of 0, but
%it is unclear, if this is possible

[p, n]=size(x);
xMean=mean(x,2);

g2pK=0;
Si=inv(cov(x'));
for i=1:n
    for j=1:n
                g2pK=g2pK+((x(:,i)-xMean)'*Si*(x(:,j)-xMean))^4;
    end
end
g2pK=g2pK/n^2;

end