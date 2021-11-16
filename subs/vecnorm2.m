function [vecn] = vecnorm2(matrix, dim)




if nargin==2 && dim==2
    matrix=matrix';
end

[z, ~]=size(matrix);

vecn=zeros(z,1);

for k=1:z
    vecn(k)=norm(matrix(k,:));
end
    











































end

