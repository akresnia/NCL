conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
montages={'Bplr','CAvr','CRef'};

subject = '348';%'288_004' or '348'
ntrls = 75;
cond_nrs = [2,5];
mont_nr = 3; %1-bipolar, 2 - CAvr, 3-CRef
montage = char(montages(mont_nr));

dec = 4; %decimation factor
fs = 1000/dec; %sampling freq
subERP = 0; filt=0; %0/1
subflag = 1;
boot=0; %subtraction of bootstrapped (1) or "normal" (0) DTF plots
loc = 'TG'; %localisation 'HG' or 'TG'

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
if strcmp(loc, 'TG')     
    chansel = '1 , 3 ,4 ,9 , 10 , 11 , 12,17,18,19,20,28';%'1,9,17,25,33,40,48,56';
end
% chansel='6,7,9,10';

%% DTF analysis
%changed amultipcolor.m!
%channel descriptions are without bad electrodes (110/229 in 348_HG/348_TG)
path = [path subject '_' loc '\'];
for cond_nr=cond_nrs
    cond = char(conds(cond_nr));
    
    %checking if the .mat file exists:
    condit = [cond '_' montage];
    ns = ''; %temp name_suffix
    if subERP==1; ns='-ERP'; end
    if filt==0; name_suffix = [ns '_dec' num2str(dec)];
    else name_suffix = [ns '_dec' num2str(dec) '_filt'];end
    out_fname = [path,condit, name_suffix, '.mat'];

    t = length(dir(out_fname)); %0 if preprocessed file doesn't exist

    if t==0
        disp 'preprocessing...'
        [out_fname, nchan, ntrls,fs] = preprocessing(subject,loc,cond_nr,dec,mont_nr,subERP,filt);
    else
        nch = load([out_fname(1:end-4) '_nch.mat']);
        nchan = nch.nchan;
    end
    DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
        descfil,winlen,winshf,winnum,t0,t_end)    
end
%% Subtraction analysis
if subflag==1
    if (length(cond_nrs)==2 && (cond_nrs(2)-cond_nrs(1)==3))
        cond_nrs = cond_nrs(1);
    end
    for cond_nr=cond_nrs
        subtr_analysis(cond, path, montage, name_suffix,boot);
    end
end
