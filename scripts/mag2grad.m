function [lf] = mag2grad(lm, grad)

%tries to combine a 555*pos magnetometers-lm to gradiometer-lm without weighting

%check for the channel-sum?
lf=zeros(size(grad.chantype,1), size(lm, 2));

for i=1:271 %meggrad
    
    lf(i,:)=lm(i,:)+lm(i+271,:);
end
    
    










end












