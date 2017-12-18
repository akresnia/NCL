function [X_bipolar] = bipolar_montage_HG(data_in)
%%% data_in is a matrix in format (chan x samples x trials)
% HG pairing

[chan,samp,epoc]=size(data_in);
X_bipolar = NaN(chan-1, samp, epoc);

for n = 1:(chan-1)
   X_bipolar(n,:,:) = data_in(n+1,:,:) - data_in(n,:,:);
end
%X = X_bipolar;
%save([path,condition, '_bipolar.mat'], 'X');
