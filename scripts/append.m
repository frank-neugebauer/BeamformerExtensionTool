function [data] = append(data)
%append combines the trials in data into one single trial, as if the data
%was read from one continous file

%trials
tr{1}=horzcat(data.trial{:});
data.trial=tr;

%sampleinfo
sample=sum(data.sampleinfo(:,2));
data.sampleinfo=[1; sample];

%time
for i=size(data.time,2):-1:2
    for j=i-1:-1:1
        data.time{i}=data.time{i}+2*data.time{j}(end)-data.time{j}(end-1);
    end
end
time{1}=horzcat(data.time{:});
data.time=time;



end
