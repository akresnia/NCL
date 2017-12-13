function [out_fname, nchan, ntrls,fs]=preprocessing(mont,loc, cond_nr,dec,montage,mred,subERP,filt)
%%% mont = 0; %montage done before; 0-no file, 1 - .mat file exists
%%% loc: 'HG', 'TG'
%%% cond_nr: 1 to 6, conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
%%% dec: decimation factor (suggested range 2-5)
%%% montage: 0 - bipolar, 1 - grand average, 2 - common reference (raw data)
%%% mred: mean reduction 0/1
%%% subERP: ERP subtraction 0/1
%%% filt: flag for highpass filtering 5Hz 0/1

conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
subject = '288_004';%'348';

%% loading data
%files with bipolar montage exist (result of the script bipolar_montage.m)
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' subject '_' loc '\'];
cond = char(conds(cond_nr));

if mont==0
data = load([path,cond '.mat'],'X'); 
data_in = data.X;
end
%% deleting bad electrode
%2nd in HG or 37th in TG (110/229)

if (strcmp(loc,'HG') && strcmp(subject,'348')) %loc=='HG'
    if mont==0
        data_in = [data_in(1,:,:);data_in(3:end,:,:)];
    end
    cond = [cond, '-110'];
elseif (strcmp(loc,'TG') && strcmp(subject,'348'))
    if mont==0
        data_in = [data_in(1:36,:,:);data_in(38:end,:,:)];
    end
    cond = [cond, '-229'];
end
%% montage
if strcmp(loc,'TG') %only common reference for TG
    montage=2;
end

if montage==0
    if mont==0
        data_mont = bipolar_montage_HG(path,cond,data_in);
        X = data_mont.X;
    end
    condit = [cond, '_bipolar'];
elseif montage==1
    if mont==0
        data_mont = GA_montage(path,cond, data_in);
        X = data_mont.X;
    end
    condit = [cond, '_GA'];
elseif montage==2
    if mont==0
        X = data_in;
        %save([path,cond, '.mat'], 'X');
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
nchan = size(X,1); %11 channels for 348 HG
ntrls = size(X,3); %75 trials

%% downsampling
%dec = 4; %decimation factor
sig = NaN(nchan, size(X,2)/dec, ntrls);
fs = fs/dec;
for ch=1:nchan
    for tr=1:ntrls
        sig(ch,:,tr) = decimate(X(ch,:,tr),dec);
    end
end

 
%% temporal mean reduction is done inside mmultar (DTF) package

%% subtract ERP?
ns = ''; %temp name_suffix
if subERP==1
    ns='-ERP';
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
    name_suffix = [ns '_dec' dec '.mat'];
    sig_out = sig;
else
    [b,a] = butter(5, 5/(fs/2), 'high');
    for tr=1:ntrls
        for c = 1:nchan
            sig_out(c,:,tr) = filtfilt(b,a, sig(c,:,tr));
        end
        %sig_out(:,:,tr) = (detrend(sig_out(:,:,tr)'))';
    end
    name_suffix= [ns '_dec' dec '_filt.mat'];
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