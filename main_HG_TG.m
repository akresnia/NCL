%%% cond_nr: 1 to 6, 
conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
cond_nr = 6;
%mred = 0; subERP = 0; ch_del = 1; filt=0;
subflag=0;
%loc = 0; %localisation 0 - HG, 1 - TG
mont =1; % .mat file exists
subject = '348';

%% omitting preprocessing script
if mont==1
    disp "Remember to create all files that have new fs"
    name_suffix = 'mont.mat';
    cond = char(conds(cond_nr));
    condit_HG = [cond, '-110'];
    condit_TG = [cond, '-229'];
    path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' ];
    out_fname_HG = [path,subject, '_HG\', condit_HG, name_suffix];
    out_fname_TG = [path,subject, '_TG\', condit_TG, name_suffix];
else
    error('run preprocessing.m')
end

TG_electrodes = '1,2'; %number of row 1-11, not electrode
HG_electrodes = '1,2'; %number of row 1-63
%% create new file
data_HG = load(out_fname_HG, X);
data_TG = load(out_fname_TG, X);
data_HG = data_HG.X;
data_TG = data_TG.X;
TG_idx = str2num(TG_electrodes); HF_idx = str2num(HG_electrodes);
TG_chan = data_TG(TG_idx,:,:);
HG_chan = data_HG(HG_idx,:,:);
data = [TG_chan;HG_chan];
nchan1 = length(TG_idx) + length(HG_idx);
nchan2 = size(data,1);
%channels sanity check
if nchan1==nchan2
    nchan=nchan1;
else
    error('beep')
end
ntrls = size(data,3);
out_fname = [path,cond,TG_electrodes, HG_electrodes,'_TG_HG.mat'];
save(out_fname,'data');
%% DTF parameters
t0 = 250;
t_end = 950;
winlen = 40;
fstart = 0;
fend = 30;
winshf = 10;
winnum = [];
fs = 500;
chansel=[TG_electrodes,',',HG_electrodes];

%% create file with channel numbers
fid = fopen([path 'TG_HG_chans.txt'],'wt');
fprintf(fid, [TG_electrodes,',',HG_electrodes]);
fclose(fid);
descfil = [path 'TG_HG_chans.txt'];

%% DTF analysis
%changed amultipcolor.m!
%[out_fname, nchan, ntrls,fs] = preprocessing(mont,loc,cond_nr,ch_del,montage,mred,subERP,filt);
    
DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
    descfil,winlen,winshf,winnum,t0,t_end)    

montage = 'CRef';

%% Subtraction analysis
%dopracowaæ!
if subflag==1
    cond = '8'; %2/4/8
    if loc==0
        load([out_fname(1:end-13) '0-' cond '-110mont_DTF_datv.mat'])
        datv_exp = load([out_fname(1:end-13) cond '-110mont_DTF_datv.mat']);
        datv_exp=datv_exp.datv;
        load([out_fname(1:end-13) '0-' cond '-110mont_opis.mat']);
        load('FVL.mat');
        smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[montage...
            ' Coh-' cond ' - Coh-0-' cond] FVL{3}.sx},opis,1,0);
    else
        load([out_fname(1:end-15) '0-' cond '-229mont_DTF_datv.mat'])
        datv_exp = load([out_fname(1:end-15) cond '-229mont_DTF_datv.mat']);
        datv_exp=datv_exp.datv;
        load([out_fname(1:end-15) '0-' cond '-229mont_opis.mat']);
        load('FVL.mat');
        smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[montage...
            ' Coh-' cond ' - Coh-0-' cond] FVL{3}.sx},opis,1,0);
    end
end