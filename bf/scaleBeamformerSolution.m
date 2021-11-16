function [out] = scaleBeamformerSolution(beam, data, lead)

numberOfFilters=max(size(beam.filter));

alpha=zeros(numberOfFilters,1);
value=alpha;

for i=1:numberOfFilters
    wave=beam.filter{i}'*data;
    wave=lead.leadfield{i}*beam.orientation{i}*wave;
    alpha(i)=trace(wave'*data/(norm(wave)^2));
    value(i)=norm(alpha(i)*wave-data);
end


out.value=value;
out.scale=alpha;






end

