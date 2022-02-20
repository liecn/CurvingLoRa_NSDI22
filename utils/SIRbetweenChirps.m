function sir2ser = SIRbetweenChirps(sf1, chirp1, sf2, chirp2, bw, fs, SIR_list, simu_iters, fft_scaling)
    ideal_upchirp1 = symbol_generation_by_frequency(0,sf1, chirp1, bw, fs);
    ideal_downchirp1 = conj(ideal_upchirp1);
    nsamp1 = 2^sf1 * fs / bw;
    nsamp2 = 2^sf2 * fs / bw;

    sir2ser = zeros(1, length(SIR_list));
    n_combined_signal_SF2 = 2;
    
    for SIR_index = 1:length(SIR_list)
        SIR=SIR_list(SIR_index);
        error_case = 0;
        correct_case = 0;
        for i = 1:simu_iters

            if sf1 > sf2
                n_combined_signal_SF2 = 2^(sf1 - sf2) + 1;
            end

            combined_signal_SF2 = [];

            for j = 1:n_combined_signal_SF2
                symbol_SF2 = randi([0,2^sf2-1],1);
                combined_signal_SF2 = [combined_signal_SF2, symbol_generation_by_frequency(symbol_SF2,sf2, chirp2, bw, fs)];
            end

            symbol_SF1 = randi([0,2^sf1-1],1);
            signal_SF1 = symbol_generation_by_frequency(symbol_SF1, sf1,chirp1, bw, fs);
            initial_index = ceil(rand * nsamp2);
            ref_ampl = 10^(SIR / 20); % intf_ampl = 1;
            mixed_signal = ref_ampl * signal_SF1 + combined_signal_SF2(initial_index:initial_index + nsamp1 - 1);
            
%             amp_interfere_gain = utils.interfere_gain_to_mix_signal(ref_ampl * signal_SF1,combined_signal_SF2(initial_index:initial_index + nsamp1 - 1),0)
            
            chirp_dechirp = mixed_signal .* ideal_downchirp1;

            chirp_fft_raw = (fft(chirp_dechirp, nsamp1 * fft_scaling));

            chirp_peak_overlap = abs(chirp_abs_alias(chirp_fft_raw, fs / bw));
            [pk_height_overlap, pk_index_overlap] = max(chirp_peak_overlap);
            estimated_label_true = pk_index_overlap / fft_scaling;
            estimated_label = mod(round(estimated_label_true), 2^sf1);

            if estimated_label ~= (symbol_SF1)
                error_case = error_case + 1;
            else
                correct_case=correct_case+1;
            end
            if(error_case==1000||correct_case==1000)
                break;
            end

        end
        sir2ser(1,SIR_index) = error_case/(error_case+correct_case);
    end