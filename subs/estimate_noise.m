function [noise_par] = estimate_noise(cfg, data)
%estimate_noise


latency=ft_getopt(cfg, 'latency', 'all');
method=ft_getopt(cfg, 'method', 'deviation');
latencyInSeconds=ft_getopt(cfg, 'latencyInSeconds', 1);

if latencyInSeconds
    time=ft_getopt(cfg, 'time', 1:size(data, 2));
end




if ~strcmp(latency, 'all')
    if  latencyInSeconds %need to estimate the points in the array
        display('Using specific latency');
        tbeg = nearest(time, cfg.latency(1));  %TODO this gives an error when a trial is specified, or now when no trial is specified
        tend = nearest(time, cfg.latency(end));
        data=data(:, tbeg:tend);
    else
        data=data(:, latency(1):latency(2));
    end
end



switch method
    
    case {'deviation', 'standard_deviation', 'sigma'}
        noise_par=std(data, 0, 2); %default weighting, second dimension
        
end
        
       


end