function [ out ] = minmax( vector )
%minmax gives the maximum of absolute values, but with according sign

[val, ind]=max(abs(vector));
out=val*sign(vector(ind));


end

