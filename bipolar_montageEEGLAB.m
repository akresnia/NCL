%%
%Bipolar pairing%

% HG pairing
HG_ind = find(All_ChanTypes==1);
n_HG = numel(HG_ind);
bipolar_data = [];
bipolar_labels = [];
bipolar_type = [];

for n = 1:(n_HG-1)
    
    if All_ChanNums(HG_ind(n+1)) - All_ChanNums(HG_ind(n)) == 1
       bipolar_temp = EEG.data(HG_ind(n+1),:,:) - EEG.data(HG_ind(n),:,:);
       bipolar_data = cat(1,bipolar_data,bipolar_temp);
       bipolar_labels = [bipolar_labels,[All_ChanNums(HG_ind(n+1));All_ChanNums(HG_ind(n))]];
       bipolar_type = [bipolar_type,1];
    end
end

% TG pairing
TG_ind = find(All_ChanTypes==2);
n_TG = numel(TG_ind);
gridcols = numel(Old_ChanNums)/griddims;
TG_grid = reshape(Old_ChanNums,[griddims,gridcols]);

for n = 1:numel(TG_grid)
    if ismember(TG_grid(n),All_ChanNums)
        if mod(n,griddims) > 0
            if ismember(TG_grid(n)+1,All_ChanNums)
                 from_ind = find(All_ChanNums == TG_grid(n));
                 to_ind = find(All_ChanNums == TG_grid(n)+1);
                 bipolar_temp = EEG.data(from_ind,:,:) - EEG.data(to_ind,:,:);
                 bipolar_data = cat(1,bipolar_data,bipolar_temp);
                 bipolar_labels = [bipolar_labels,[TG_grid(n);TG_grid(n)+1]];
                 bipolar_type = [bipolar_type,2];
            end
        end
        if n <= numel(TG_grid)-griddims
            if ismember(TG_grid(n)+8,All_ChanNums)
                 from_ind = find(All_ChanNums == TG_grid(n));
                 to_ind = find(All_ChanNums == TG_grid(n)+griddims);
                 bipolar_temp = EEG.data(from_ind,:,:) - EEG.data(to_ind,:,:);
                 bipolar_data = cat(1,bipolar_data,bipolar_temp);
                 bipolar_labels = [bipolar_labels,[TG_grid(n);TG_grid(n)+griddims]];
                 bipolar_type = [bipolar_type,2];
            end
        end
    end
end