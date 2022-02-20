clear;clc;
bw = config(2);
fs = config(3);
duty_cycle = 0.9;
n_payload = config(7);
n_packet = 20;

data_dir = [config(1),'data/transmitter/'];

if ~exist(data_dir, 'dir')
    mkdir(data_dir);
end

sf_list = [10];

coefficient_matrix = {[1],[1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4]};
label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2'};

keywords='outdoor';

for sf_index=1:length(sf_list)
    sf=sf_list(sf_index);
    for coeff_index=1:length(label_curving_list)
        coefficient=coefficient_matrix{coeff_index};
        %         data_generation(n_payload, sf, coefficient, bw, fs, duty_cycle, data_dir, [num2str(n_payload), '_',num2str(sf),'_',num2str(coeff_index),'_',keywords,'_dc090']);
        final_output = [];
        encoded_data = zeros(n_packet, n_payload);
        
        for packet_index = 1:n_packet
            [output, data_frequency] = packet_generation(n_payload, sf, coefficient, bw, fs);
            %     sig = complex(output(1,:),output(2,:));
            %     stft_nfft = 1024;
            %     n_classes = 2^sf / 4;
            %     stft_window = n_classes;
            %     stft_overlap = stft_window / 2;
            %     synth_win = hamming(stft_window, 'periodic');
            %     mixed_signal_spec=stft(sig, fs, 'Window', synth_win, 'OverlapLength', stft_overlap, 'FFTLength', stft_nfft, 'Centered', false);
            %     chirp_spectrum = mixed_signal_spec;
            %     align_win_len = size(chirp_spectrum, 1) / (fs/bw);
            %     chirp_spectrum_focused = chirp_spectrum(1:align_win_len, :) + chirp_spectrum(align_win_len + (1:align_win_len), :) + chirp_spectrum(end - align_win_len + 1:end, :);
            %     chirp_spectrum_abs = abs(chirp_spectrum_focused);
            %     surf([1:size(chirp_spectrum_abs, 2)], [-size(chirp_spectrum_abs, 1) / 2:size(chirp_spectrum_abs, 1) / 2 - 1], chirp_spectrum_abs, 'edgecolor', 'none'); view(2);
            
            output = reshape(output, 1, []);
            idle_count = floor(size(output, 2) * (1 / duty_cycle - 1));
            idle = zeros(1, idle_count);
            output = [idle,output];
            final_output = [final_output, output];
            encoded_data(packet_index, :) = data_frequency;
        end
        final_output = [final_output, idle];
        fileID = fopen([data_dir, num2str(n_payload), '_',num2str(sf),'_',num2str(coeff_index),'_',keywords,'_dc090'], 'w');
        fwrite(fileID, final_output, 'float');
        fclose(fileID);
        save([data_dir, num2str(n_payload), '_',num2str(sf),'_',num2str(coeff_index),'_',keywords,'_dc090', '.mat'], 'encoded_data');
    end
end
