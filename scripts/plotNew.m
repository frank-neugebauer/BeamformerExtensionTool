
%plot all RT-ME for every compartment for 1 alg and 1 noiselevel


close all;

for dur=[1 2 3 5 6];

no=[1 2]; %1 low, 2 high
for alg=1
    for me=2  % 0 for MEG, 2 for EEG
        
        
        tmrmtere=[1+me 2+me];
        
        % f = figure;
        % p = uipanel('Parent',f,'BorderType','none');
        % p.Title = 'My Super Title';
        % set(gcf,'color',[1 1 1]);
        % p.TitlePosition = 'centertop';
        % p.FontSize = 12;
        % p.FontWeight = 'bold';
        
        
        
        
        
        
        
        a=squeeze(LocErrorTotalN(tmrmtere,no,alg,1,:,dur)); %RTME noise alg comp dip, X dipxComp
        b=squeeze(LocErrorTotalN(tmrmtere,no,alg,2,:,dur));
        c=squeeze(LocErrorTotalN(tmrmtere,no,alg,3,:,dur));
        d=squeeze(LocErrorTotalN(tmrmtere,no,alg,4,:,dur));
        e=squeeze(LocErrorTotalN(tmrmtere,no,alg,5,:,dur));
        
        
        
        
        
        
        
        
        % a=ones(60,1);
        % b=2*ones(60,1);
        % c=3*ones(60,1);
        % d=4*ones(60,1);
        % e=5*ones(60,1);
        
        data=[];
        for i=1:2
            for j=1:2 %RTME
                %noise
                data=[data;a(i,j,:);b(i,j,:);c(i,j,:);d(i,j,:);e(i,j,:)];
            end
        end
        data=squeeze(data);
        
        labAlg={'unit gain','unit array gain','unit noise gain','unit gain g2','unit array gain g2','unit noise gain g2'};
        labComp=repmat({'3', '4', '5', '6', '6a'}', 60*4, 1);
        labRTME=repmat({'TM', 'RM', 'TE', 'RE'}', 60*4,1);
        labRTM=repmat({' ', ' ', 'TML', ' ', ' ',' ', ' ', 'TMH', ' ', ' ',' ', ' ', 'RML', ' ', ' ',' ', ' ', 'RMH', ' ', ' '}',60,1);
        labRTE=repmat({' ', ' ', 'TEL', ' ', ' ',' ', ' ', 'TEH', ' ', ' ',' ', ' ', 'REL', ' ', ' ',' ', ' ', 'REH', ' ', ' '}',60,1);
        
        
        labModel=repmat((1:20)',60,1)';
        gap=[1;56666660]';
        
        
        
        pos=[];
        pin=1;
        for i=1:4*6
            if ~(mod(i,6)==0)
                pos=[pos pin];
            end
            pin=pin+1;
        end
        
        
        labNoise='';
        for k=1:4
            labNoise=[labNoise, ' ', ' ', num2str(k), ' ', ' '];
        end
        labNoise=repmat(labNoise', 60,1);
        
        
        labT=randn(1,1200);
        
        %subplot(2,2,mo,'Parent',p)
        figure;
        % f = figure;
        % p = uipanel('Parent',f,'BorderType','none');
        % p.Title = 'My Super Title';
        set(gcf,'color',[1 1 1]);
        % p.TitlePosition = 'centertop';
        % p.FontSize = 12;
        % p.FontWeight = 'bold';
        
        
        if me==0
            labRT=labRTM;
            melab='m';
        else
            labRT=labRTE;
            melab='e';
        end
        
        title(labAlg{alg});
        boxplot(data, labModel, 'Colors', linspecer(5),'BoxStyle', 'filled',  'Positions',pos, 'Labels',{labComp, labRT}, 'MedianStyle', 'line', 'Whisker', 1.5,'dataLim', [0, 40], 'ExtremeMode','clip');
        axis([0 25 -0.5 41]);
        
        h = findobj(gca,'tag','Median');
        set(h,'linestyle','-', 'linewidth', 2);
        set(h,'Color',[0 0 0])
        
        title(strcat({''}, labAlg{alg}));
        ylabel('Localization error in mm');
        xlabel({'Number of modeled compartments';' direction of source, type of simulation, and level of noise'});
        
        
        
        %saving
        grid on;
        grid minor;
        nameAlgs={'ug', 'uag', 'ung', 'ug2', 'uag2', 'ung2'}';
        
        name=strcat(nameAlgs{alg},melab);
       % print(name, '-depsc');
        
    end
    
end


end
