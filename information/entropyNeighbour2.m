function [ entr ] = entropyNeighbour2(data,  k )

if nargin==1
    k=1;
end

if size(data,2)>size(data,1)
    data=data';
end

n=length(data);


[~, p]=knnsearch(data, data, 'K', k+1);

p=p(:,k+1);
gamma=0.577215664901532;
entr=1/n*sum(log(p*pi/exp(-gamma)));




end