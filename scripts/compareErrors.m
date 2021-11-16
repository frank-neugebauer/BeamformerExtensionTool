
%LocErrorTotalN=zeros(4,2,6,5,60, 7);

%oI=3; %1,2,3,5,6

%same=ones(4,2,6,5,60);

% same2=LocErrorTotalN(:,:,:,:,:,1)==LocErrorTotalN(:,:,:,:,:,2);
% same3=LocErrorTotalN(:,:,:,:,:,1)==LocErrorTotalN(:,:,:,:,:,3);
% same5=LocErrorTotalN(:,:,:,:,:,1)==LocErrorTotalN(:,:,:,:,:,5);
% same6=LocErrorTotalN(:,:,:,:,:,1)==LocErrorTotalN(:,:,:,:,:,6);
% 
% 
% [row,col,v]=find(~same2);
% k2 = find(~same2);
% k3=find(~same3);
% k5= find(~same5);
% k6= find(~same6);

%RETURNS ALL EMPTY, RESULTS ARE ALWAYS THE SAME!

%load errors
med=zeros(4,2,6,5,5);
nI=[1 2 3 5 6];


for n=1:5
    for ori=1:4
        for noise=1:2
            for alg=1:6
                for model=1:5                    
                    med(ori, noise, alg, model,n)=median(LocErrorTotalN(ori,noise, alg, model, :,nI(n)));
                end
            end
        end
    end
    
end
med=round(med);
k=0;
isame=cell(1,1);
for ori=1:4
    for noise=1:2
        for alg=1:6
            for model=1:5
                if~isequal(med(ori, noise, alg, model, 1),med(ori, noise, alg, model, 2),med(ori, noise, alg, model, 3),med(ori, noise, alg, model, 4),med(ori, noise, alg, model, 5));
                    k=k+1;
                   isame{k}=[ori, noise, alg, model];
                   a=squeeze(med(ori,noise, alg, model, [1 2 4 5]));
                   diffe(a)  
                end
            end
        end
    end
end





























