funs = {'Spectrum', 'Coherence', 'DTF','NDTF','dDTF','PDC','ffDTF'};
conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
cond_nrs = [1,4]; % choose conditions for comparison, cond_nr: 1 to 6

singleplots = {[1,3]};%,[3,6],[4,7]}; %{[]} or {[i,j]} or {[i,j],[k,l]}; indices of electr. 1:nchan
funnums = [3]; %[3,4] indices of functions from funs for individualplots; for plots' matrices defined in DTF_analysis.m

montages={'Bplr','CAvr','CRef'}; % only CRef montage for TG
mont_nr = 3; %there is no bipolar available yet
subject = '288_004'; %'348' or '288_004'
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' ];

%choose electrodes for analysis:
TG_electrodes = '28,36'; %number of el. in descfile (348:1-63) or (288:1-96) 
HG_electrodes = '2,3';%,4,5,6,7,8'; %(1-11) or (1-8)

%data and analysis parameters
dec = 10;%2; %decimation factor
fs = 1000/dec; %original sampling frequency 1000 Hz
subERP = 0; filt=0;
subflag = 0; %subtraction analysis 0/1
bootflag=1; %plotting of bootstrapped (1) or "normal" (0) DTF plots
baseflag=1;
%% DTF parameters
% 0-500ms = silence; 500-1200ms = ground; 1200-1900ms = figure+ground;
% 1900-2400ms = silence
t0 = 1; %time range 500/dec
t_end = 2400/dec;
winlen = 80/dec; %window length [samples]
fstart = 1; %freq range
fend = 30;
winshf = 20/dec; %window shift [samples]
winnum = []; %number of windows; [] = program calculates from wlen and wshf
chansel= '1-'; %'1,2,6,7,8'; '1-' = all

%% create file with channel numbers 
% in HG for bipolar mont. plots will be labeled with numbers of...
% more medial (smaller) electrode from each pair
TG_idx = str2num(TG_electrodes); HG_idx = str2num(HG_electrodes);
chn_HG = load([path,subject,'_HG\Coh-2.mat'], 'ChanNums');
chn_TG = load([path,subject,'_TG\Coh-2.mat'], 'ChanNums');
TG_HG_el_No = [chn_TG.ChanNums(TG_idx) chn_HG.ChanNums(HG_idx)]; %electrode numbers

fid = fopen([path 'TG_HG_chans.txt'],'wt');
fprintf(fid, '%d\n',TG_HG_el_No);
fclose(fid);

descfil = [path 'TG_HG_chans.txt'];

%% constructing file names
montage = char(montages(mont_nr));
fnumbs=[]; %initialising to avoid missing parameter for subtraction func

for cond_nr=cond_nrs 
    ns = ''; %temp name_suffix
    if subERP==1; ns='-ERP'; end
    if filt==0; name_suffix = [ns '_dec' num2str(dec)];
    else name_suffix = [ns '_dec' num2str(dec) '_filt'];end
    %name_suffix = '_dec4';
    cond = char(conds(cond_nr));
    condit = [cond '_' montage];
    if sum(strcmp(subject,{'348', '288_004'}))==0 %add every new subject to the cell after checking
        error('Subject not checked for bad electrodes')
    end
    out_fname_HG = [path,subject, '_HG\', condit, name_suffix, '.mat'];
    out_fname_TG = [path,subject, '_TG\',condit, name_suffix, '.mat'];

    %% check if files exist
    t = length(dir(out_fname_HG)); %0 if preprocessed file doesn't exist
    if t==0
        disp 'preprocessing...'
        preprocessing(subject,'HG',cond_nr,dec,mont_nr,subERP,filt);
    end
    
    t = length(dir(out_fname_TG)); %0 if preprocessed file doesn't exist
    if t==0
        disp 'preprocessing...'
        preprocessing(subject,'TG',cond_nr,dec,mont_nr,subERP,filt);
    end
    
    %% create new file
    data_HG = load(out_fname_HG);
    data_TG = load(out_fname_TG);
    data_HG = data_HG.sig_out;
    data_TG = data_TG.sig_out;

    TG_chan = data_TG(TG_idx,:,:);
    HG_chan = data_HG(HG_idx,:,:);
    data = [TG_chan;HG_chan];
    nchan1 = length(TG_idx) + length(HG_idx);
    nchan = size(data,1);
    % channels sanity check
    if nchan1 ~= nchan
        error('beep!')
    end
    ntrls = size(data,3);
    name_suffix_long = [name_suffix, '_',TG_electrodes,';', HG_electrodes,'_TG_HG']; 
    out_fname = [path,condit,name_suffix_long, '.mat'];
    save(out_fname,'data');

    %% DTF analysis
    %changed amultipcolor.m!
    %[out_fname, nchan, ntrls,fs] = preprocessing(mont,loc,cond_nr,ch_del,montage,mred,subERP,filt);

    DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
        descfil,winlen,winshf,winnum,t0,t_end, bootflag, baseflag)   

    %% Plotting single DTF plots
    if ~isempty(singleplots{1})
        boot_sfx='';
        if bootflag==1
            boot_sfx='_boot';
        end
        
        if baseflag==1
            base_sfx = '_base';
        end
        
        global FVL FVS
        load([out_fname '_mout.mat']); %saved results and mv params
        
        %idcs of saved and chosen functions; without 8=AR:
        fnumbs=setdiff(intersect(getfuncsavenumbers(mv),funnums),8); 
        
        for j=fnumbs %loop over saved and chosen DTF functions
            datv = eval([FVS{j}.vn boot_sfx]); %get the variable name
            if bootflag==1
                datv = squeeze(datv(:,:,:,2,:)); %1- lower, 2 -median, 3- upper
            end
            if baseflag
                datv_base = eval([FVS{j}.vn base_sfx]);
                datv_base = repelem(datv_base(:,:,1,:),1,1,100,1); %WHY???
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
        cond_nrs = cond_nrs(1);
    end
    for cond_nr=cond_nrs
        cond = char(conds(cond_nr));
        subtr_analysis(fnumbs, cond, path, montage, name_suffix_long,bootflag,singleplots,fstart,fend);
    end
end
