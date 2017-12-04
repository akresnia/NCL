%%% cond_nr: 1 to 6, conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'
cond_nr = 6;
mred = 0; subERP = 0; ch_del = 1; filt=0;
subflag=1;
loc = 1; %localisation 0 - HG, 1 - TG
mont = 1; % .mat file exists
%% DTF parameters
t0 = 250;
t_end = 950;
winlen = 40;
fstart = 0;
fend = 30;
winshf = 10;
winnum = [];
% chansel='6,7,9,10';

%% DTF analysis
%changed amultipcolor.m!
if loc==1
    montage = 2; j=2;
    descfil = 'C:\Users\Alicja\Desktop\Newcastle\348\348_TG\ChanNums-229.txt';
    chansel = '1 , 2 , 3  ,4 , 5 , 6 , 7 , 8';%'1,9,17,25,33,40,48,56';
else
    j = 2;
    montage = j; %0-bipolar, 1 - CAR, 2-common ref

    if ch_del==0
        descfil = 'C:\Users\Alicja\Desktop\Newcastle\348\348_HG\ChanNums.txt';
        chansel = '1,2,3,4,5,6,7,8,9,10,11,12';
        if j==0
            chansel = '1,2,3,4,5,6,7,8,9,10,11';
        end
    else
        descfil = 'C:\Users\Alicja\Desktop\Newcastle\348\348_HG\ChanNums-110.txt';
        chansel = '1,2,3,4,5,6,7,8,9,10,11';
        if j==0
           chansel = '1,2,3,4,5,6,7,8,9,10';
        end
    end
end
[out_fname, nchan, ntrls,fs] = preprocessing(mont,loc,cond_nr,ch_del,montage,mred,subERP,filt);
    
DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
    descfil,winlen,winshf,winnum,t0,t_end)    

montages={'bipolar','CAv','CRef'};

%% Subtraction analysis
if subflag==1
    cond = '2'; %2/4/8
    if loc==0
        load([out_fname(1:end-13) '0-' cond '-110mont_DTF_datv.mat'])
        datv_exp = load([out_fname(1:end-13) cond '-110mont_DTF_datv.mat']);
        datv_exp=datv_exp.datv;
        load([out_fname(1:end-13) '0-' cond '-110mont_opis.mat']);
        load('FVL.mat');
        smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[char(montages(j))...
            ' Coh-' cond ' - Coh-0-' cond] FVL{3}.sx},opis,1,0);
    else
        load([out_fname(1:end-13) '0-' cond '-229mont_DTF_datv.mat'])
        datv_exp = load([out_fname(1:end-13) cond '-229mont_DTF_datv.mat']);
        datv_exp=datv_exp.datv;
        load([out_fname(1:end-13) '0-' cond '-229mont_opis.mat']);
        load('FVL.mat');
        smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[char(montages(j))...
            ' Coh-' cond ' - Coh-0-' cond] FVL{3}.sx},opis,1,0);
    end
end