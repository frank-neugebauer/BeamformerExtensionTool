function [ b2p ] = b2p(data)

% the b_p,2 formula of "Eigenvectors of a kurtosis matrix as interesting directions to reveal
% cluster structure" by Daniel Peña, page 2

m=mean(data);
S=inv(cov(data));
T=size(data,2);
N=size(data,1);


b2p=0;
for i=1:T
    b2p=b2p+ ( (data(:,i)-m)'*S*(data(:,i)-m) )^2;
end
b2p=b2p/T;

b2p=b2p-N(N+2); %difference to 0 suggest non-normality now


end