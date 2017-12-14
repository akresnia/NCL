%%% only CRef montage
conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
cond_nrs = [1,4]; % choose conditions for comparison, cond_nr: 1 to 6

montages={'Bplr','CAvr','CRef'};
mont_nr = 3; %there is no bipolar available for TG
subject = '348'; %'348' or '288_004'
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' ];

%choose electrodes for analysis:
TG_electrodes = '28,36'; %number of el. in descfile (348:1-63) or (288:1-96) 
HG_electrodes = '2,3,4,5,6,7,8'; %(1-11) or (1-8)

%data and analysis parameters
dec = 4; %decimation factor
fs = 1000/dec; %original sampling frequency 1000 Hz
subERP = 0; filt=0;
subflag = 1; %subtraction analysis 0/1
boot=0; %subtraction of bootstrapped (1) or "normal" (0) DTF plots

%% DTF parameters
% 0-500ms = silence; 500-1200ms = ground; 1200-1900ms = figure+ground;
% 1900-2400ms = silence
t0 = 500/dec; %time range
t_end = 1900/dec;
winlen = 80/dec; %window length [samples]
fstart = 0; %freq range
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

%% omitting preprocessing script
montage = char(montages(mont_nr));
for cond_nr=cond_nrs %i=1:length(cond_nrs); cond_nr = cond_nrs(i);
    ns = ''; %temp name_suffix
    if subERP==1; ns='-ERP'; end
    if filt==0; name_suffix = [ns '_dec' num2str(dec)];
    else name_suffix = [ns '_dec' num2str(dec) '_filt'];end
    %name_suffix = '_dec4';
    cond = char(conds(cond_nr));
    condit = [cond '_' montage];
    if sum(strcmp(subject,{'348', '288_004'}))==0
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
        descfil,winlen,winshf,winnum,t0,t_end)    
end

%% Subtraction analysis
if subflag==1
    if (length(cond_nrs)==2 && (cond_nrs(2)-cond_nrs(1)==3))
        cond_nrs = cond_nrs(1);
    end
    for cond_nr=cond_nrs
        subtr_analysis(cond, path, montage, name_suffix_long,boot);
    end
end
