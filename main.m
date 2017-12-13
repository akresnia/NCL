conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
montages={'Bplr','CAvr','CRef'};

subject = '288_004';%'288_004' or '348'
ntrls = 75;
cond_nr = 6;
cond = char(conds(cond_nr));
mont_nr = 3; %1-bipolar, 2 - CAvr, 3-CRef
montage = char(montages(mont_nr));


dec = 4; %decimation factor
subERP = 0; filt=0; %0/1
subflag = 1;
loc = 'HG'; %localisation 'HG', 'TG'
mont = 0; % decimated .mat file exists

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
    [out_fname, nchan, ntrls,fs] = preprocessing(subject,loc,cond_nr,dec,mont_nr,subERP,filt);
else
    path = [path subject '_' loc '\'];
    condit = [cond '_' montage];
    
    ns = ''; %temp name_suffix
    if subERP==1; ns='-ERP'; end
    if filt==0; name_suffix = [ns '_dec' num2str(dec)];
    else name_suffix = [ns '_dec' num2str(dec) '_filt'];end
    
    out_fname = [path,condit, name_suffix, '.mat'];
    nch = load([out_fname(1:end-4) '_nch.mat']);
    nchan = nch.nchan;
    fs = 1000/dec;
end
DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
    descfil,winlen,winshf,winnum,t0,t_end)    



%% Subtraction analysis
if (subflag==1 && filt==0 && subERP ==0) 
    sfx = ['_' montage '_dec' num2str(dec)];
    b = length(cond) + length([sfx '.mat']);
    c = cond(end); %2/4/8
    
    load([out_fname(1:end-b) 'Coh-' c sfx '_DTF_datv.mat'])
    datv_ctrl = load([out_fname(1:end-b) 'Coh-0-' c sfx '_DTF_datv.mat']);
    datv_ctrl=datv_ctrl.datv; %control condition
    load([out_fname(1:end-b) 'Coh-0-' c sfx '_opis.mat']);
    load('FVL.mat');
    smultipcolor(datv-datv_ctrl,0,1,FVL{3}.tt,{[montage...
        ' Coh-' c ' - Coh-0-' c] FVL{3}.sx},opis,1,0);
end