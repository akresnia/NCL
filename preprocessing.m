function [out_fname, nchan, ntrls,fs]=preprocessing(mont,loc, cond_nr,ch_del,montage,mred,subERP,filt)
%%% mont = 0; %montage done before; 0-no file, 1 - .mat file exists
%%% loc: 0 - HG, 1 - TG
%%% cond_nr: 1 to 6, conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
%%% montage: 0 - bipolar, 1 - grand average, 2 - common reference (raw data)
%%% mred: mean reduction 0/1
%%% subERP: ERP subtraction 0/1
%%% ch_del: deleting of electrode 110 (very low std for Coh-8)
%%% filt: flag for highpass filtering 5Hz 0/1

conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
subject = '348';

if loc == 0
    localisation ='_HG';
elseif loc == 1
    localisation ='_TG';
else
    error('loc parameter must be 0 (HG) or 1 (TG)');
end
%% loading data
%files with bipolar montage exist (result of the script bipolar_montage.m)
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' subject localisation '\'];
cond = char(conds(cond_nr));

if mont==0
data = load([path,cond '.mat'],'X'); 
data_in = data.X;
end
%% deleting bad electrode
%2nd in HG or 37th in TG
if ch_del==1
    if loc==0
        if mont==0
            data_in = [data_in(1,:,:);data_in(3:end,:,:)];
        end
        cond = [cond, '-110'];
    else % loc==1
        if mont==0
            data_in = [data_in(1:36,:,:);data_in(38:end,:,:)];
        end
        cond = [cond, '-229'];
    end
end
%% montage
if loc==1 %only common reference for TG
    montage=2;
end

if montage==0
    if mont==0
    bipolar_montage_HG(path,cond,data_in);
    end
    condit = [cond, '_bipolar'];
elseif montage==1
    if mont==0
        GA_montage(path,cond, data_in);
    end
    condit = [cond, '_GA'];
elseif montage==2
    if (mont==0 && ch_del==1)
        X = data_in;
        save([path,cond, '.mat'], 'X');
    end
    condit = cond;
else
    error('wrong montage parameter')
end

fname = [path, condit, '.mat']; 
fs = 1000;

%% load data
data=load(fname);
X = data.X;
nchan = size(X,1); %11 bipolar channels
ntrls = size(X,3); %75 trials

%% downsampling
dec = 2; %decimation factor
sig = NaN(nchan, size(X,2)/dec, ntrls);
fs = fs/dec;
for ch=1:nchan
    for tr=1:ntrls
        sig(ch,:,tr) = decimate(X(ch,:,tr),dec);
    end
end

 
%% temporal mean reduction
%done inside mmultar (DTF) package
if mred==1
    sig = mean_red(sig);
end

%% subtract ERP?
if subERP==1
    for c = 1:nchan
        ERP = mean(sig(c,:,:),3);
        for tr=1:ntrls    
            sig(c,:,tr) = sig(c,:,tr) - ERP;
        end
    end
end
%% highpass filtering (and commented detrending)
%detrend(x) removes the best straight-line fit from vector x and returns it in y....
%If x is a matrix, detrend removes the trend from each column.
% we probably should detrend windowed signal, not the raw one
sig_out = zeros(size(sig));
if filt==0
    name_suffix = 'mont.mat';
    sig_out = sig;
else
    [b,a] = butter(5, 5/(fs/2), 'high');
    for tr=1:ntrls
        for c = 1:nchan
            sig_out(c,:,tr) = filtfilt(b,a, sig(c,:,tr));
        end
        %sig_out(:,:,tr) = (detrend(sig_out(:,:,tr)'))';
    end
    name_suffix= 'mont_filt.mat';
end

%%
% zm = zeros(nchan,1);
% for i=1:nchan
% zm(i) = mean(std(sig_out(i,:,:)));
% end
% disp(zm)
% hold on
% plot(zm)
% title('mean std of channels')
out_fname = [path,condit, name_suffix];
save(out_fname, 'sig_out');
%stationarity check may be done in licz_smtmvar.m