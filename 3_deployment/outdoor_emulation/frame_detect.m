function [start, value,bins] = frame_detect(winset,SF,correlation_threshold)

% LoRa modulation & sampling parameters
Fs = config(3);         % sample rate
BW = config(2);         % LoRa bandwidth
% SF = config(1);         % LoRa spreading factor
nsamp = Fs * 2^SF / BW;

start = [];
value = [];
bins = [];
state_table = containers.Map('KeyType','double','ValueType','double');
pending_keys = containers.Map('KeyType','double','ValueType','double');
state_table_bins = cell(2^SF,1);
n_dead_key=8;
% window by window traversal
for i = 1:length(winset)
%     if(i==30)
%         fprintf('stop');
%     end
    %         fprintf('window(%d)\n',i);
    key_set = cell2mat(keys(state_table));
    update_keys = containers.Map('KeyType','double','ValueType','double');
    
    % print keys
    %         fprintf('Keys:');
    for k = key_set
        update_keys(k) = 0;
        %                 fprintf(' %d',round(k));
    end
    %         fprintf('\n');
    
    % group each symbol to a possible frame
    symbset = winset(i).symset;
    
    %% print symbs
    %         fprintf('symbs:');
    %         for k = symbset
    %             fprintf(' %.d',round(k.bin));
    %         end
    %         fprintf('\n');
    
    for sym = symbset
        % detect consecutive preambles
        [I, key] = peak_nearest(key_set, mod(round(sym.bin),2^SF), 2);
        if I < 0
            state_table(mod(round(sym.bin),2^SF)+1) = 1;
            state_table_bins{mod(round(sym.bin),2^SF)+1}=[sym.bin];
        else
            state_table(key) = state_table(key) + 1;
            state_table_bins{key}=[state_table_bins{key}, sym.bin];
            update_keys(key) = 1;
            %                 if state_table(key) >= 5
            %                     pending_keys(key) = 10;
            %                 end
            if state_table(key) == n_dead_key
                pks=state_table_bins{key};
                
                %                 [~, I] = max(abs(pks - mean(pks)));
                %                 if I == 1 || I == 8
                %                     tmp = pks;
                %                 else
                %                     tmp = [pks(1:I-1), pks(I+1:end)];
                %                 end
                [~,tmp_index]=sort(abs(pks - mean(pks)));
                tmp=pks(tmp_index(1:5));
                pks_detection=max(abs(tmp - mean(tmp)));
                if pks_detection < correlation_threshold
                    % fprintf("frame detected with %d,%d!\n",pks_detection,pks_val_detection);
                    
                    frame_offset=round(mean(tmp)/2^SF * nsamp);
                    frame_st = (nsamp - frame_offset) + (i-length(pks))*nsamp;
                    if frame_offset<nsamp/2
                        frame_st = frame_st-nsamp;
                    end                   
                    start = [start, i-length(pks)+1];
                    value = [value, frame_st];
                    bins=[bins,key];
                    %                     remove(pending_keys, key);
                    update_keys(key) = 0;
                end
                
                
            end
            
        end
        
        % detect the first sync word (8)
        %             [I, key] = peak_nearest(key_set, mod(sym.bin-24, 2^SF), 2);
        %             if I > 0 && pending_keys.isKey(key)
        %                 fprintf('SYNC-1: %d\n',round(key));
        %                 pending_keys(key) = 10;
        %                 state_table(key) = state_table(key) + 1;
        %                 update_keys(key) = 1;
        %             end
        
        % detect the second sync word (16)
        %             [I,key] = peak_nearest(key_set, mod(sym.bin-32,2^SF), 2);
        %             if I > 0 && pending_keys.isKey(key) && pending_keys(key) > 5
        %                 fprintf('SYNC-2: %d\t Frame Detected\n',round(key));
        %                 start = [start, i-9];
        %                 value = [value, key];
        %                 remove(pending_keys, key);
        %                 update_keys(key) = 0;
        %             end
    end
    
    % delete items without updated
    for k = key_set
        %         if pending_keys.isKey(k) && pending_keys(k) > 0
        %             if update_keys(k) == 0
        %                 pending_keys(k) = pending_keys(k) - 1;
        %                 update_keys(k) = 1;
        %             end
        %         end
        
        if update_keys(k)== 0
            if state_table(k)>2&&state_table(k)<8
                state_table(k) = state_table(k) + 1;
                state_table_bins{k}=[state_table_bins{k},0];
                
                %             if ~isKey(state_table,k) || state_table(k)==n_dead_key
            else
                remove(state_table, k);
                state_table_bins{k}=[];
            end
            %                         fprintf('\tRemove %.2f from table\n',k);
        end
    end
end
end