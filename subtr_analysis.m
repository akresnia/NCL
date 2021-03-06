function [ data_sub ] = subtr_analysis(funnums, cond, path, montage, name_suffix,...
    boot, baseflag,single_trials,fmin,fmax)
%plots figure which is a subtraction of coh- and coh-0- plots
%   funnums: list of int, indices of function in funs
%   cond: condition name (char) i.e. 'Coh-0-8'
%   path: directory of calculated DTF matrices
%   montage: 'Bplr' or 'CAvr' or 'CRef'
%   name_suffix: i.e. _dec4 or _dec4_filt
%   boot: bootstrap flag
%   baseflag: 0/1, subtract baseline
%   single_trials: cell for individual plotting, {[1,2],[1,4]} or {[]} etc.

c = cond(end); %2/4/8
fn1 = [path 'Coh-' c '_' montage name_suffix '.mat']; %filename1
fn2 = [path 'Coh-0-' c '_' montage name_suffix '.mat'];

boot_sfx='';
if boot==1
    boot_sfx='_boot';
end

chck = length(dir([fn1 '_mout.mat'])) + ...
    length(dir([fn2 '_mout.mat'])); %check if both files exist

if chck==2
    datv = load([fn1 '_mout.mat']);
    datv_ctrl = load([fn2 '_mout.mat']);%control condition data
    opis1 = datv.mv; %to get channel numbers; opis = description
    opis2 = datv_ctrl.mv;
    if isequal(opis1.opisy, opis2.opisy)==1 %check of channels descriptions
        global FVL FVS FRQPMAX
        for funnum=funnums
            condsub = [' Coh-' c ' - Coh-0-' c];
            funname = [FVS{funnum}.vn boot_sfx]; %get the variable name
            data = datv.(funname);
            data_ctrl = datv_ctrl.(funname);
            
            if baseflag==1
                per = 2; %1- lower, 2 -median, 3- upper percentile, for bootstrap calculations
                if boot==1
                    data = squeeze(data(:,:,:,per,:)); %1- lower, 2 -median, 3- upper
                    data_ctrl = squeeze(data_ctrl(:,:,:,per,:)); %1- lower, 2 -median, 3- upper
                end
                base_name = [FVS{funnum}.vn '_base'];
                baseline = repelem(datv.(base_name)(:,:,per,:),1,1,FRQPMAX,1); %2, because median
                datv0 = data - baseline;
                data(datv0<0)=NaN;
                
                baseline_ctrl = repelem(datv_ctrl.(base_name)(:,:,per,:),1,1,FRQPMAX,1); %2, because median
                datv_c = data_ctrl - baseline_ctrl;
                data_ctrl(datv_c<0)=NaN;
            end
            
            data_sub = data-data_ctrl;
            if (boot==0) || (boot==1 && baseflag==1)
                % 0,1 after data_sub are zaxis limits
                % 1,0 at the end: saveflag, autoscale flag
                smultipcolor(data_sub,0,1,FVL{funnum}.tt,{[montage...
                    condsub] FVL{funnum}.sx},opis1.opisy,1,0);                
            else

                smultipcolor3(data_sub,0,1,FVL{funnum}.tt,{[montage...
                    condsub 'Boot'] FVL{funnum}.sx},opis1.opisy,1,0);
            end
            single_plot(data_sub,funnum, single_trials, FVL, montage, condsub, opis1.opisy, fmin, fmax )
        end
    else
        disp('subtraction aborted, exp and control file have different sets of electrodes')
    end
else
    disp 'one input file does not exist'
end
end


