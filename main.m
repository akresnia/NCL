%%% cond_nr: 1 to 6, conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'
subject = '288_004';%'288_004' or '348'
ntrls = 75;
cond_nr = 3;
dec = 4; %decimation factor
subERP = 0; filt=0;
subflag = 0;
loc = 'TG'; %localisation 'HG', 'TG'
mont = 0; % decimated .mat file exists
montage = 2; %0-bipolar, 1 - CAR, 2-CRef
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\']; 
%% DTF parameters
t0 = 500/dec;
t_end = 1900/dec;
winlen = 80/dec;
fstart = 0;
fend = 30;
winshf = 20/dec;
winnum = [];
chansel = '1-';
descfil = [path loc '_chans.txt'];
% chansel='6,7,9,10';

%% DTF analysis
%changed amultipcolor.m!
%channel descriptions are without bad electrodes (110/229 in 348_HG/348_TG)
if strcmp(loc, 'TG')     
    chansel = '1 , 3  ,4 ,9 , 10 , 11 , 12,17,18,19,20,28';%'1,9,17,25,33,40,48,56';
end

if mont==0
    [out_fname, nchan, ntrls,fs] = preprocessing(subject,loc,cond_nr,dec,montage,subERP,filt);
else
    path = [path subject '_' loc '\'];
    condit = 'a';
    name_suffix = 'b';
    out_fname = [path,condit, name_suffix];
    nch = load([out_fname(1:end-4) 'n_ch.mat']);
    nchan = nch.nchan;
    fs = 1000/dec;
end
DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
    descfil,winlen,winshf,winnum,t0,t_end)    

montages={'bipolar','CAv','CRef'};

%% Subtraction analysis
if subflag==1
    cond = '8'; %2/4/8
    if strcmp(loc,'HG')
        load([out_fname(1:end-13) '0-' cond '-110mont_DTF_datv.mat'])
        datv_exp = load([out_fname(1:end-13) cond '-110mont_DTF_datv.mat']);
        datv_exp=datv_exp.datv;
        load([out_fname(1:end-13) '0-' cond '-110mont_opis.mat']);
        load('FVL.mat');
        smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[char(montages(montage))...
            ' Coh-' cond ' - Coh-0-' cond] FVL{3}.sx},opis,1,0);
    else
        load([out_fname(1:end-15) '0-' cond '-229mont_DTF_datv.mat'])
        datv_exp = load([out_fname(1:end-15) cond '-229mont_DTF_datv.mat']);
        datv_exp=datv_exp.datv;
        load([out_fname(1:end-15) '0-' cond '-229mont_opis.mat']);
        load('FVL.mat');
        smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[char(montages(montage))...
            ' Coh-' cond ' - Coh-0-' cond] FVL{3}.sx},opis,1,0);
    end
end