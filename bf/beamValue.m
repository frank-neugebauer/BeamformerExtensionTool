function [value] = beamValue(cfg, beam, data)


dataArray=data.avg;
scale=ft_getopt(cfg,'scale', ones(size(beam.value)));

peak=cfg.peak;

num=size(beam.filter,1);
%plotdata=zeros(num, 1);

value=zeros(num, size(peak,2));
for n=1:size(peak,2)
    
    for i=1:num
        value(i,n)=(beam.filter{i}'*dataArray(:,peak(n)))^2/scale(i);
    end
end


end