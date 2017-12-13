function [X_bipolar] = bipolar_montage_HG(data_in)
%%condition is a string 'Coh-0-2','Coh-2' etc, for saving.
%%% data_in is a matrix in format (chan x samples x trials)
% HG pairing

[chan,samp,epoc]=size(data_in);
X_bipolar = NaN(chan-1, samp, epoc);

for n = 1:(chan-1)
   X_bipolar(n,:,:) = data_in(n+1,:,:) - data_in(n,:,:);
%    for tr=1:size(X,3)
%        X_bipolar(n,:,tr) = (X_bipolar(n,:,tr) - mean(X_bipolar(n,:,tr)))/std(X_bipolar(n,:,tr));  
%    end
end
%X = X_bipolar;
%save([path,condition, '_bipolar.mat'], 'X');
