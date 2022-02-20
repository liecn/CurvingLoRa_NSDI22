clear;
clc;
close all;
%%
start_phase=-pi/2;
end_phase=pi/2;
x = linspace(start_phase,end_phase,100);
y = 0.5*(sin(x)-sin(start_phase));
p_1 = polyfit(x,y,5);

start_phase=-3*pi/8;
end_phase=3*pi/8;
x = linspace(start_phase,end_phase,100);
y = 0.5*(sin(x)-sin(start_phase));
p_2 = polyfit(x,y,5);

SF = [7,9,11];
SNR = -5:-1:-30;
COEFF = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4],p_1(1:end-1),p_2(1:end-1)};

bw=config(2);
fs=125000;
fft_scaling=config(4);
SER=zeros(length(SF)*length(COEFF),length(SNR));

simu_iters=20000;

data_root = [config(1),'2_simulation/result/'];
key_words='snr2ser_fs125k';

for sf_index = 1:length(SF)
    sf=SF(sf_index);
    nsamp = fs * 2^sf / bw;
    for coeff_index = 1:length(COEFF)
        coeff = COEFF{coeff_index};
        down_chirp = conj(symbol_generation_by_frequency(0,sf, coeff, bw, fs));
        ser_index=(sf_index-1)*length(COEFF)+coeff_index;
        for snr_index = 1:length(SNR)
            snr = SNR(snr_index);
            error=0;
            for i = 1:simu_iters
                
                % encoded_data=randombits(sf);
                encoded_data=mod(i,2^sf);
                encoded_chirp = symbol_generation_by_frequency(encoded_data, sf,coeff, bw, fs);
                encoded_chirp_noised = awgn(encoded_chirp,snr);
                chirp_dechirp=encoded_chirp_noised.*down_chirp;
                
                chirp_fft_raw = (fft(chirp_dechirp, nsamp * fft_scaling));
                chirp_peak_overlap = abs(chirp_abs_alias(chirp_fft_raw, fs / bw));
                [pk_height_overlap, pk_index_overlap] = max(chirp_peak_overlap);
                estimated_label_true=pk_index_overlap/fft_scaling;
                estimated_label=mod(round(estimated_label_true),2^sf);
                if estimated_label ~= encoded_data
                    error = error+1;
                end 
            end
            SER(ser_index,snr_index) = error/simu_iters;
        end
    end
end
data_path = [data_root, key_words,'.mat'];
save(data_path, 'SNR','SER');