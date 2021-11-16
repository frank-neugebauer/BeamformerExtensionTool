function [g] = g2(x)
% x ist N3x1 vektor
a=mean(  (x-mean(x)).^4  );
b=(mean(   (x-mean(x)).^2   ))^2;
g=a/b -3;
end

