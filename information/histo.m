function [ h, index ] = histo(cfg, data )
%histo calculates a histogram of the 1*N or N*1 dimensional data. 
% cfg can include the options:
%     either
%     bins
%     widthBins
% 
%         where numberBins can be
%             a number
%             'Square-root-choice', 'src'
%             'Sturges', 'St'
%             'Rice', 'R'
%             'Doane', 'D', then cfg.skew should be the skewness of the distribution (default 0)
%             'Scott', 'Sc'
%             'Freedman-Diaconis', 'FD'
%             %'Minimizing cross-validation estimated squared error', 'cv'
%             not yet implemented
%             %'Shimazaki-Shinomoto', 'SS', not yet implemented
%             'width', 'w', then cfg.widthBins is a number
% 



if size(data,1)>1 && size(data, 2)==1
    data=data';
end

cfg.bins=ft_getopt(cfg, 'bins', 'R');

%estimate number and width of bins
N=length(data);

if isnumeric(cfg.bins)
    bins=cfg.bins;
    widthBins=range(data)/bins;
else
    
    switch cfg.bins
        
        case {'Square-root-choice', 'src'}
            bins=ceil(sqrt(N));
                widthBins=range(data)/bins;

            
        case {'Sturges', 'St'}
            bins=ceil(log2(N))+1;
            if N<30
                warning('data length is smaller then 30. This might perform poorly');
            end
                widthBins=range(data)/bins;

        case {'Rice', 'R'}
            bins=ceil(2*N^(1/3));
                widthBins=range(data)/bins;

        case {'Doane', 'D'}
            if ~isfield(cfg, 'skew')
                warning('cfg.skew is empty. Assuming zero skewness');
                cfg.skew=0;
            end
            
            sigmag=sqrt(6*(N-2)/((N+1)*N+3));
            bins=1+log2(N)+log2(1+abs(cfg.skew)/sigmag);
            bins=ceil(bins); %this is not in the formula on wiki (?)
                widthBins=range(data)/bins;

        case {'Scott', 'Sc'}
            widthBins=3.5*std(data)/N^(1/3);
            bins=ceil(range(data)/widthBins);
            
        case {'Freedman-Diaconis', 'FD'}
            widthBins=3.5*iqr(data)/N^(1/3);
            bins=ceil(range(data)/widthBins);
            
            
        %case {'Minimizing cross-validation estimated squared error', 'cv'}
            
            
            
       % case { 'Shimazaki-Shinomoto', 'SS'}
            
            
            
        case {'width'}
            widthBins=cfg.widthBins;
            bins=ceil(range(data)/widthBins);
        
        
        
        
        otherwise
            
            
            error('cfg.bins could not be resolved')


    end
end

%% sorting data, works fine but is hard to do for 2 datasets in histo2
% data=sort(data);
% h=zeros(1, bins);
% % 
% b=1;
% i=1;
% while i<=length(data)
%     
%     if data(i)<min(data)+widthBins*b  %< or <= ?
%         h(b)=h(b)+1;
%         i=i+1;
%     else
%         b=b+1;
%     end
%     
% end

%% naive implementation works fine for small data sets, but slows down if set gets large

% h=zeros(1, bins);
% index=zeros(1,N);
% b=1;
% i=1;
% while i<=N
%     
%     if data(i)>=min(data)+widthBins*(b-1) && data(i)<min(data)+widthBins*b  %< or <= ?
%         h(b)=h(b)+1;
%         index(i)=b;
%         i=i+1;
%         b=1;
%     else
%         b=b+1;
%     end
%     
% end



%% my implementation, seems to work fine :)

 h=zeros(1, bins);

dataScaled=data-min(data);
dataScaled=dataScaled./widthBins;
dataScaled=floor(dataScaled)+1;

for i=1:N
    
    ds=dataScaled(i);
     
    if ds==bins+1 %the last intervall is closed on the right side
        ds=ds-1;
    end
    
    h(ds)=h(ds)+1;
    index=dataScaled;
end
    



%% gives different results then the above, not sure why :(

%taken from R. Moddemeijer

% dataScaled=(data-min(data))/range(data); %from 0 to 1
% dataScaled=dataScaled*(bins)+1/2; %from 1 to bins
% dataScaled=round(dataScaled);
% 
% for i=1:N
%   ds=dataScaled(i);
%   if ds >= 1 && ds<=bins
%     h(ds)=h(ds)+1;
%   end
% end



















































end