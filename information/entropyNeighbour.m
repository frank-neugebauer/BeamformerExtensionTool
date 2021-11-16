function [ E ] = entropyNeighbour(data )


    n = length(data);       
    %distance to the nearest neighbour
    data = sort(data);
    r = zeros(1,n);
    r(1) = data(2)-data(1);    
    r(2:end-1) = min(data(3:n) - data(2:n-1), data(2:n-1) - data(1:n-2)); %looking for the nearest neighbour
    r(n) = data(n)-data(n-1);    
    r(r==0) = 1/sqrt(n); %elimination of denegerated values
    %actual estimation    
    E = (1/n)*sum(log(r))+log(2*(n-1))+0.5772156649;


%E2 = (1/n)*sum(log(n*r))+log(2)+0.5772156649;







end

