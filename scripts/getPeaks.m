function [index2] = getPeaks(data, threshold )
%AGETPEAKS gives the peaks of the vector data, that are above the specified
%threshold.

if size(data,1)==1
    data=data';
end

data=data-threshold;

%now find points above 0

index=find(data>0);

index2=[];
if ~isempty(index) %there are peaks fullfilling the criterion
    
    
    %find all sequential time points
    
    countIndex=1; %for all points in index
    while countIndex<=size(index,1)
        indexNumber=index(countIndex);
        firstIndex=countIndex;
        
        
        
        while(countIndex<size(index,1) && index(countIndex+1)==indexNumber+1)
            countIndex=countIndex+1;
            indexNumber=index(countIndex);
        end
        [~, index2(end+1)]=max(data(index(firstIndex:countIndex)));
        index2(end)=index(firstIndex-1+index2(end));
        countIndex=countIndex+1;
        
        
        
        
        
    end
    
    
    
    
    
    
end

index2=index2';


