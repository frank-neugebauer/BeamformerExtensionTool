function [mp] = kugelwinkel(mu,phi)


m=mu;
p=phi;

while m<-pi/2 || m>=pi/2
    if m<-pi/2
        m=m+pi/2;
    else
        m=m-pi/2;
    end
end

while p<-pi || p>=pi 
    if p<pi
        p=p+2*pi;
    else
        p=p-2*pi;
    end
end

mp=[m;p];

end

