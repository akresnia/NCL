function single_plot(datv,funnum, single_trials, FVL, montage, cond, opis, fmin, fmax )
%plot one figure with vertical lines in 500,1200,1900 ms
%   datv: 4D data matrix, chan x chan x freqpoints(y) x winnum(x)
%   funnum: int, index of function in funs
%   single_trials: {[1,2],[1,4]} or {[]} etc.
%   FVL: struct with function names, global
%   montage: string for title
%   cond: string i.e. 'Coh-0-8'
%   opis: channels description
%   fmin, fmax: frequency range of DTF data

if ~isempty(single_trials{1})
    for i=single_trials %{[1,1],[2,3]}
        idx1 = i{1}(1);
        idx2 = i{1}(2);
        el1 = opis(idx1); el2 = opis(idx2);
        figure('Name',[FVL{funnum}.sx(2:end) ' ' cond ' ' char(el2) '->' char(el1)]) %dDTF Coh-2 119->120

        pcolor(squeeze(datv(idx1,idx2,:,:)))
        shading(gca, 'flat')
        colorbar
        title({[montage cond] FVL{funnum}.sx(2:end)})
        ylabel(['sink ' el1 'frequency [Hz]']);
        xlabel(['time [ms] ' 'source' el2]);

        ax = gca;
        xlim = ax.XLim(2);
        set(ax,'XTick',linspace(0,xlim,9));%[0 xlim*5/24 xlim/2 xlim*19/24 xlim]);
        set(ax,'XTickLabel',{'0','300','600','900','1200','1500','1800','2100','2400'});
        set(ax,'TickDir','out');
        set(ax, 'XGrid','on');
        
        ylen = length(get(ax,'YTickLabel'));
        tcks = linspace(fmin,fmax,ylen+1);
        datastring=sprintf('%g,',round(tcks(2:end)));
        datastring = datastring(1:end-1);
        str_ticks= strsplit(datastring, ',');
        set(ax,'YTickLabel',str_ticks);
        
        % plot vertical lines:
        ylims = get(gca,'YLim');
        hold on
        plot([xlim*5/24, xlim*5/24],ylims, '--r')
        plot([xlim/2, xlim/2],ylims, '--r')
        plot([xlim*19/24, xlim*19/24],ylims, '--r')
    end
end
end

