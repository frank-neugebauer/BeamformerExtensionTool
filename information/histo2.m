function [ h, index ] = histo2(cfg, data1, data2 )
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


cfg.bins=ft_getopt(cfg, 'bins', 'R');




if size(data1,1)>1 && size(data1, 2)==1
    data1=data1';
end

if size(data2,1)>1 && size(data2, 2)==1
    data2=data2';
end


data12=[data1; data2];

for i=1:2

    data=data12(i,:);



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

bins12(i)=bins;
widthBins12(i)=widthBins;

end






h=zeros(bins12(1), bins12(2));

% simple, but slow implementation
% index=zeros(2,N);
% b1=1;
% b2=1;
% 
% i=1;
% while i<=length(data12)
%     
%     if (data1(i)>=min(data1)+widthBins12(1)*(b1-1) && data1(i)<min(data1)+widthBins12(1)*b1) ...
%             || (data1(i)>=min(data1)+widthBins12(1)*(b1-1) && (data1(i)-min(data1)-widthBins12(1)*b1<min(abs(data1))/1000) && b1==bins12(1) )  %< or <= ?
%         
%         if (data2(i)>=min(data2)+widthBins12(2)*(b2-1) && data2(i)<min(data2)+widthBins12(2)*b2) ...
%                 || (data2(i)>=min(data2)+widthBins12(2)*(b2-1) && (data2(i)-min(data2)-widthBins12(2)*b2<min(abs(data2))/1000) && b2==bins12(2) ) 
%             %second criterion used to close the last intervall on the right
%             %side with a ad hoc criterion for rounding errors
%             
%             h(b1,b2)=h(b1, b2)+1;
%                     index(:,i)=[b1, b2];
% 
%         i=i+1;
%         b1=1;
%         b2=1;
%         
%         else
%             b2=b2+1;
%             
%         end
%         
%     else
%         b1=b1+1;
%     end
%     
% end

% new implementation 

dataScaled1=data1-min(data1);
dataScaled1=dataScaled1./widthBins12(1);
dataScaled1=floor(dataScaled1)+1;


dataScaled2=data2-min(data2);
dataScaled2=dataScaled2./widthBins12(2);
dataScaled2=floor(dataScaled2)+1;

for i=1:N
    
    ds1=dataScaled1(i);
    ds2=dataScaled2(i); 
    
    if ds1==bins12(1)+1 %the last intervall is closed on the right side
        ds1=ds1-1;
        dataScaled1(i)=dataScaled1(i)-1;
    end
    
     if ds2==bins12(2)+1 %the last intervall is closed on the right side
        ds2=ds2-1;
        dataScaled2(i)=dataScaled2(i)-1;

    end
    
    h(ds1, ds2)=h(ds1, ds2)+1;
    index=[dataScaled1; dataScaled2];
end

































end