function [ lead] = leadfieldChannel(channel, lead, cfg)
%LEADFIELDCHANNEL takes a ft-leadfield and channelselection and adjusts/labels the
% channels in its leadfield-field.
% For MEG, no cfg should be given.
% For EEG, cfg should be given to rereference the leadfield
% cfg.ref should be a channel, or 'avg', default 'avg'
% cfg.delRef deletes the ref-channel after rereferencing, should not be
% 'avg'



if nargin==2
    disp('deleting channels');
    
    
    channel=ft_channelselection(channel, lead.label);
    
    if ~strcmp(channel, 'all') %we need to adjust the channels
        channelAll=size(lead.leadfield{1}, 1); %number of all channels
        channelIndex=false(channelAll, 1);
        
        for i=1:channelAll   %for every channel, test if it is desired
            for j=1:size(channel,1)
                if strcmp(lead.label{i},channel{j})
                    channelIndex(i)=true;
                    %j=channelAll;
                end
            end
        end
        
        for i=1:size(lead.leadfield,1)
            lead.leadfield{i}=lead.leadfield{i}(channelIndex,:);
        end
    end
    
    lead.label=channel;
    
end


if nargin==3
    
    newref=ft_getopt(cfg, 'ref', 'avg');
    
    channel=ft_channelselection(channel, lead.label);
    
    
    %find a temporary reference or the newref in case it is a channel
    
    if strcmp(newref, 'avg')
        ref=channel{1}; %this means, it will not be deleted later
    else
        ref=newref;
        disp('rereferencing to');
        disp(ref);
    end
    
    
    
    for i=1:size(lead.label,1)
        if strcmp(ref, lead.label{i})
            indexRef=i;
            break;
        end
    end
    
    %rerefence to that channel
    for i=1:size(lead.leadfield, 1) %for every point
        number=lead.leadfield{i}(indexRef,:);
        for j=1:size(lead.leadfield{i},1)
            lead.leadfield{i}(j,:)= lead.leadfield{i}(j,:)-number;
        end
    end
    
    
    
    %delete unwanted channels, see code above
    
    lead=leadfieldChannel(channel, lead); %this also adds lead.label
    
    
    if strcmp(newref, 'avg')
        
        %rereference to average
        disp('recalculating avg ref');
        
        for i=1:size(lead.leadfield, 1) %for every point
            
            number=mean(lead.leadfield{i});
            for j=1:size(lead.leadfield{i},1)
                lead.leadfield{i}(j,:)= lead.leadfield{i}(j,:)-number;
            end
        end
    end
    
    
    
    if ft_getopt(cfg,'delRef', 0)
        disp('deleting the reference channel');
        %find the index for the reference again
        for i=1:size(lead.label,1)
            if strcmp(ref, lead.label{i})
                indexRef=i;
                break;
            end
        end   
            channelNew=lead.label;
            channelNew{indexRef}=strcat('-', channelNew{indexRef});
            
            lead=leadfieldChannel(channelNew, lead);
            
        
        
    end
    
    
    
    
end




disp('finished leadfield processing');

end

