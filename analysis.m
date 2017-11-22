%files with bipolar montage exist (result of the script bipolar_montage.m)
localisation ='_HG';
conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
subject = '348';
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' subject localisation '\'];
cond = char(conds(6));
montage = 0; %0 - bipolar, 1 - grand average
mred=0; %temporal mean reduction 0/1
subERP = 0;%subtract ERP?
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
%% highpass filtering & random stationarity check
t0 = 1;
t_end = 500;
winlen = 10;
sum = 0;
[b,a] = butter(3, 5/(fs/2), 'high');
sig = zeros(size(sig));
for tr=1:ntrls
    for c = 1:nchan
        sig(c,:,tr) = filtfilt(b,a, sig(c,:,tr));
        rand_t = randi([t0 t_end - winlen],1,1);
        sum = sum+ adftest(sig(c,rand_t:rand_t+winlen,tr));
    end
end
out_fname = [path,condition, '_mont_filt_.mat'];
save(out_fname, 'sig');
%% DTF analysis
fstart = 5;
fend = 50;
chansel = '1,2,3,4';
winshf = 5;
winnum = [];

DTF_analysis(out_fname, nchan, ntrls, fs,fstart,fend,chansel,winlen,winshf,winnum,t0,t_end)