function [e] = sphereToKart(r,mu,phi)
x=r*cos(mu)*cos(phi);
y=r*cos(mu)*sin(phi);
z=r*sin(mu);

e=[x;y;z];

end

