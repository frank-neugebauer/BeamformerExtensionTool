function [con] = con_mutualInformation( source )
%con_mutualInformation takes a source with a cell of trials and calculates
%the mutual information between the sensors or source waveforms for every
%trial
%Con is cell with a mutual information matrix for every trial in source

con=cell(max(size(source.trial)));

for iTrial=1:max(size(source.trial))
    
    con{iTrial}=zeros(size(source.trial{iTrial},1));
    
    for iSources=1:size(source.trial{iTrial},1)
        
        for iOtherSources=(iSources+1):size(source.trial{iTrial},1)
        
        con{iTrial}(iSources, iOtherSources)=my_mutualInformation(source.trial{iTrial}(iSources, :),source.trial{iTrial}(iOtherSources, :));
        
        end
    end
    
    con{iTrial}=con{iTrial}+con{iTrial}'; %should be symmetric for easy graph analysis
end
        
        




























end

