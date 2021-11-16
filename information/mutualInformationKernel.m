function [ mi] = mutualInformationKernel(cfg, data1, data2, h )
%mutualInformationKernel estimates the mutual information of data1 and
%data2 with a Gaussian Kernel with bandwidth h



if nargin==3
    h=0;
end

if size(data1,1)==length(data1)
    data1=data1';
end


if size(data2,1)==length(data2)
    data2=data2';
end


%mi=0;

% for i=1:length(data1)
%     
%     p12=myKernelDesity([data1,data2], [data1(i), data2(i)], h);
%     p1=myKernelDesity(data1, data1(i), h);
%     p2=myKernelDesity(data2, data2(i), h);
%     
%     
%     if p12~=0 && p1~=0 && p2~=0
%         
% %         if log(p12/(p1*p2))<0
% %             disp('?');
% %         end
%         
%         mi=mi+log(p12/(p1*p2));
%     end
%     
% end
%
% mi=mi/length(data1);


% % 
% % r1=range(data1)/100;
% % r2=range(data2)/100;
% % 
% % points1=min(data1)-r1/100:r1:max(data1)+r1;
% % points2=min(data2)-r2/100:r2:max(data2)+r2;
% % 
% % 
% % 
% % for i=1:length(points1)
% %          p1=myKernelDesity(data1, points1(i), h);
% %          
% %          if p1~=0
% %              for j=1:length(points2)
% %                  p12=myKernelDesity([data1,data2], [points1(i), points2(j)], h);
% %                  
% % %                  if p1/p12>10^20
% % %                      disp(p1)
% % %                      disp(p2)
% % %                  end
% %     
% %     
% %     p2=myKernelDesity(data2,points2(j), h);
% %                  
% %                  if p12~=0 && p2~=0
% %                     mi=mi+r1*r2*p12*log(p12/(p1*p2));
% %                     
% %                  end
% %              end
% %          end
% %          
% %          
% %          
% % end


fun=@(x,y) NanOrNumber( myKernelDesity([data1;data2]',[x;y]')'.*log(myKernelDesity([data1;data2]',[x;y]')'./ ... 
    (myKernelDesity(data1,x).*myKernelDesity(data2,y)))); 
%transposes and . are needed for array input and integration, for x,y numbers the output is a single number



mi=integral2(fun, -inf, inf, -inf, inf);






























end

