function [ infoMa ] = informationMatrix(data)

numVars=size(data, 1);

infoMa=zeros(numVars);

for n=1:numVars
for m=n:numVars
    
    infoMa=information(data(n,:), data(m,:));
end
end

infoMa=infoMa+triu(infoMa,1)';





end

