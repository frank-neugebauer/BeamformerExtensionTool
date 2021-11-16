function [sd] = spatialDispersionLocation(beam)

value=beam.value;



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
    sd=sd+(value(i)/a*norm(beam.pos(i,:)-beam.pos(beam.index,:)));
end
sd=sd/(N-1);




