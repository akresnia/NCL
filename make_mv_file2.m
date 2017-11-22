localisations = {'_HG', '_TG'};
conds = {'0-2', '0-4', '0-8', '2', '4','8'};
%for v = 1:length(conds)
    subject = '348';
    %fname = 'C:\Users\Alicja\Desktop\Newcastle\348\348_HG\Coh-4-bipolar_ERP.mat'; %path
    fname = 'test.mat';
    %fname = 'Coh-2-bipolar.mat';
    chans = 2;%11 channels
    ntrls = 1; %75 number of trials
    fsamp = 250; % sampling frequency
    fstart = 0;
    fend = 90; %100 max frequency
    pord = 0; % model order 0 - estimate
    format = 6; %MAT file
    trial_mode = 0; % 0 == multitrial; 1 == trial-by-trial
    %chansel = '1,3,5,7,9,11';
    chansel = '1,2';
    %descfil = 'C:\Users\Alicja\Desktop\Newcastle\348\348_HG\ChanNums.txt';
    descfil = 'testchans.txt';
    winlen = []; %100 window length [] 
    winshf = 0; %20 window shift 0
    winnum = 1; %20 number of windows #unobligatory

    baseln = 0; %estimate baseline
    bootst = 0; %run bootstrap
    siglev = 2; %significance level 1 = .99; 2 = .95; 3 = .9; 4 = .75;
    norm2 = 0; %ensemble mean

    mv = struct(...
        'fname',fname,'chans',chans,'recl',[],'ntrls',ntrls,'fsamp',fsamp,'fstart',fstart,'fend',fend,...
        'pord',pord,'method',1,'format',format,'trial_mode',trial_mode,...
        'chansel',chansel,...
        'descfil',descfil,...
        'winlen',winlen,'winshf',winshf,'winnum',winnum,...
        'norm0',1,'norm1',1,'norm2',norm2,...
        'baseln',baseln,'bootst',bootst,'siglev',siglev,'basenum',100,'bootpool',200,'bootnum',100,...
        'pDTF',1,'pNDTF',0,'pSpect',0,'pCohs',0,'pdDTF',1,'pPDC',1,'pffDTF',0,...
        'sDTF',1,'sNDTF',0,'sSpect',0,'sCohs',0,'sdDTF',0,'sPDC',0,'sffDTF',0,...
        'sAR',1,'savefigs',1,...
        'userange',1,'timerangestart',1,'timerangeend',250,'pautoflag',0,...
        'incl_instant',0);

    clearvars -except mv veps

    global FRQPMAX % number of points in frequency domain
    global FVL FVS
    FRQPMAX = 100;
    FVL = { struct('f',@liczSpectrum,'sx','_spec','tt','Power spectrum','hn','pSpect'),...
            struct('f',@liczCohs,'sx','_cohs','tt','Coherences','hn','pCohs'),...
            struct('f',@liczDTF,'sx','_DTF','tt','Normalized DTF','hn','pDTF'),...
            struct('f',@liczNDTF,'sx','_NDTF','tt','Non-normalized DTF','hn','pNDTF'),...
            struct('f',@liczdDTF,'sx','_dDTF','tt','Direct DTF','hn','pdDTF'),...
            struct('f',@liczPDC,'sx','_PDC','tt','Partial directed coherence','hn','pPDC'),...
            struct('f',@liczffDTF,'sx','_ffDTF','tt','Full frequency DTF','hn','pffDTF'),...
        };
    FVS = { struct('f',@podajSpectrum,'vn','spectrum'),...
            struct('f',@podajCohs,'vn','cohs'),...
            struct('f',@liczDTF,'vn','DTF'),...
            struct('f',@liczNDTF,'vn','NDTF'),...
            struct('f',@liczdDTF,'vn','dDTF'),...
            struct('f',@liczPDC,'vn','PDC'),...
            struct('f',@liczffDTF,'vn','ffDTF'),...
            struct('f',@podajAR,'vn','AR_A_H'),...
        };

    multar1m(mv)
%end