%%% cond_nr: 1 to 6, 
conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
cond_nrs = [3,6];
%mred = 0; subERP = 0; ch_del = 1; filt=0;loc = 0; %localisation 0 - HG, 1 - TG
subflag=1;
mont =1; % .mat file exists
subject = '348';
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' ];
TG_electrodes = '28,36'; %number of row 1-63
HG_electrodes = '2,3,4,5,6,7,8,9,10'; %number of row 1-11
TG_idx = str2num(TG_electrodes); HG_idx = str2num(HG_electrodes);

%% create file with channel numbers
chn_HG = load([path,'348_HG\Coh-2.mat'], 'ChanNums');
chn_TG = load([path,'348_TG\Coh-2.mat'], 'ChanNums');
TG_HG_el_No = [chn_TG.ChanNums(TG_idx) chn_HG.ChanNums(HG_idx)]; %electrode numbers

fid = fopen([path 'TG_HG_chans.txt'],'wt');
fprintf(fid, '%d\n',TG_HG_el_No);
fclose(fid);

descfil = [path 'TG_HG_chans.txt'];

%% omitting preprocessing script
for i=1:length(cond_nrs)
    cond_nr = cond_nrs(i);
    if mont==1
        disp 'Remember to create all files that are resampled'
        name_suffix = 'mont.mat';
        cond = char(conds(cond_nr));
        condit_HG = [cond, '-110'];
        condit_TG = [cond, '-229'];
        out_fname_HG = [path,subject, '_HG\', condit_HG, name_suffix];
        out_fname_TG = [path,subject, '_TG\', condit_TG, name_suffix];
    else
        error('run preprocessing.m')
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
        error('beep')
    end
    ntrls = size(data,3);
    out_fname = [path,cond,'_',TG_electrodes,';', HG_electrodes,'_TG_HG.mat'];
    save(out_fname,'data');
    %% DTF parameters
    t0 = 250;
    t_end = 950;
    winlen = 40;
    fstart = 0;
    fend = 100;
    winshf = 10;
    winnum = [];
    fs = 500;
    chansel='1';
    for i=2:nchan %selecting all channels for analysis
    chansel=[chansel, ',',num2str(i)];
    end

    %% DTF analysis
    %changed amultipcolor.m!
    %[out_fname, nchan, ntrls,fs] = preprocessing(mont,loc,cond_nr,ch_del,montage,mred,subERP,filt);

    DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,...
        descfil,winlen,winshf,winnum,t0,t_end)    
end
montage = 'CRef';

%% Subtraction analysis
%dopracowa�!
if subflag==1
    d = cond(end); %2/4/8
    load([path,'Coh-0-', d ,'_',TG_electrodes,';', HG_electrodes,'_TG_HG_DTF_datv.mat'])
    datv_exp = load([path,'Coh-', d,'_',TG_electrodes,';', HG_electrodes,'_TG_HG_DTF_datv.mat']);
    datv_exp=datv_exp.datv;
    load([out_fname(1:end-4), '_opis.mat']);
    load('FVL.mat');
    smultipcolor(datv_exp-datv,0,1,FVL{3}.tt,{[montage...
        ' Coh-' d ' - Coh-0-' d] FVL{3}.sx},opis,1,0);
end