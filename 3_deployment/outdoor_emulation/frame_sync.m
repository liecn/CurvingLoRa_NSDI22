function [outsig, t_offset,f_offset] = frame_sync(frame_sig, sf,upchirp_index)
    %
    % parameter
    %
    fs = config(3);         % sample rate        
    bw = config(2);         % LoRa bandwidth
    DEBUG = config(0);         % LoRa spreading factor
    nsamp = fs * 2^sf / bw;
    nfft = nsamp *  config(4);
    
%     frame_sig = frame_sig(round(nsamp*0.1):end);
    
    up_pre = frame_sig(upchirp_index*nsamp + (1:nsamp));
    down_pre = frame_sig(11*nsamp + (1:nsamp));
    over_rate = fs / bw;
    
    % % dechirp
    rz = chirp_dechirp_fft(up_pre, nfft,sf,[1]);
    rz = chirp_comp_alias(rz, over_rate);
    up_az = abs(rz);
    [~,peak_i] = max(up_az);
    up_freq = peak_i/nfft * fs;
    
    dcp = down_pre .* symbol_generation_by_frequency(0, sf, [1], bw, fs);
    rz = fft(dcp, nfft);
    rz = chirp_comp_alias(rz, over_rate);
    down_az = abs(rz);
    [~,peak_i] = max(down_az);
    down_freq = peak_i/nfft * fs;
    
    if DEBUG
        fprintf('[up-chirp] freq = %.2f\n[down-chirp] freq = %.2f\n', up_freq, down_freq);
        figure;
        subplot(2,2,1);
            Utils.spectrum(up_pre,sf);title('spectrum of up');
        subplot(2,2,2);
            Utils.spectrum(down_pre,sf);title('spectrum of down');
            
        f_idx = (0:nfft-1)/nfft*fs;
        subplot(2,2,3);
            plot(f_idx(1:numel(up_az)), up_az); title('FFT of up'); xlim([0 bw]);
        subplot(2,2,4);
            plot(f_idx(1:numel(down_az)), down_az); title('FFT of down'); xlim([0 bw]);
    end
    
    % % calculate CFO
    f_offset = (up_freq + down_freq) / 2;
    if abs(f_offset) > 50e3
        if f_offset < 0
            f_offset = f_offset + bw/2;
        else
            f_offset = f_offset - bw/2;
        end
    end
    
    % % calculate Time Offset
    t_offset = round((up_freq - f_offset) / bw * nsamp);
    if t_offset > nsamp/2
        t_offset = t_offset - nsamp;
    end
    
    sig_st = t_offset;
    if sig_st < 0
        frame_sig = frame_sig(-sig_st:end);
%         frame_sig = [zeros(1, -sig_st), frame_sig];
        sig_st = 0;
    end
    
    outsig = frame_sig(sig_st+1:end);
    
%     figure;
%         plot(real(frame_sig));
%         hold on
%         plot(sig_st+1:length(frame_sig), real(outsig));
end