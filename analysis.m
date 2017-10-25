localisations = {'_HG', '_TG'};
conds = {'0-2', '0-4', '0-8', '2', '4','8'};
subject = '348';
fname = ['C:\Users\Alicja\Desktop\Newcastle\', subject,'\',subject,...
    '_HG', '\coh-', '2', '.mat']; %path
fs = 1000;
%load data
load(fname);
nchan = size(X,1); %12 channels
ntrls = size(X,3); %75 trials
%downsampling
%sig = decimate(X(1,:,1), 5);

%artifact reduction

%preprocessing: montage grand average (does it make sense for ECoG?)
Xm = mean_red(X);
%highpass filtering 
[b,a] = butter(3, 5/(fs/2), 'high');
sig = zeros(size(Xm));
for tr=1:ntrls
    for c = 1:nchan
        sig(c,:,tr) = filtfilt(b,a, Xm(c,:,tr));
    end
end

%one trial analysis
sig_1 =squeeze(sig(:,:,1));

%subtract ERP?
sig_erp = sig_1 - mean(sig,3);
%0-mean
sig_0m=zeros(size(sig_1));
for c=1:nchan
sig_0m(c,:) = sig_erp(c,:) - mean(sig_erp(c,:));
end
%normalise (std = 1)?

%calculate AR coefficients (A, V)
%transform to freq domain (->H)
%NDTF(f) = |H(f)|^2
%plot