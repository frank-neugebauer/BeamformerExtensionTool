function [out ] = diffe(a)

ma=max_matrix(a);
mi=max_matrix(-a);
dif=ma+mi;

out=[ma -mi dif];


end

