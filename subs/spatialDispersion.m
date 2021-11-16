function [sd] = spatialDispersion(value)
%spatialDispersion calculates the spread of the signal in the source space. More details in
% Lucka, 2012, appendix B
% value should either be an N*1 or N*3 array of power or moments

%if N*3, go to N*1

N=size(value, 1);

if size(value,2)==3
    valueNew=zeros(N, 1);
    for i=1:N
    valueNew=value(i,1)+value(i,2)+value(i,3);
    end
    
    value=valueNew;
end


sd=-1;
a=max(value);
for i=1:N
    sd=sd+(value(i)/a);
end
sd=sd/(N-1);










































end

