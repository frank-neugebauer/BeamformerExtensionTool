function source_activation_mri4(cfg, mri,dat,pos)
%source_activation2 plots the data dat on the mri, using the positions pos
%
%cfg can include the following options:
% thresh
% useOri: 0,1 use Orientation or not
% orientation: can be given as cell of size dat, can be infered by x*3 dat
% map: colormap, default parula
% useZoom: 0,1 allows zooming but slows down the plot
%layout: subplot positions to use (default is (2,2)), must have at least 3
%positions
%cb wether or not to display a colorbar (default=1)




% Plot MRI slices and the source activation
% Marios Antonakakis, 25.10.2018
% mri: fieldtrip mri structure
% scale: scale value
% dat: number of sources x 3 values
% pos: source space points;
% thresh: threshold value of the source activity
% time: the time interval of the represented activity
% tit: the title of the inverse method


fss=16;
thresh=ft_getopt(cfg, 'thresh', 0.1);

map=ft_getopt(cfg, 'color', 'parula');
%tit=ft_getopt(cfg, 'title', []);

useOri=ft_getopt(cfg, 'useOri', ~isfield(cfg,'orientation'));
orientation=ft_getopt(cfg, 'orientation', []);
useZoom=ft_getopt(cfg, 'useZoom', 0);

layout=ft_getopt(cfg, 'layout', [2,2]);

cb=ft_getopt(cfg, 'cb', 1);

f = figure('WindowScrollWheelFcn',@figScroll,'WindowButtonUpFcn',@ImageClickUp,'Name','Source Activity on MRI',...
    'pos',[100 100 400*layout(2) 400*layout(1)]);



%zButton=uicontrol(f, 'Style', 'togglebutton');

if length(pos) == round(length(dat)/3)
    dat = reshape(dat,3,size(dat,1)/3)';
end


%
if useOri~=0
    if iscell(orientation) %orientation is a cell with 3*1 vector in each cell
        ori=cell2mat(orientation);
        ori=changeLead(ori');
        ori=squeeze(ori);
        ori=ori';
    end
        
    if isempty(orientation)
        if size(dat, 2)==1
            error('Method should use orientation but none is given. Use either cfg.orientation or use 3 dim data');
        else
            ori=dat./vecnorm(dat);
        end
    end
end


if size(dat,2)==3
    dat=vecnorm(dat);
end



%dat(dat < max(dat)*thresh) = NaN;


[~,idm] = max(dat);

pos = round(pos);
xx = linspace(1,mri.dim(1),mri.dim(1));
yy = linspace(1,mri.dim(2),mri.dim(2));
zz = linspace(1,mri.dim(3),mri.dim(3));

% sagittal_pos = [.1 .55 .4 .4];
% coronal_pos  = [.55 .55 .4 .4];
% axial_pos    = [.1 .05 .4 .4];

count = pos(idm,:); %gives the slice in x-y-z

dat = (dat - min(dat)) / ( max(dat) - min(dat));

indexForNan=dat<thresh;
dat(indexForNan) = NaN;

if useOri
ori(indexForNan,:)=NaN;
end

%mri.anatomy(find(mri.anatomy==0))=NaN;

plotData;






%%
    function plotData()
        
        for k=1:3
            
            if mod(count(k),2)==1
                if count(k) < mri.dim(k)
                    count(k)=count(k)+1;
                else
                    count(k)=count(k)-1;
                end
            end
            
        end
        
        
        
        symS=10;
        sym='o';
        
        
        
        
        clf;
        disp(count);
        ax1 = axes('Parent',f,'Units','normalized');
        ax2 = axes('Parent',f,'Units','normalized', 'Tag', '1');

        ax3 = axes('Parent',f,'Units','normalized');
                
                
        idx=find(pos(:,1)==count(1));
        
        
        if useZoom
        [gr1 gr2]=meshgrid(yy, zz);
        
        kk=rot90(cont_enh(squeeze(mri.anatomy(count(1),:, :))), 0);
        scatter(ax1, gr2(:),gr1(:), symS, kk(:), sym, 'filled');
        else 
            imagesc(ax1, yy,zz,cont_enh(rot90(squeeze(mri.anatomy(count(1),:,:)))));
        end
        
        hold on;
        scatter(ax2, pos(idx,2),pos(idx,3),symS,dat(idx,:),sym,'filled');
        
        if useOri
        quiver(ax3, pos(idx,2),pos(idx,3), ori(idx, 2), ori(idx, 3), 0.2, 'color', 'red');
        end
        
        % im2 = imagesc(ax3,yy,zz,nan(mri.dim(2),mri.dim(3)));  set(im2,
        % 'AlphaData', 0) %what does this do?
        
        
            if layout(1)==2 &&layout(2)==2
                text(-60,mri.dim(2)+10,'P/I','color','w','fontweight','bold','fontsize',fss)
                text(mri.dim(2)-20,mri.dim(3)+10,'A','color','w','fontweight','bold','fontsize',fss)
                text(-60,-30,'S','color','w','fontweight','bold','fontsize',fss)
                
                text(0, mri.dim(2)+10, ['Sagittal ' num2str(count(1)) '/' num2str(mri.dim(1))],'fontsize',fss, 'color', 'w');
            end   
                
              %  text(mri.dim(2)-50,20,[num2str(floor(1000*time)) ' ms'],'color','w','fontweight','bold','fontsize',fss)
               %  title(['Sagittal ' num2str(count(1)) '/' num2str(mri.dim(1))],'fontsize',fss, 'color', 'w')
               
            if layout(1)==1 &&layout(2)==3 %horizontal layout
                text(-100,mri.dim(2),'P/I','color','w','fontweight','bold','fontsize',fss)
                text(mri.dim(2)-50,mri.dim(2),'A','color','w','fontweight','bold','fontsize',fss)
                text(-30, mri.dim(2), ['Sagittal ' num2str(count(1)) '/' num2str(mri.dim(1))],'fontsize',fss, 'color', 'w');

                
                text(-100,-10,'S','color','w','fontweight','bold','fontsize',fss)
                
            end
            
            
            
        
        
        
        
        axis([1 mri.dim(2) 1 mri.dim(3)])
        axis off
        
        % Link them together
        linkaxes([ax1,ax2,ax3])
        % Hide the top axes
        ax1.Visible = 'off';
        ax2.Visible = 'off';
        ax3.XTick = [];
        ax3.YTick = [];
        % Give each one its own colormap
        
        
        colormap(ax1,'gray');
        colormap(ax2, map);
        caxis(ax2, [0 1])
        
      %  colorbar(ax2);
        
      ax1.Tag='11';
      ax2.Tag='12';  
      ax3.Tag='13';
      
        subplot_tight(layout(1),layout(2),1,[],ax1)
        subplot_tight(layout(1),layout(2),1,[],ax2)
        subplot_tight(layout(1),layout(2),1,[],ax3)
        
        
        % %         scatter(ax2,pos(idx,1),pos(idx,3),scale*dat(idx,:),dat(idx,:),'s','filled');
        
        %%
        
        ax1 = axes('Parent',f,'Units','normalized');
        ax2 = axes('Parent',f,'Units','normalized', 'Tag', '2');
        ax3 = axes('Parent',f,'Units','normalized');
        
        idx=find(pos(:,2)==count(2));
        
        
        if useZoom
            
            [gr1 gr2]=meshgrid(xx, zz);
            
            kk=rot90(cont_enh(squeeze(mri.anatomy(:,count(2), :))), 1);
            scatter(ax1, gr1(:),rot90(gr2(:),2), symS, kk(:), sym, 'filled');
        else
            imagesc(ax1, xx,zz,rot90(cont_enh(squeeze(mri.anatomy(:,count(2),:)))));
        end
        
        
        hold on;
        scatter(ax2, pos(idx,1),pos(idx,3),symS,dat(idx,:),sym,'filled');
        
        if useOri
            
            quiver(ax3, pos(idx,1),pos(idx,3), ori(idx, 1), ori(idx, 3), 0.2, 'color', 'red');
        end
        % im2 = imagesc(ax3,yy,zz,nan(mri.dim(2),mri.dim(3)));  set(im2,
        % 'AlphaData', 0) %what does this do?
      
        if layout(1)==2 &&layout(2)==2

        text(-20,mri.dim(2)+10,'L/I','color','w','fontweight','bold','fontsize',fss)
        text(mri.dim(2)-50,mri.dim(3)+10,'R','color','w','fontweight','bold','fontsize',fss)
        text(-20,-30,'S','color','w','fontweight','bold','fontsize',fss)
        text(20, mri.dim(2)+10,['Coronal ' num2str(count(2)) '/' num2str(mri.dim(2))],'fontsize',fss, 'color', 'w');
        
        %title(['Coronal ' num2str(count(2)) '/' num2str(mri.dim(2))],'fontsize',fss)
        
        end
        
        if layout(1)==1 &&layout(2)==3 %horizontal layout
            
        text(-40,mri.dim(2),'L/I','color','w','fontweight','bold','fontsize',fss)
        text(-65+mri.dim(2),mri.dim(2),'R','color','w','fontweight','bold','fontsize',fss)
        text(-40,-10,'S','color','w','fontweight','bold','fontsize',fss)
        text(20, mri.dim(2),['Coronal ' num2str(count(2)) '/' num2str(mri.dim(2))],'fontsize',fss, 'color', 'w');
        

           
        end
        
        
        
        
        
        
        
        
        
        axis([1 mri.dim(1) 1 mri.dim(3)])
        axis off
        
        % Link them together
        linkaxes([ax1,ax2,ax3])
        % Hide the top axes
        ax1.Visible = 'off';
        ax2.Visible = 'off';
        ax3.XTick = [];
        ax3.YTick = [];
        % Give each one its own colormap
        
        
        colormap(ax1,'gray');
        
        caxis(ax2, [0 1])
        colormap(ax2, map);
     %   colorbar(ax2);
        
      ax1.Tag='21';
      ax2.Tag='22';  
      ax3.Tag='23';
        
        subplot_tight(layout(1),layout(2),2,[],ax1)
        subplot_tight(layout(1),layout(2),2,[],ax2)
        subplot_tight(layout(1),layout(2),2,[],ax3)
        
        %%
        
        ax1 = axes('Parent',f,'Units','normalized');
        ax2 = axes('Parent',f,'Units','normalized', 'Tag', '3');
        ax3 = axes('Parent',f,'Units','normalized');
        
        idx=find(pos(:,3)==count(3));
        
        
        if useZoom
            
            [gr1 gr2]=meshgrid(xx, zz);
            
            kk=rot90(cont_enh(squeeze(mri.anatomy(:,:, count(3)))), -1);
            scatter(ax1, rot90(gr1(:),-1),gr2(:), symS, kk(:), sym, 'filled');
        else
            imagesc(ax1, xx,zz,rot90(cont_enh(squeeze(mri.anatomy(:,:, count(3))))));
            
        end
        
        
        
        hold on;
        
        scatter(ax2, pos(idx,1),pos(idx,2),symS,dat(idx,:),sym,'filled');
        if useOri
        quiver(ax3, pos(idx,1),pos(idx,2), ori(idx, 1), ori(idx, 2), 0.2, 'color', 'red');
        end
        % im2 = imagesc(ax3,yy,zz,nan(mri.dim(2),mri.dim(3)));  set(im2,
        % 'AlphaData', 0) %what does this do?
        
        if layout(1)==2 &&layout(2)==2 %horizontal layout
            
            text(-40,mri.dim(2)+10,'L/P','color','w','fontweight','bold','fontsize',fss)
            text(mri.dim(2)-70,mri.dim(3)+10,'R','color','w','fontweight','bold','fontsize',fss)
            text(-40,-30,'A','color','w','fontweight','bold','fontsize',fss)
            %title(['Axial ' num2str(count(3)) '/' num2str(mri.dim(3))],'fontsize',fss)
            text(10, mri.dim(2)+10, ['Axial ' num2str(count(3)) '/' num2str(mri.dim(3))],'fontsize',fss, 'color', 'w');
            
        end
        
        if layout(1)==1 &&layout(2)==3 %horizontal layout
            
            
            
            
             text(-5,mri.dim(2),'L/P','color','w','fontweight','bold','fontsize',fss)
            text(mri.dim(2)-40,mri.dim(3),'R','color','w','fontweight','bold','fontsize',fss)
            text(-5,-10,'A','color','w','fontweight','bold','fontsize',fss)
            %title(['Axial ' num2str(count(3)) '/' num2str(mri.dim(3))],'fontsize',fss)
            text(60, mri.dim(2), ['Axial ' num2str(count(3)) '/' num2str(mri.dim(3))],'fontsize',fss, 'color', 'w');
            
            
            
            
            
            
%             text(-40,mri.dim(2),'L/I','color','w','fontweight','bold','fontsize',fss)
%             text(-65+mri.dim(2),mri.dim(2),'R','color','w','fontweight','bold','fontsize',fss)
%             text(-40,-10,'S','color','w','fontweight','bold','fontsize',fss)
%             text(20, mri.dim(2),['Coronal ' num2str(count(2)) '/' num2str(mri.dim(2))],'fontsize',fss, 'color', 'w');
%             
            
            
        end
        
        
        
                
        axis([1 mri.dim(1) 1 mri.dim(2)])
        axis off
        
        % Link them together
        linkaxes([ax1,ax2,ax3])
        % Hide the top axes
        ax1.Visible = 'off';
        ax2.Visible = 'off';
        ax3.XTick = [];
        ax3.YTick = [];
        % Give each one its own colormap
        
        
        colormap(ax1,'gray');
        colormap(ax2, map);
        caxis(ax2, [0 1])
        
      if cb==1 && layout(1)==2 &&layout(2)==2
           H=colorbar(ax2);
           
       end
           
         ax1.Tag='31';
      ax2.Tag='32';  
      ax3.Tag='33';
        
        subplot_tight(layout(1),layout(2),3,[], ax1)
        subplot_tight(layout(1),layout(2),3,[],ax2)
        subplot_tight(layout(1),layout(2),3,[],ax3)
        
       if cb==1 && layout(1)==1 &&layout(2)==3
           H=colorbar(ax2);
           H.Position(1)=0.95;
       end
       
        
       
       
    end


    function ImageClickUp ( src , evnt )
        axesHandle  = get(src,'CurrentAxes');
        coordinates = get(axesHandle,'CurrentPoint');
        coordinates = coordinates(1,1:2);
        rcoords     = round(coordinates);
        
        g=gca;
        g.Tag
       % i don't know why I need to do this ...
       if ~useZoom
       switch g.Tag
           
           case '11'
               rcoords(2)=mri.dim(3)-rcoords(2);
               
           case '22'
               rcoords(2)=mri.dim(str2double(g.Tag(2)))-rcoords(2);
               
           case '33'
               rcoords(2)=mri.dim(2)-rcoords(2);
    
       end
       else
                   rcoords(2)=mri.dim(2)-rcoords(2); %this will surely make an error sometime later
       end
        
        for k=1:length(f.Children)
            
            if isequal(g.Position, f.Children(k).Position) && ~isempty(f.Children(k).Tag)
                Tag=f.Children(k).Tag;
                break;
            end
        end
        
        
        switch Tag(1)
            
            case '1'
                count2 = [count(1), rcoords(1),  mri.dim(3)-rcoords(2)];
                
            case '2'
                count2 = [rcoords(1), count(2), mri.dim(3)-rcoords(2)];
                
            case '3'
                count2 = [rcoords(1), mri.dim(2)-rcoords(2), count(3)];
                
            otherwise
                disp('there was a mistake');
                count2=count;
                
        end
        
        if count2(1) > 0 && count2(1) < mri.dim(1) && ...
                count2(2) > 0 && count2(2) < mri.dim(2) && ...
                count2(3) > 0 && count2(3) < mri.dim(3)
            count = count2;
            plotData()
        end
        %
        %         ax_pos = axesHandle.Position;
        %         if round(pdist2(ax_pos,sagittal_pos),1) == 0
        %             count2 = [count(1) rcoords(1) mri.dim(3) - rcoords(2)];
        %         elseif round(pdist2(ax_pos,coronal_pos),1) == 0
        %             count2 = [rcoords(1) count(2) mri.dim(3) - rcoords(2)];
        %         elseif round(pdist2(ax_pos,axial_pos),1) == 0
        %             count2 = [rcoords(1) mri.dim(2) - rcoords(2) count(3)];
        %         end
        %         if count2(1) > 0 && count2(1) < mri.dim(1) && ...
        %                 count2(2) > 0 && count2(2) < mri.dim(2) && ...
        %                 count2(3) > 0 && count2(3) < mri.dim(3)
        %             count = count2;
        %             plot_data()
        
    end


    function figScroll(src,evnt)
        
        %g=gca;
        
        
        
        if isprop(evnt,'VerticalScrollCount')
            scl = evnt.VerticalScrollCount;
        else
            scl = NaN;
        end

        
        %in which quarter is the mouse?
        
        if f.CurrentPoint(2) > (f.InnerPosition(4)-f.InnerPosition(2))/2
            quX=1;
        else
            quX=2;
        end
        
        if f.CurrentPoint(1) > (f.InnerPosition(3)-f.InnerPosition(1))/2
            quY=2;
        else
            quY=1;
        end
        
        
        if quX==1 &&quY==1
            tag=1;
        end
        
        if quX==1 &&quY==2
            tag=2;
        end
        
        if quX==2 &&quY==1
            tag=3;
        end
        
        if quX==2 &&quY==2
            warning('please click a plot!');
            return;
        end
        
        
        
        %tag=str2double(g.Tag);
        
        if scl<0
            
            if count(tag)<mri.dim(tag)-1
                count(tag)=count(tag)+2;
            else
                warning('dimension limit reached!');
            end
        end
        
        if scl>0
            
            if count(tag)>1
                count(tag)=count(tag)-2;
            else
                warning('dimension limit reached!');
            end
        end
        
        plotData;
        
    end




    function adj_img = cont_enh(img)
        img     = img/max(max(img)); % image normalization 
        adj_img = adapthisteq(img);
    end   






end

