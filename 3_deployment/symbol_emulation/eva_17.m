% clear;
% clc;
% SF = [8, 10, 12];
% % SF = [7, 9, 11];
COEFF = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4]};

SNR = [-30:5:30];
bw = config(2);
fs = config(3);
fft_scaling = config(4);
n_preamble_upchirp = config(5);

data_root=config(1);
data_path = [data_root, 'data/symbol/'];
key_words = 'basic_snr2ser_symbol';

feature_data_list_raw = dir(fullfile(data_path));
preamble_peak_threshold = 20;

for sf = SF
    disp(sf);
    nsamp = fs * 2^sf / bw;
    SER = zeros(length(COEFF),length(SNR), 5);
    SER_counter = zeros(length(COEFF),length(SNR), 5);
    for coeff_index = 1:length(COEFF)
        coeff = COEFF{coeff_index};
        feature_data_list = list_filter(feature_data_list_raw, sf, coeff_index);

        % up_chirp = symbol_generation_by_frequency(0, sf, coeff, bw, fs);
        % down_chirp = conj(up_chirp);

        for feature_data_index = 1:length(feature_data_list) - 1
            feature_data_name_1 = feature_data_list(feature_data_index).name;
            feature_data_name_2 = feature_data_list(feature_data_index + 1).name;

            raw_data_name_components_1 = strsplit(feature_data_name_1, '_');
            true_code_1 = str2num(raw_data_name_components_1{6});

            raw_data_name_components_2 = strsplit(feature_data_name_2, '_');
            true_code_2 = str2num(raw_data_name_components_2{6});

            try
                fileID_1 = fopen([data_path, feature_data_name_1], 'r');
                [encoded_chirp_1, ~] = io_read_line(fileID_1);

                fileID_2 = fopen([data_path, feature_data_name_2], 'r');
                [encoded_chirp_2, ~] = io_read_line(fileID_2);

                offset = randi([1, floor(0.5 * nsamp)], 1);
                offset_index = ceil(offset / nsamp * 10);

                encoded_chirp_combined = encoded_chirp_1 + [zeros(1, offset), encoded_chirp_2(1:end - offset)];

                for snr_index = 1:length(SNR)
                    snr = SNR(snr_index);

                    encoded_chirp_combined_noised = utils.add_noise(encoded_chirp_combined, snr, fs, bw, sf);
                    
                    rz = chirp_dechirp_fft(encoded_chirp_combined_noised, nsamp * fft_scaling, sf, coeff);

                    z = chirp_abs_alias(rz, fs / bw);
        
                    [ma, I] = max(abs(z));
                    estimated_label = mod(round((I / numel(z) * 2^sf)), 2^sf);

                    if estimated_label ~= true_code_1
                        SER(coeff_index,snr_index, offset_index) = SER(coeff_index,snr_index, offset_index) + 1;
                    end
                    SER_counter(coeff_index,snr_index, offset_index) = SER_counter(coeff_index,snr_index,offset_index) + 1;
                end

            catch e
                fprintf(1, 'The identifier was:\n%s', e.identifier);
                fprintf(1, 'There was an error in %d! The message was:\n%s', e.stack.line, e.message);
                % delete(file_name);
                disp(feature_data_name_2);
            end

        end

    end
    output_path = [data_root,'3_deployment/result/symbol_emulation/', key_words,'_',num2str(sf),'_comp.mat'];
    SER = SER ./ SER_counter;
    save(output_path, 'SNR', 'SER');
end