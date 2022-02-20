clear;
clc;
SF = [7, 9, 11];
SNR = -1:-1:-30;
COEFF = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4]};

bw = config(2);
fs = config(3);
fft_scaling = config(4);
n_preamble_upchirp = config(5);

data_root=config(1);
data_path = [data_root, 'data/symbol/'];
key_words = 'basic_code2ser_';

feature_data_list = dir(fullfile(data_path));
n_feature_data_list = size(feature_data_list, 1);

for sf_index = 1:length(SF)
    sf_selected = SF(sf_index);

    SER = zeros(length(COEFF), 2^sf_selected);
    SER_counter = zeros(length(COEFF), 2^sf_selected);

    for feature_data_index = 1:n_feature_data_list
        feature_data_name = feature_data_list(feature_data_index).name;

        if strcmp(feature_data_name, '.') == 1 || strcmp(feature_data_name, '..') == 1
            continue;
        end

        raw_data_name_components = strsplit(feature_data_name, '_');
        % file_name = [num2str(sf), '_', num2str(coeff_index), '_', num2str(packet),'_', num2str(symbol), '_', num2str(value), '_', num2str(true_code)];

        sf = str2num(raw_data_name_components{1});
        coeff_index = str2num(raw_data_name_components{2});
        symbol_index = str2num(raw_data_name_components{4});
        estimated_code = str2num(raw_data_name_components{5});
        true_code = str2num(raw_data_name_components{6});

        if sf ~= sf_selected || mod(round(estimated_code), 2^sf) ~= true_code || symbol_index < n_preamble_upchirp + 2
            continue;
        end

        try
            fileID = fopen([data_path, feature_data_name], 'r');
            [encoded_chirp, count_data_read] = io_read_line(fileID);

            nsamp = fs * 2^sf / bw;
            coeff = COEFF{coeff_index};

            for snr_index = 1:length(SNR)
                snr = SNR(snr_index);
                encoded_chirp_noised = utils.add_noise(encoded_chirp, snr, fs, bw, sf);

                rz = chirp_dechirp_fft(encoded_chirp_noised, nsamp * fft_scaling, sf, coeff);

                z = chirp_comp_alias(rz, fs / bw);

                [ma, I] = max(abs(z));
                value = mod(round((I / numel(z) * 2^sf)), 2^sf);

                if value ~= true_code
                    SER(coeff_index, true_code+1) = SER(coeff_index, true_code+1) + 1;
                end

                SER_counter(coeff_index, true_code+1) = SER_counter(coeff_index, true_code+1) + 1;
            end

        catch e
            fprintf(1, 'The identifier was:\n%s', e.identifier);
            fprintf(1, 'There was an error! The message was:\n%s', e.message);
            disp(feature_data_name);
        end

    end

    output_path = [data_root,'3_deployment/result/symbol_emulation/',key_words, num2str(sf_selected),'.mat'];
    SER = SER ./ SER_counter;
    save(output_path, 'SER');
end
