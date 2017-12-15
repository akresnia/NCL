function [ datv_sub ] = subtr_analysis(cond, path, montage, name_suffix, boot,single_trials,fmax,fmin)
%plots figure which is a subtraction of coh- and coh-0- plots
%   cond: condition name (char) i.e. 'Coh-0-8'
%   path: directory of calculated DTF matrices
%   montage: 'Bplr' or 'CAvr' or 'CRef'
%   name_suffix: i.e. _dec4 or _dec4_filt

c = cond(end); %2/4/8
fn1 = [path 'Coh-' c '_' montage name_suffix]; %filename1
fn2 = [path 'Coh-0-' c '_' montage name_suffix];

boot_sfx='';
if boot==1
    boot_sfx='_Boot';
end

chck = length(dir([fn1 '_DTF_datv' boot_sfx '.mat'])) + ...
    length(dir([fn2 '_DTF_datv' boot_sfx '.mat'])); %check if both files exist

if chck==2
    load([fn1 '_DTF_datv' boot_sfx '.mat']);
    datv_ctrl = load([fn2 '_DTF_datv' boot_sfx '.mat']);
    datv_ctrl = datv_ctrl.datv; %control condition data
    opis1 = load([fn1 '_opis.mat']); 
    load([fn2 '_opis.mat']);
    if isequal(opis1.opis, opis)==1
        load('FVL.mat');
        datv_sub = datv-datv_ctrl;
        if boot==0
        smultipcolor(datv_sub,0,1,FVL{3}.tt,{[montage...
            ' Coh-' c ' - Coh-0-' c] FVL{3}.sx},opis,1,0);
        else
        smultipcolor3(datv_sub,0,1,FVL{3}.tt,{[montage...
            ' Coh-' c ' - Coh-0-' c] FVL{3}.sx},opis,1,0);
        end
        for i=single_trials %{[1,1],[2,2]}
            i1 = i{1}(1);
            i2 = i{1}(2);
            if boot==0
%                 smultipcolor(datv_sub(i1,i2,:,:),0,1,FVL{3}.tt,{[montage...
%                 ' Coh-' c ' - Coh-0-' c] FVL{3}.sx},opis(i1),1,0);
                figure()
                pcolor(squeeze(datv_sub(i1,i2,:,:)))
                shading(gca, 'flat')
                colorbar
                
                global FRQPMAX
                fstep = (fmax - fmin)/FRQPMAX;
                ax = gca;
                %set(ax,'YTickLabel',num2str(linspace(fmin,fmax,10)));
                xlim = ax.XLim(2);
                set(ax,'XTick',[0 xlim*5/24 xlim/2 xlim*19/24 xlim]);
                set(ax,'XTickLabel',{'0','500','1200','1900','2400'});
                set(ax,'TickDir','out');
                set(ax, 'XGrid','on');
                %yticklabels({num2str(1:fstep:fmax)})
                ylabel('freq in constant scale 0-100');
                xlabel('time [ms]');
                
                ylims = get(gca,'YLim');
                hold on
                plot([xlim*5/24, xlim*5/24],ylims, '--r')
                plot([xlim/2, xlim/2],ylims, '--r')
                plot([xlim*19/24, xlim*19/24],ylims, '--r')
            end
        end
    else
        disp('subtraction aborted, exp and control file have different sets of electrodes')
    end
else
    disp 'one input file does not exist'
end
end


