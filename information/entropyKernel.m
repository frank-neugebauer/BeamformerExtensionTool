function [ entr ] = entropyKernel( cfg, data )

if nargin==1
    data=cfg;
    cfg=[];
end


if size(data,1)~=length(data)
    data=data';
end


% r1=range(data)/100;
% points=min(data)-r1:r1:max(data)+r1;
% 


p1=@(x) NanOrNumber( myKernelDesity(data,x).*log(myKernelDesity(data,x))); %new
    
%plog=@(x) log(myKernelDesity(data,x));



%       %   p1=myKernelDesity(data, points, 0);
%          
% 
%      %    p1=p1/sum(p1);
%      %    figure;
%      %    plot(points, p1);
%              
%        %    entr=-sum(p1.*log(p1), 'omitnan');
%                     
 

         
         entr=-integral(p1, -inf, inf);
         



end

