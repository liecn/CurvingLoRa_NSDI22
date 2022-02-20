clear;
clc;
%% Plot Fig. 5: set chirp_type to 1-5 for different types of chirps
%We use 1 and 2 in the paper
chirp_type = 1;

%% Param Setting
sf_list = [7, 8, 9, 10, 11, 12];
CurvingLoRa = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4]}; 
bw = config(2);
fs = config(3);
fft_scaling = config(4);
sf = sf_list(4);

fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.4*3 3.3*3]);
set(gcf,'WindowStyle','normal','Position', [0,0,640*2,360*2]);
colormap(fig, hot);
color_disk = {'r', 'g', 'b', 'k'};

key_words = 'sir2peak';
chirp = CurvingLoRa{chirp_type};
ideal_upchirp = symbol_generation_by_frequency(2^sf / 2, sf, chirp, bw, fs);
ideal_downchirp = conj(ideal_upchirp);
nsamp = 2^sf * fs / bw;

stft_nfft = 1024;
n_classes = 2^sf / 4;
stft_window = n_classes;
stft_overlap = stft_window / 2;
synth_win = hamming(stft_window, 'periodic');

%% Spectrogram
symbol_SF1 = 2^sf;
signal_SF1 = symbol_generation_by_frequency(symbol_SF1, sf, chirp, bw, fs);

n_combined_signal_SF2 = 2;
symbol_SF2_list = [round(2^sf * 0.75), round(2^sf * 0.25)];
combined_signal_SF2 = [];

for j = 1:n_combined_signal_SF2
    symbol_SF2 = symbol_SF2_list(j);
    sig = symbol_generation_by_frequency(symbol_SF2, sf, chirp, bw, fs);
    combined_signal_SF2 = [combined_signal_SF2, sig];
end
shift_ratio = 0.6;
initial_index = round(size(signal_SF1, 2) * shift_ratio);
mixed_signal = signal_SF1 + combined_signal_SF2(:, initial_index:initial_index + size(signal_SF1, 2) - 1);
mixed_signal_spec=stft(mixed_signal, fs, 'Window', synth_win, 'OverlapLength', stft_overlap, 'FFTLength', stft_nfft, 'Centered', false);

chirp_spectrum = mixed_signal_spec;
align_win_len = size(chirp_spectrum, 1) / (fs/bw);
chirp_spectrum_focused = chirp_spectrum(1:align_win_len, :) + chirp_spectrum(align_win_len + (1:align_win_len), :) + chirp_spectrum(end - align_win_len + 1:end, :);
chirp_spectrum_abs = abs(chirp_spectrum_focused);
surf([1:size(chirp_spectrum_abs, 2)], [-size(chirp_spectrum_abs, 1) / 2:size(chirp_spectrum_abs, 1) / 2 - 1], chirp_spectrum_abs, 'edgecolor', 'none'); view(2);
shading interp
hold on;

% Label Line
plot3(ones(size(chirp_spectrum_abs, 1)+10,1)*26,[-size(chirp_spectrum_abs, 1) / 2-8:size(chirp_spectrum_abs, 1) / 2 +7],ones(size(chirp_spectrum_abs, 1)+10,1)*1000,'r-','LineWidth',10);

xlabel('Time (ms)');
ylabel('Frequency (kHz)');
xticks([1 7 * 4 15 * 4])
xticklabels({'0', '4', '8'})
xlim([1, size(chirp_spectrum_abs, 2)])
ylim([-size(chirp_spectrum_abs, 1) / 2, size(chirp_spectrum_abs, 1) / 2 - 1])
saveas(gcf, [config(1), 'figs/', key_words, '_', num2str(chirp_type), '_', num2str(shift_ratio), '_abs.png'])
clf

%% FFT Energy Peak Detection
chirp_dechirp = signal_SF1 .* ideal_downchirp;
chirp_fft_raw = (fft(chirp_dechirp, nsamp * fft_scaling));

chirp_peak_overlap = (chirp_abs_alias(chirp_fft_raw, fs / bw));
[pk_height_overlap, pk_index_overlap] = max(chirp_peak_overlap);

plot(chirp_peak_overlap, 'LineWidth', 10, 'Color', color_disk{4});
hold on;
plot(pk_index_overlap, pk_height_overlap, '-p', 'MarkerFaceColor', 'red', 'MarkerSize', 30)

sir = -10;
mixed_signal=0;
ref_ampl = 10^(sir / 20);
initial_index = round(length(signal_SF1) * shift_ratio);
mixed_signal = mixed_signal+combined_signal_SF2(initial_index:initial_index + nsamp - 1) / ref_ampl;

chirp_dechirp = mixed_signal .* ideal_downchirp;
chirp_fft_raw = (fft(chirp_dechirp, nsamp * fft_scaling));
chirp_peak_overlap = (chirp_abs_alias(chirp_fft_raw, fs / bw));
[pk_height_overlap, pk_index_overlap] = max(chirp_peak_overlap);
plot(chirp_peak_overlap, 'LineWidth', 10, 'Color', color_disk{1});

    
xlabel('Frequency Bins #');
ylabel('abs. FFT');
xlim([0, size(chirp_peak_overlap, 2)]);
legend({'Target Sig', 'Target Peak', 'Interfered Sig'},'Position', [0.6 0.83 0. 0.]);
xticks([0:round(length(chirp_peak_overlap) / 3.2):length(chirp_peak_overlap)]);
xticklabels({'0', '40', '80', '120'});
set(gca, 'ytick', []);
saveas(gcf, [config(1), 'figs/', key_words, '_', num2str(chirp_type), '_sir_abs.png'])