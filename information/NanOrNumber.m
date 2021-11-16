function [ x ] = NanOrNumber( x,default)

if nargin==1
    default=0;
end

for i=1:length(x)
    
    if isnan(x(i)) || isinf(x(i))
        x(i)=default;
    end
    
end

end

