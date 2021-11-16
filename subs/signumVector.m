function [ s ] = signumVector( x )
%signumVector returns 1, if there are more positive (>=0) numbers in x and
%-1 if not

s=prod((-sign(x)<0)*2-1);








end

