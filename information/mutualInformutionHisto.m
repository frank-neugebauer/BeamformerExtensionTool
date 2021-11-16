function [mI ] = mutualInformutionHisto(cfg,  data1, data2, h, index )


if nargin ==3
cfg.bins=ft_getopt(cfg, 'bins', 'R');
[h, index]=histo2(cfg, data1, data2);
end









mI=0;

ph=h/sum(h(:)); %is that right?

h1=sum(h');
ph1=h1/sum(h1);

h2=sum(h);
ph2=h2/sum(h2);


% for i=1:length(data1)
%     
%     for j=1:length(data2)
%         
%         if  ph(index(1,i), index(2,j))~=0 && ph1(index(1,i))~=0 && ph2(index(2,j))~=0
%         f=ph(index(1,i), index(2,j))/ph1(index(1,i))/ph2(index(2,j));
%         f=log(f);
%         else
%             f=0;
%         end
%         
%         mI=mI+h(index(1,i), index(2,j))*f;
%         
% 
%     end
% end


for i=1:size(h,1)
    for j=1:size(h,2)

        if  ph(i, j)~=0 && ph1(i)~=0 && ph2(j)~=0
        f=ph(i,j)/ph1(i)/ph2(j);
        f=log(f);
        else
            f=0;
        end
        
        mI=mI+h1(i)*h2(j)*ph(i,j)*f;
        
        
        
    end
end











end

