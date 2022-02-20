function symbols = symb_detect(sig, SF,preamble_peak_threshold)
% LoRa modulation & sampling parameters
Fs = config(3); % sample rate
BW = config(2); % LoRa bandwidth
nsamp = Fs * 2^SF / BW;
nfft = nsamp * config(4);
MAX_PK_NUM = config(8); % maximum number of peaks

% detect in-window distributions for signal in each window
symbols = [];

% iteratively extract the highest peak

for loop = 1:MAX_PK_NUM
    % dechirpring and fft
    station_fout = chirp_dechirp_fft(sig, nfft, SF, [1]);
    
    % applying non-stationary scaling down-chirp
    amp_lower_bound = 1;
    amp_upper_bound = 1.2;
    scal_func = linspace(amp_lower_bound, amp_upper_bound, nsamp);
    non_station_fout = chirp_dechirp_fft(sig .* scal_func, nfft, SF, [1]);
    
    
    %% iterative compensate phase rotation (taking the advantage of over sampleing)
    [non_scal_targ,pk_phase] = chirp_comp_alias(station_fout, Fs/BW);
    %     plot(abs(non_scal_targ));
    [pk_height, pk_index] = max(abs(non_scal_targ));
    
    % pk_height = -1;
    % pk_index = 0;
    % pk_phase = 0;
    
    align_win_len = length(station_fout) / (Fs / BW);
    
    % for pending_phase = (0:19) / 20 * 2 * pi
    %     non_scal_targ = exp(1i * pending_phase) * station_fout(1:align_win_len) + station_fout(end - align_win_len + 1:end);
    
    %     if max(abs(non_scal_targ)) > pk_height
    %         [pk_height, pk_index] = max(abs(non_scal_targ));
    %         pk_phase = pending_phase;
    %     end
    
    % end
    
    % threshold for peak detecting
    if loop == 1
        if pk_height<8
            break;
        end
        threshold = pk_height / preamble_peak_threshold;
    else
        
        if pk_height < threshold
            break;
        end
        
    end
    
    % Determine whether the peak is legitimate (whether it is duplicated)
    repeat = false;
    %         [ma, I] = max(abs(targ));
    %         cbin = (1 - pk_index / align_win_len) * 2^SF;
    fidx = (0:align_win_len-1) /align_win_len * 2^SF;
    cbin=fidx(pk_index);
    
    for s = symbols
        
        if abs(s.bin - cbin) < 2
            repeat = true;
            break;
        end
        
    end
    
    if repeat
        break;
    end
    
    % Scaling factor of peaks: alpha
    non_scal_targ = non_station_fout(1:align_win_len) + non_station_fout(end - align_win_len + 1:end)*exp(1i * pk_phase);
    alpha = abs(non_scal_targ(pk_index)) / pk_height;
    
    % abnormal alpha
    if alpha < amp_lower_bound || alpha > amp_upper_bound
        return;
    end
    
    % According to the scaling factor, reconstruct signal segment
    freq = (0:align_win_len - 1) * BW / align_win_len;
    
    if alpha < (amp_lower_bound + amp_upper_bound) / 2 % near previous window
        seg_len = (alpha - amp_lower_bound) * 2 / (amp_upper_bound - amp_lower_bound) * nsamp;
        amp = pk_height / seg_len;
        [dout, sym] = symb_refine(true, seg_len, amp, freq(pk_index), sig,SF);
    else % near following window
        seg_len = (amp_upper_bound - alpha) * 2 / (amp_upper_bound - amp_lower_bound) * nsamp;
        amp = pk_height / seg_len;
        [dout, sym] = symb_refine(false, seg_len, amp, freq(pk_index), sig,SF);
    end
    
    symbols = [symbols, sym];
    sig = dout;
end

end
