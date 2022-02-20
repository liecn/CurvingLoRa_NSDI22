clear
sf_selected_list = [4];
n_packet_list_selected = [1:8];
clc
coeff_selected_list = 1:5;
n_mixed_packet_list = 1:12;

close all

% LoRa modulation & sampling parameters
fs = config(3); % sample rate
bw = config(2); % LoRa bandwidth
n_preamble_upchirp = config(5);

sf_list = [7, 8, 9, 10, 11, 12];
CurvingLoRa = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4]};

head_len = 12.25;

correlation_threshold = 10;
preamble_peak_threshold = 3;

data_path = [config(1), 'data/outdoor/'];
groundtruth_path = [config(1), 'data/groundtruth/'];
% data_path = ['D:\papers\CurvingLoRa\preprocessing\data\receiver\outdoor_testbed_mixed_10\'];
% groundtruth_path = ['D:\papers\CurvingLoRa\preprocessing\data\receiver\outdoor_testbed_10\'];
for sf_index = sf_selected_list
    sf_selected = sf_list(sf_index);
    nsamp = 2^sf_selected * fs / bw;
    
    ans_matrix = cell(length(CurvingLoRa), length(n_packet_list_selected), length(n_mixed_packet_list));
    
    ans_matrix_count = cell(length(CurvingLoRa), length(n_packet_list_selected), length(n_mixed_packet_list));
    
    feature_data_list = dir(fullfile(data_path));
    n_feature_data_list = size(feature_data_list, 1);
    
    for feature_data_index = 1:n_feature_data_list
        feature_data_name = feature_data_list(feature_data_index).name;
        
        if strcmp(feature_data_name, '.') == 1 || strcmp(feature_data_name, '..') == 1
            continue;
        end
        
        raw_data_name_components = strsplit(feature_data_name, '_');
        % file_name = [num2str(sf), '_', num2str(coeff_index), '_', num2str(packet_index),'_', num2str(sir), '_', num2str(offset_index), '_', num2str(true_code)];
        
        sf = str2num(raw_data_name_components{1});
        coeff_index = str2num(raw_data_name_components{2});
        packet_index = str2num(raw_data_name_components{3});
        n_mixed_packets = str2num(raw_data_name_components{5});
        
        if sf ~= sf_selected || ~ismember(packet_index, n_packet_list_selected) || ~ismember(coeff_index, coeff_selected_list) || ~ismember(n_mixed_packets, n_mixed_packet_list)
            continue;
        end
        
        coeff = CurvingLoRa{coeff_index};
        true_frame_st_list = zeros(n_mixed_packets, 1);
        
        for ii = 1:n_mixed_packets
            true_frame_st_list(ii) = str2num(raw_data_name_components{5 + n_mixed_packets + ii});
        end
        
        try
            %% load raw signal
            fileID = fopen([data_path, feature_data_name], 'r');
            [mdata, count_data_read] = io_read_line(fileID);
            
            win_num = floor(length(mdata) / nsamp);
            init_win_info = cwin(0);
            win_set(1, win_num) = init_win_info;
            
            for i = 1:win_num
                win_set(i) = cwin(i);
                symb = mdata((i - 1) * nsamp + (1:nsamp));
                syms = symb_detect(symb, sf, preamble_peak_threshold);
                
                for s = syms
                    win_set(i).addSymbol(s);
                end
                
            end
            
            %% detect LoRa frames by preambles
            [start_win, bin_value] = frame_detect(win_set, sf, correlation_threshold);
            
            if isempty(start_win)
                disp('ERROR: No packet is found!\n');
                disp(feature_data_name);
                continue;
            end
            
            groundtruth_count = [];
            correction_count = [];
            
            for i = 1:length(start_win)
                frame_st_raw = bin_value(i);
                [pos_diff, pos_index] = min(abs(true_frame_st_list - frame_st_raw));
                
                pos = mod(pos_index - 1, 6) + 1;
                groundtruth_file = [raw_data_name_components{1}, '_', raw_data_name_components{2}, '_', num2str(pos), '_', raw_data_name_components{pos_index + 5}, '_gt.mat'];
                load([groundtruth_path, groundtruth_file]);
                
                frame_length = ceil(4.25 + length(final_data_frequency_groundtruth) + 1) * nsamp;
                
                n_payload_corrected = -1;
                
                for frame_st_comp_index = [-2, -1, 0, 1, 2]
                    frame_st = frame_st_raw + frame_st_comp_index * nsamp;
                    
                    if frame_st + frame_length > length(mdata) || frame_st<1
                        continue;
                    end
                    
                    raw = mdata(frame_st:frame_st + frame_length);
                    
                    [sig_raw, toff, foff] = frame_sync(raw, sf, 3);
                    %                     fprintf('File %s has toff of %f and foff of %f\n', feature_data_name,toff, foff);
                    
                    t = (0:numel(sig_raw) - 1) / fs;
                    sig = sig_raw .* exp(-1i * 2 * pi * foff * t);
                    
                    [code_list, n_payload_corrected_tested] = frame_decoder(sig, sf, coeff, final_data_frequency_groundtruth);
                    
                    if n_payload_corrected_tested == length(final_data_frequency_groundtruth) - n_preamble_upchirp
                        n_payload_corrected = n_payload_corrected_tested;
                        break;
                    elseif n_payload_corrected_tested > n_payload_corrected
                        n_payload_corrected = n_payload_corrected_tested;
                    end
                    
                end
                
                groundtruth_count = [groundtruth_count, length(final_data_frequency_groundtruth) - n_preamble_upchirp];
                
                correction_count = [correction_count, n_payload_corrected];
                
                fprintf('File %s has %d corrected of %d\n', feature_data_name, n_payload_corrected, length(final_data_frequency_groundtruth) - n_preamble_upchirp);
                
            end
            
            ans_matrix_count{coeff_index, packet_index, n_mixed_packets} = groundtruth_count;
            
            ans_matrix{coeff_index, packet_index, n_mixed_packets} = correction_count;
        catch e
            fprintf(1, 'The identifier was:%s', e.identifier);
            fprintf(1, 'There was an error in %d! The message was:\n%s',e.stack.line, e.message);
            disp(feature_data_name);
        end
    end
    
    save([config(1), '3_deployment/result/outdoor_emulation/outdoor_emulation_', num2str(sf), '.mat'], 'ans_matrix', 'ans_matrix_count');
end

fprintf('Experiment Finish!\n');
