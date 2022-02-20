% clear;
clear;
clc;
sf_list = [10];
% coeff_list = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4]};
coeff_list = {[1, 0]};
bw = 125000;
fs = 250000;
fft_scaling = 10;

stft_nfft = 1024;

for sf_index = 1:length(sf_list)
    sf = sf_list(sf_index);
    nsamp = fs * 2^sf / bw;
    code = 2^sf / 2;

    n_classes = 2^sf / 4;
    stft_window = n_classes;
    stft_overlap = stft_window / 2;
    synth_win = hamming(stft_window, 'periodic');

    for coeff_index = 1:length(coeff_list)
        coeff = coeff_list{coeff_index}
        down_chirp = conj(symbol_generation_by_frequency(0, sf, coeff, bw, fs));

        encoded_chirp = symbol_generation_by_frequency(code, sf, coeff, bw, fs);

        chirp_spectrum = stft(encoded_chirp, fs, 'Window', synth_win, 'OverlapLength', stft_overlap, 'FFTLength', stft_nfft, 'Centered', false);
        align_win_len = size(chirp_spectrum, 1) / (fs/bw);
        chirp_spectrum_focused = chirp_spectrum(1:align_win_len, :) + chirp_spectrum(align_win_len + (1:align_win_len), :);
        % chirp_spectrum_focused=chirp_spectrum;
        chirp_spectrum_abs = abs(chirp_spectrum_focused);
        surf([1:size(chirp_spectrum_abs, 2)], [-size(chirp_spectrum_abs, 1) / 2:size(chirp_spectrum_abs, 1) / 2 - 1], chirp_spectrum_abs, 'edgecolor', 'none'); view(2);
        shading interp

        xlabel('Time (ms)');
        ylabel('Frequency (kHz)');
        xticks([1 7 * 4 15 * 4])
        xticklabels({'0', '4', '8'})
        xlim([1, size(chirp_spectrum_abs, 2)])
        ylim([-size(chirp_spectrum_abs, 1) / 2, size(chirp_spectrum_abs, 1) / 2 - 1])
        set(gcf, 'WindowStyle', 'normal', 'Position', [0, 0, 640 * 2, 360 * 2]);
        saveas(gcf, ['demo.png'])

        chirp_dechirp = encoded_chirp .* down_chirp;
        chirp_fft_raw = fft(chirp_dechirp, nsamp * fft_scaling);
        chirp_peak_overlap = abs(chirp_comp_alias(chirp_fft_raw, fs / bw));
        [pk_height_overlap, pk_index_overlap] = max(chirp_peak_overlap);
        estimated_label_true = pk_index_overlap / fft_scaling;
        estimated_label = mod(round(estimated_label_true), 2^sf);

        if estimated_label == code
            fprintf('decode correctly.\n')
        end

    end

end
