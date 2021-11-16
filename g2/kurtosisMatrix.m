function [K ] = kurtosisMatrix(data, lambda)

%data SensorxTime
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
T=size(data,2);
N=size(data, 1);

%data is in Time x Sensor

C=cov(data');
mu=mean(data, 2);
for ii=1:T
  data(:,ii)=data(:,ii)-mu;
end 


Z=sqrtm(inv(C+lambda*eye(N)))*data;



K=zeros(N,N);
for i=1:T
    z=Z(:,i);
k=(z'*z)*(z*z');
K=K+k;
end


K=1/T*K;




end

