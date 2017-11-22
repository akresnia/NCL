cond_nr = 1;
montage = 0; %0-bipolar, 1 - CAR
mred = 0; subERP = 0;
[out_fname, nchan, ntrls,fs] = preprocessing(cond_nr,montage,mred,subERP);

%% DTF analysis
t0 = 1;
t_end = 1200;
winlen = 40;
fstart = 70;
fend = 150;
chansel = '1,2,3,4,5,6,7,8,9,10,11';
winshf = 5;
winnum = [];
DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
    winlen,winshf,winnum,t0,t_end)