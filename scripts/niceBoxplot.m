

%%exaplme for 5 groups and 4 conditions

% data=zeros(5*4,100);
% 
% condcounter=1;
% c=1;
% g=1;
% for i=1:20
%     data(i,:)=randn(1,100)*g+c;
%     if condcounter<5
%         condcounter=condcounter+1;
%     else
%         condcounter=1;
%         c=c+1;
%     end
%     
%     if g<5
%         g=g+1;
%     else
%         g=1;
%     end
% end


%data has to be sorted like the column in the plot, 
%with data(x,:) forming the x-th box
%data

%tang=1;
%mo=1;
data=[];
for tang=3:4
for mo=1:5
data=horzcat(data,LocErrorTotal(tang,6,3,mo,:));
end
end

data=squeeze(data);

labelsGroup={'3', '4', '5', '6', '6a'};
labelsCond={' ', ' ', 'Tangential', ' ', ' ',' ', ' ', 'Radial', ' ', ' '};

titlename='EEG';%labelsGroup={'var1', 'var2', 'var3', 'var4', 'var5'}; %labels of groups, should be cell of strings, i.e. {'str1', 'str2', ...}
%labelsCond={' ',' ','exp1',' ', ' ',' ',' ','exp2',' ', ' ',' ',' ','exp3',' ', ' ',' ',' ','exp4',' ', ' '}; %labels of conditions, same format as labelsGroup. Needs to be the same size, so write {' ', str1, ' ',...} for one name per condition 

        
        siz=19;














numberGroups=size(labelsGroup,2);  %number of different groups
numberInGroups=size(data, 2);   %number of boxes per group
numberCond=size(data,1)/numberGroups; %number of 
labelsGroup=repmat(labelsGroup',numberCond*numberInGroups,1);
labelsCond=repmat(labelsCond', numberInGroups, 1);

group=repmat((1:numberGroups*numberCond)', numberInGroups,1)';



%labModel=repmat((1:20)',60,1)';

        
        
        pos=[]; %quick and dirty :)
        posi=1;

        for i=1:((numberGroups+1)*numberCond) %every group will have an empty position after them, forming a space
            if ~(mod(i,numberGroups+1)==0)
                pos=[pos posi];
            end
            posi=posi+1;
        end


        h = figure;

set(h, 'DefaultTextFontSize', siz);


       % figure;
boxplot(data, group, 'Colors', linspecer(numberGroups), 'Labels',{labelsGroup, labelsCond},'BoxStyle', 'filled',  'Positions',pos, 'MedianStyle', 'line', 'Whisker', 1.5, 'symbol', '+','dataLim', [0, 20], 'ExtremeMode','clip');
%'dataLim', [0, 40], 'ExtremeMode','clip', for handling outliers

%



 h = findobj(gca,'tag','Median');   %set the median to a thick, black line for better visibility
set(h,'linestyle','-', 'linewidth', 2);
set(h,'Color',[0 0 0])
        
%         title(strcat({''}, labAlg{alg}));
%         ylabel('');
%         xlabel({''});
        
       grid on;
        grid minor; 
        
        
               %axis([0 13 -0.5 40]);

     ylabel('Localization error in mm','FontSize',siz);
     set(gca,'FontSize',20)
     
     %set(gca,'XTick',1:2)%2 because only exists 2 boxplot
     
     %xlabel({'Number of modeled compartments';' direction of source'});
title(titlename, 'FontSize', siz);
print(titlename, '-depsc');
























