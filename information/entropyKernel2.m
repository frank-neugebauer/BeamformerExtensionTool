function [ entr ] = entropyKernel2(data1, data2 )


if size(data1,1)==length(data1)
    data1=data1';
end

if size(data2,1)==length(data2)
    data2=data2';
end

% r1=range(data)/100;
% points=min(data)-r1:r1:max(data)+r1;
% 


p12=@(x,y) NanOrNumber(myKernelDesity([data1;data2]',[x;y]')'.*log(myKernelDesity([data1;data2]',[x;y]')'));
    
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
 

         
         entr=-integral2(p12, -inf, inf, -inf, inf);
         



end


