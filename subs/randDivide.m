
function [idxo prtA]=randDivide(M,K) 

[n,m]=size(M);
np=(n-rem(n,K))/K;
B=M;
[c,idx]=sort(rand(n,1));
C=M(idx,:);
i=1;
j=1;
ptrA={};
idxo={};
n-mod(n,K)
while i<n-mod(n,K)
    prtA{j}=C(i:i+np-1,:);
    idxo{i}=idx(i:i+np-1,1);
    i=i+np;
    j=j+1;

end
prtA{j}=C(i:n,:);

end 
