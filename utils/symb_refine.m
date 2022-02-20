function [dout,sym] = symb_refine(near_prev,seg_length, seg_ampl, peak_freq, org_sig,SF)
    % Reconstruct a chirp of the same frequency

    % LoRa modulation & sampling parameters
    Fs = config(3);         % sample rate        
    BW = config(2);         % LoRa bandwidth
    nsamp = Fs * 2^SF / BW;
    
    min_residual = Inf;
    dout = org_sig;

    % iteratively searching initial phase
    rphase_1 = 0;
    rphase_2 = 0;
    for pending_phase = (0:19)/20*2*pi
%         sig = seg_ampl * symb_gen_phase(2^SF * (1 - peak_freq/BW),pending_phase,rphase_2,SF);
        sig = seg_ampl * symbol_generation_by_phase(2^SF * ( peak_freq/BW), SF,[1], BW, Fs,pending_phase,rphase_2);
        if near_prev
            sig(round(seg_length+1):end) = 0;
        else
            sig(1:round(end-seg_length)) = 0;
        end
        e_residual = sum((abs(org_sig - sig)).^2);
        if e_residual < min_residual
            rphase_1 = pending_phase;
            min_residual = e_residual;
            dout = org_sig - sig;
        end
    end

    for pending_phase = (0:19)/20*2*pi
%         sig = seg_ampl * symb_gen_phase(2^SF * (1 - peak_freq/BW),rphase_1,pending_phase,SF);
        sig = seg_ampl * symbol_generation_by_phase(2^SF * ( peak_freq/BW), SF,[1], BW, Fs,rphase_1,pending_phase);
        
        if near_prev
            sig(round(seg_length+1):end) = 0;
        else
            sig(1:round(end-seg_length)) = 0;
        end
        e_residual = sum((abs(org_sig - sig)).^2);
        if e_residual < min_residual
            rphase_2 = pending_phase;
            min_residual = e_residual;
            dout = org_sig - sig;
        end
    end

    % searching other paprameters
    r_freq = peak_freq;
    r_ampl = seg_ampl;
    r_length = seg_length;

%     % alternate search frequency and phase
%     % ENABLED when under extremely low SNR
%     for i = peak_freq + BW/(2^SF) * (-5 : 0.1 : 5)
%         if i < 0 || i > BW
%             continue;
%         end
%         sig = seg_ampl * symb_gen_phase(2^SF * (1 - i/BW),rphase_1,rphase_2,SF);
%         if near_prev
%             sig(round(seg_length+1):end) = 0;
%         else
%             sig(1:round(end-seg_length)) = 0;
%         end
%         e_residual = sum((abs(org_sig - sig)).^2);
%         if e_residual < min_residual
%             r_freq = i;
%             min_residual = e_residual;
%             dout = org_sig - sig;
%         end
%     end
% 
%     for pending_phase = (0:19)/20*2*pi
%         sig = seg_ampl * symb_gen_phase(2^SF * (1 - r_freq/BW),pending_phase,rphase_2,SF);
%         if near_prev
%             sig(round(seg_length+1):end) = 0;
%         else
%             sig(1:round(end-seg_length)) = 0;
%         end
%         e_residual = sum(abs(org_sig - sig));
%         if e_residual < min_residual
%             rphase_1 = pending_phase;
%             min_residual = e_residual;
%             dout = org_sig - sig;
%         end
%     end
% 
%     for pending_phase = (0:19)/20*2*pi
%         sig = seg_ampl * symb_gen_phase(2^SF * (1 - r_freq/BW),rphase_1,pending_phase,SF);
%         if near_prev
%             sig(round(seg_length+1):end) = 0;
%         else
%             sig(1:round(end-seg_length)) = 0;
%         end
%         e_residual = sum(abs(org_sig - sig));
%         if e_residual < min_residual
%             rphase_2 = pending_phase;
%             min_residual = e_residual;
%             dout = org_sig - sig;
%         end
%     end
% 
%     for i = peak_freq + BW/(2^SF) * (-0.5 : 0.02 : 0.5)
%         if i < 0 || i > BW
%             continue;
%         end
%         sig = seg_ampl * symb_gen_phase(2^SF * (1 - i/BW),rphase_1,rphase_2,SF);
%         if near_prev
%             sig(round(seg_length+1):end) = 0;
%         else
%             sig(1:round(end-seg_length)) = 0;
%         end
%         e_residual = sum(abs(org_sig - sig));
%         if e_residual < min_residual
%             r_freq = i;
%             min_residual = e_residual;
%             dout = org_sig - sig;
%         end
%     end

    for i = seg_ampl * (0.9:0.01:1.1)
%         sig = i * symb_gen_phase(2^SF * (1 - r_freq/BW),rphase_1,rphase_2,SF);
        sig = i * symbol_generation_by_phase(2^SF * (r_freq/BW), SF,[1], BW, Fs,rphase_1,rphase_2);
        
        if near_prev
            sig(round(seg_length+1):end) = 0;
        else
            sig(1:round(end-seg_length)) = 0;
        end
        e_residual = sum(abs(org_sig - sig));
        if e_residual < min_residual
            r_ampl = i;
            min_residual = e_residual;
            dout = org_sig - sig;
        end
    end

    for i = seg_length - 50 : 5 : seg_length + 50
        if i < 0 || i > nsamp
            continue;
        end
%         sig = r_ampl * symb_gen_phase(2^SF * (1 - r_freq/BW),rphase_1,rphase_2,SF);
        sig = r_ampl * symbol_generation_by_phase(2^SF * (r_freq/BW), SF,[1], BW, Fs,rphase_1,rphase_2);
        
        if near_prev
            sig(round(i+1):end) = 0;
        else
            sig(1:round(end-i)) = 0;
        end
        e_residual = sum(abs(org_sig - sig));
        if e_residual < min_residual
            min_residual = e_residual;
            dout = org_sig - sig;
            r_length = i;
        end
    end

    sym = csymbol(near_prev, r_freq, r_ampl, r_length,SF);
end