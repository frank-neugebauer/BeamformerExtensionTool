function [ y ] = myKernelDesity(data, points,h)


    
if min(size(data))==1

    if nargin==2 || h==0
    h=1.06*std(data)*length(data)^(-1/5);
    end
    
    
    
    
y=points;
N=length(data);
for p=1:length(points)
    y(p)=0;
    
    for i=1:N
    
    y(p)= y(p)+exp( -((points(p)-data(i))^2)/(2*h^2) );
    
    end
    y(p)=y(p)/(N*h*sqrt(2*pi));

end

end








if min(size(data))==2
        N=length(data);

    if nargin==2 || h==0
    h=mean(std(data))*N^(-1/6);
    end
    
    

    
    
    
    
    
    y=zeros(size(points,1),1);
    
    
    for p=1:size(points,1)
        
        y(p)=0;
        
        for i=1:N
            
            d=sqrt((points(p,1)-data(i,1))^2+(points(p,2)-data(i,2))^2);
            
            y(p)=y(p)+exp(-d^2/(2*h^2));
        end
        y(p)=1/(N*h^2*2*pi)*y(p);
    end
end
    
    
    
    
    
    
    
    
    




end













