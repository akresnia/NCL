conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
montages={'Bplr','CAvr','CRef'};
funs = {'Spectrum', 'Coherence', 'DTF','NDTF','dDTF','PDC','ffDTF'};

singleplots = {[1,3],[3,4]};%, [4,5],[3,2],[3,7]}; %{[]} or {[i,j]} or {[i,j],[k,l]}; indices of electr. 1:nchan
funnums = [3,4]; %indices of funs [3,4,5,6]
subflag = 1; %0/1 - conduct subtraction analysis
bootflag=1; %plotting of bootstrapped (1) or "normal" (0) DTF plots
baseflag=1;

subject = '288_004';%'288_004' or '348'
loc = 'HG'; %localisation 'HG' or 'TG'

cond_nrs = [3,6];
mont_nr = 3; %1-bipolar, 2 - CAvr, 3-CRef
montage = char(montages(mont_nr));

dec = 4; %2 decimation factor
fs = 1000/dec; %sampling freq
subERP = 0; filt=0; %0/1

path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\']; 
%% DTF parameters
ntrls = 75; %number of trials
t0 = 1;%500/dec;
t_end =2400/dec; %whole=2400; 1900/dec;
winlen = 80/dec; % window length
fstart = 1; %frequency range for analysis
fend = 30;
winshf = 20/dec; %window shift
winnum = []; %calculated from winlen and winshf
chansel = '3,4,5,6,7'; %'1-' all channels 
descfil = [path loc '_chans.txt'];
if strcmp(loc, 'TG')     
    chansel = '1,3,4,9,10,11,12,17,18,19,20,28';% chosen for '348'
end

%% DTF analysis
%channel descriptions are without bad electrodes (110/229 in 348_HG/348_TG)
path = [path subject '_' loc '\'];
fnumbs=funnums; %initialising to avoid missing parameter for subtraction func
for cond_nr=cond_nrs
    cond = char(conds(cond_nr));
    
    %% Checking if the .mat file exists:
    condit = [cond '_' montage];
    ns = ''; %temp name_suffix
    if subERP==1; ns='-ERP'; end
    if filt==0; name_suffix = [ns '_dec' num2str(dec)];
    else name_suffix = [ns '_dec' num2str(dec) '_filt'];end
    out_fname = [path,condit, name_suffix, '.mat'];

    temp = length(dir(out_fname)); %0 if preprocessed file doesn't exist

    if temp==0
        disp 'preprocessing...'
        [out_fname, nchan, ntrls,fs] = preprocessing(subject,loc,cond_nr,dec,mont_nr,subERP,filt);
    else
        nch = load([out_fname(1:end-4) '_nch.mat']);
        nchan = nch.nchan;
    end
    DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
        descfil,winlen,winshf,winnum,t0,t_end, bootflag, baseflag)    

    %% Plotting single DTF plots
    if ~isempty(singleplots{1})
        boot_sfx='';
        if bootflag==1
            boot_sfx='_boot';
        end
        global FVL FVS
        load([out_fname '_mout.mat']); %saved results and mv params
        %idcs of saved and chosen functions; without 8=AR
        fnumbs=setdiff(intersect(getfuncsavenumbers(mv),funnums),8); 
        
        for j=fnumbs %loop over saved DTF functions
            datv = eval([FVS{j}.vn boot_sfx]); %get the variable name
            if bootflag==1
                datv = squeeze(datv(:,:,:,2,:)); %1- lower, 2 -median, 3- upper
            end
            if baseflag==1
                datv_base = eval([FVS{j}.vn '_base']);
                datv_base = repelem(datv_base(:,:,2,:),1,1,100,1); %2, because median
                datv0 = datv - datv_base;
                datv(datv0<0)=NaN;
            end
            single_plot(datv,j, singleplots, FVL, montage, cond, mv.opisy, fstart, fend, bootflag)
        end
    end

end



%% Subtraction analysis
if subflag==1
    if (length(cond_nrs)==2 && (cond_nrs(2)-cond_nrs(1)==3))
        cond_nrs = cond_nrs(1); %plot figure once when coh-i and coh-0-i
    end
    for cond_nr=cond_nrs
        cond = char(conds(cond_nr));
        subtr_analysis(fnumbs, cond, path, montage, name_suffix,bootflag,singleplots,fstart,fend);
    end
end
