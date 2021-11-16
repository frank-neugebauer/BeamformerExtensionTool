function [value] = sliding_g2(vektor, varargin)
% varargin specifies the metric and lenght used for a sliding window.
% If a metric is chosen, a lenght must follow
% Use as:
% no input - classic g2
% 'max', lenght  maximum metric
% 'sum', leght   sum metric
% 'sum_plus, lenght sum metric with only positiv numbers

if size(varargin)==0
    value=g2(vektor);
else
    
    if strcmp(varargin{1},'max')
        value=g2max(vektor,varargin{2});
    end
    
    if strcmp(varargin{1},'sum')
        value=g2sum(vektor,varargin{2});
    end
    
    if strcmp(varargin{1},'sum_plus')
        value=g2sum_plus(vektor,varargin{2});
    end
    
end



end

