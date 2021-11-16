function [ point, count] = distr_sphere(Nwish, r )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin==1
    r=1;
end

% n = 2*Nwish; % number of points
% 
% 
% 
% 
% thetha = 0:pi/(n/2):2*pi; 
% phi    = -pi:2*pi/n:pi;
% 
% 
% 
% [t,p] = meshgrid(thetha,phi);    
% 
% 
% xp    = r.*sin(p).*cos(t);
% yp    = r.*sin(t).*sin(p);
% zp    = r.*cos(p);  
% %plot3(xp,yp,zp,'*');
% 
% %plot3(xp,'*')
% 
% points=[];
% for i=1:31
% points=[points; xp(i,:)', yp(i,:)', zp(i,:)'];
% end
% 
% ind=find(subplus(points(:,3)));
% 
% pointsplus=points(ind, :);
% 
% 















count=1;
a=4*pi/Nwish*r*r;  %surface of sphere /number of points = roughly the space for one point
d=sqrt(a);       %if a is a square, this is the length or width of that square
mv=round(pi/d);  %length of one half of circle / wished distance = number of points for each axis
dv=pi/mv; %distance on polar axis
dp=a/dv; %

%point=zeros(mv-1, 3);
for m=0:(mv-1)
    v=pi*(m+0.5)/mv;
    mp=round(2*pi*sin(v)/dp);
    for n=0:(mp-1)
        p=2*pi*n/mp;
        point(count, :)=r*[sin(v)*cos(p), sin(v)*sin(p), cos(v)];
        count=count+1;
    end
end

disp(['placed', ' ', num2str(count-1), ' ', 'points on sphere']);















end

