function [out_fname, nchan, ntrls,fs]=preprocessing(subject,loc, cond_nr,dec,mont_nr,subERP,filt)
%%% subject: '288_004' or '348';
%%% loc: 'HG', 'TG'
%%% cond_nr: 1 to 6, conds = {'Coh-0-2','Coh-0-4','Coh-0-8','Coh-2','Coh-4','Coh-8'};
%%% dec: decimation factor (suggested range 2-5)
%%% mont_nr: 1 - bipolar, 2 - common average, 3 - common reference (raw data)
%%% subERP: ERP subtraction 0/1
%%% filt: flag for highpass filtering 5Hz 0/1

conds = {'Coh-0-2', 'Coh-0-4', 'Coh-0-8', 'Coh-2', 'Coh-4','Coh-8'};
montages={'Bplr','CAvr','CRef'};
montage = char(montages(mont_nr));

%% loading data
%files with bipolar montage exist (result of the script bipolar_montage.m)
path = ['C:\Users\Alicja\Desktop\Newcastle\' subject '\' subject '_' loc '\'];
cond = char(conds(cond_nr));
data = load([path cond '.mat'],'X'); 
data_in = data.X;

%% deleting bad electrode
%2nd in HG or 37th in TG (110/229) for subject 348

if (strcmp(loc,'HG') && strcmp(subject,'348')) %loc=='HG'
    data_in = [data_in(1,:,:);data_in(3:end,:,:)];
    %cond = [cond, '-110'];
elseif (strcmp(loc,'TG') && strcmp(subject,'348'))
    data_in = [data_in(1:36,:,:);data_in(38:end,:,:)];
    %cond = [cond, '-229'];
elseif (strcmp(loc,'HG') && strcmp(subject,'288_004'))
    disp('no bad electrodes')
elseif (strcmp(loc,'TG') && strcmp(subject,'288_004'))
    disp('patient not checked for bad electrodes')
else
    disp('patient not checked for bad electrodes')
end
%% montage
if strcmp(loc,'TG') %only common reference for TG
    mont_nr=3;
end
condit = [cond '_' montage];
if mont_nr==1
    X = bipolar_montage_HG(data_in);
elseif mont_nr==2
    X = GA_montage(data_in);
    
elseif mont_nr==3
    X = data_in;
else
    error('wrong montage parameter')
end

fs = 1000; %sampling frequency

%% get data parameters
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
    name_suffix = [ns '_dec' num2str(dec)];
    sig_out = sig;
else
    [b,a] = butter(3, 5/(fs/2), 'high');
    for tr=1:ntrls
        for c = 1:nchan
            sig_out(c,:,tr) = filtfilt(b,a, sig(c,:,tr));
        end
        %sig_out(:,:,tr) = (detrend(sig_out(:,:,tr)'))';
    end
    name_suffix= [ns '_dec' num2str(dec) '_filt'];
end

out_fname = [path,condit, name_suffix, '.mat'];
save(out_fname, 'sig_out');
save([out_fname(1:end-4) '_nch.mat'], 'nchan');

%% std testing for bad electrodes removal
% zm = zeros(nchan,1);
% for i=1:nchan
% zm(i) = mean(std(sig_out(i,:,:)));
% end
% disp(zm)
% hold on
% plot(zm)
% title('mean std of channels')

%stationarity check may be done in licz_smtmvar.m