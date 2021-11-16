function [ y ] = negentropyN(x)


y=log(var(x))+2*(1+log(2*pi))-entropyNeighbour(x);


end

