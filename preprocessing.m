function [out_fname, nchan, ntrls,fs]=preprocessing(cond_nr,montage,mred,subERP)
%%% cond_nr: 1 to 6, conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
%%% montage: 0 - bipolar, 1 - grand average
%%% mred: mean reduction 0/1
%%% subERP: ERP subtraction 0/1

%% montage
%files with bipolar montage exist (result of the script bipolar_montage.m)
localisation ='_HG';
conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
subject = '348';
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' subject localisation '\'];
cond = char(conds(cond_nr));

if montage==0
    %bipolar_montage_HG(path,cond);
    condit = [cond, '_bipolar'];
elseif montage==1
    %GA_montage(path,cond);
    condit = [cond, '_GA'];
end
fname = [path, condit, '.mat']; 
fs = 1000;

%% load data
data=load(fname);
X = data.data_out;
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
%% artifact reduction

%% temporal mean reduction
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
%% highpass filtering and commented detrending
%detrend(x) removes the best straight-line fit from vector x and returns it in y....
%If x is a matrix, detrend removes the trend from each column.
[b,a] = butter(3, 5/(fs/2), 'high');
sig_out = zeros(size(sig));
for tr=1:ntrls
    for c = 1:nchan
        sig_out(c,:,tr) = filtfilt(b,a, sig(c,:,tr));
    end
    %sig_out(:,:,tr) = (detrend(sig_out(:,:,tr)'))';
end

%%
out_fname = [path,condit, '_mont_filt_.mat'];
save(out_fname, 'sig_out');
