function [value,g] = g2max(x,lenght)

if size(x,1)==1
    x=x';
end

lenght=floor(lenght/2)*2;

nAuf=size(x,1);
n=0;
g=zeros(2*ceil(nAuf/lenght),1);

while 1+(n/2+1)*lenght<=nAuf
     g(n+1)=g2(x(1+n*lenght/2:1+(n/2+1)*lenght));
     n=n+1;
end

g(n+1)=g2(x(1+n*lenght/2+lenght:end));
n=n+1;
if 1+(n/2+1)*lenght<=nAuf
    g(n+1)=g2(x(1+n*lenght/2:end));
end

value=max(g);



end

