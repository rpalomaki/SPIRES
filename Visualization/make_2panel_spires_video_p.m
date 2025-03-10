function make_2panel_spires_video_p(infiles,vidname,rrb)
%parallel implementation of function to create reprojected spires MODIS video
%input: infile - input h5 files, cell Nx1
%vidname : output vidname
%rrb : target rasterref w/ CRS

vars={'raw_snow_fraction','shade_fraction'};

[x,y]=worldGrid(rrb);
[lat,lon]=projinv(rrb.ProjectedCRS,x,y);
lat_l=ceil(lat(1,1)):-4:floor(lat(end,1));
lon_l=ceil(lon(1,1)):4:floor(lon(1,end));

[x,y]=projfwd(rrb.ProjectedCRS,mean(lat_l)*ones(size(lon_l)),lon_l);
[clon,~]=worldToIntrinsic(rrb,x,y);

[x,y]=projfwd(rrb.ProjectedCRS,lat_l,mean(lon_l)*ones(size(lat_l)));
[~,rlat]=worldToIntrinsic(rrb,x,y);
cm=colormap(parula);
close;
cm(1,:)=[0.5 0.5 0.5];
ltr={'(a)','(b)','(c)','(d)'};

spmd
    figure('Position',[1   1   1900 1200],'Color','w','Visible','off');
    set(gcf,'toolbar','none');
    tiledlayout(1,2,'TileSpacing','none','padding','tight');
    for j=1:length(vars)
        nexttile(j)
        imagesc;
        axis image;
        colormap(cm);
        set(gca,'YDir','reverse','Box','on','XTick',clon,'XTicklabel',[],...
            'YTick',rlat,'YTickLabel',[],'box','off');
        set(gca,'NextPlot','replaceChildren');
        if j==1
            set(gca,'YTick',rlat,'YTickLabel',num2str(lat_l'));
        end
        
        set(gca,'XTick',clon,'XTickLabel',num2str(lon_l'))
        
        c=colorbar('Location','SouthOutside');
%         c.Position(1)=c.Position(1)+0.25;
%         c.Position(2)=c.Position(2)+0.05;
         c.Position(3)=c.Position(3)-0.05;
        if j==1
            title('fsca_raw','Interpreter','none');
            caxis([0 1]);
        elseif j==2
            title('fshade');
            caxis([0 1])
        end
    end
end
frames={};

for ii=1:size(infiles,1)
    fname=infiles{ii};
    for j=1:2
        if j==1
            [fsca_raw,matdates,hdr]=GetEndmember(fname,vars{j});
        elseif j==2
            fshade=GetEndmember(fname,vars{j});
        end
    end

    parfor i=1:length(matdates)
        %need to initialize as empty temp var for parfor
        x=[];
        fsca_raw_f=[];
        fshade_f=[];
        mask=[];

        fsca_raw_i=fsca_raw(:,:,i);
        fshade_i=fshade(:,:,i);
        
        matdates_i=matdates(i);

        for j=1:length(vars)
            if j==1
                fsca_raw_f=rasterReprojection(fsca_raw_i,...
                    hdr.RasterReference,'InProj',hdr.ProjectionStructure,...
                    'rasterref',rrb);
                fsca_raw_f(fsca_raw_f<0)=0;
                mask=~isnan(fsca_raw_f);
                x=fsca_raw_f;
            elseif j==2
                fshade_f=rasterReprojection(fshade_i,...
                    hdr.RasterReference,'InProj',hdr.ProjectionStructure,...
                    'rasterref',rrb);
                fshade_f(fshade_f<0)=0;
                fshade_f(isnan(fshade_f))=0;
                x=fshade_f;
            
            end
            nexttile(j)
            imagesc(x,'AlphaData',mask);

            text(1,0.5,ltr{j},'FontSize',25,'VerticalAlignment','bottom',...
                'HorizontalAlignment','right','Units','normalized');
            if j==1
                text(0,1,datestr(matdates_i),'units','normalized',...
                    'FontSize',25,'VerticalAlignment','top');
            end

        end
        child=get(gcf,'children');
        child=child.Children;
        for y = 1:length(child)
            chi=child(y);
            set(chi, 'fontsize', 25);
        end
        frame=getframe(gcf);
        %parfor ensures frame order will be correct
        frames= [frames, frame];
        fprintf('done w/ %s\n', datestr(matdates_i));
    end
end

f=VideoWriter(vidname);
f.FrameRate=10;
f.Quality=90;
open(f);

for idx=1:numel(frames)
    writeVideo(f,frames{idx})
end

close(f);