function X_bipolar = bipolar_montage_HG(condition)
% HG pairing
fname = 'Coh-8';
fs=1000;
load([fname '.mat'],'X');
n_HG = size(X,1); %electrodes
bipolar_data = [];
bipolar_labels = [];
bipolar_type = [];
dec = 4; %decimation factor
X_bipolar = NaN(n_HG-1, size(X,2), size(X,3));


for n = 1:(n_HG-1)
   X_bipolar(n,:,:) = X(n+1,:,:) - X(n,:,:);
%    for tr=1:size(X,3)
%        X_bipolar(n,:,tr) = (X_bipolar(n,:,tr) - mean(X_bipolar(n,:,tr)))/std(X_bipolar(n,:,tr));  
%    end

end
save([fname '_bipolar.mat'], 'X_bipolar');
%% TG pairing
% TG_ind = find(All_ChanTypes==2);
% n_TG = numel(TG_ind);
% gridcols = numel(Old_ChanNums)/griddims;
% TG_grid = reshape(Old_ChanNums,[griddims,gridcols]);
% 
% for n = 1:numel(TG_grid)
%     if ismember(TG_grid(n),All_ChanNums)
%         if mod(n,griddims) > 0
%             if ismember(TG_grid(n)+1,All_ChanNums)
%                  from_ind = find(All_ChanNums == TG_grid(n));
%                  to_ind = find(All_ChanNums == TG_grid(n)+1);
%                  bipolar_temp = EEG.data(from_ind,:,:) - EEG.data(to_ind,:,:);
%                  bipolar_data = cat(1,bipolar_data,bipolar_temp);
%                  bipolar_labels = [bipolar_labels,[TG_grid(n);TG_grid(n)+1]];
%                  bipolar_type = [bipolar_type,2];
%             end
%         end
%         if n <= numel(TG_grid)-griddims
%             if ismember(TG_grid(n)+8,All_ChanNums)
%                  from_ind = find(All_ChanNums == TG_grid(n));
%                  to_ind = find(All_ChanNums == TG_grid(n)+griddims);
%                  bipolar_temp = EEG.data(from_ind,:,:) - EEG.data(to_ind,:,:);
%                  bipolar_data = cat(1,bipolar_data,bipolar_temp);
%                  bipolar_labels = [bipolar_labels,[TG_grid(n);TG_grid(n)+griddims]];
%                  bipolar_type = [bipolar_type,2];
%             end
%         end
%     end
% end