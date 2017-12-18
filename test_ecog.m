fname = 'C:\Users\Alicja\Desktop\Newcastle\348\348_HG\Coh-2.mat';
dat = load(fname);
X = dat.X;
s1 = X(5,:,5);%5s are arbitrary chosen from Coh-2-bipolar_stand.mat
s2 = X(8,:,7);
%s2 = X_bipolar(8,:,5)-mean(X_bipolar(8,:,:),3);
dec = 2;
s1 = decimate(s1,dec);
s2 = decimate(s2,dec);

dt = 1/(1000/dec); %1000 is an initial sampling freq
t = 0:dt:2.4-dt;
s = zeros(4,length(t));
N = size(t);

s(1,:) = s1;
%ms = mean(s(1,:));
%s(2,:) = 0.8*[ms, s(1,1:end-1)]+0.001*randn(N);
s(2,:) = [2*randn(1,4),s1(1:end-4)]+0.05*randn(N);
s(3,:) = s2;
%s(5,:) = (0.3*s(1,:))+(0.7*s(4,:));
s(4,:) = s(1,1:end).*s(3,1:end)+0.001*randn(N);
%s(4,:) = [s(1,1),s(1,1:end-1)].*([s(3,1),s(3,1:end-1)])+0.001*randn(N);
%s(7,:) = s(2,:)+0.0001*randn(N);
%s(7,:) = (0.5*[ms,ms,ms,s(1,1:end-3)]).*(0.8*[ms,s(4,1:end-1)])+0.001*randn(N);
plot(t,s(1,:),t,s(4,:))
save('test_ecog.mat', 's')
