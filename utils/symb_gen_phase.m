function sig = symb_gen_phase(k, phase1, phase2,SF, is_down)
    %LORASYMBOL generate lora symbol
       
    % LoRa modulation & sampling parameters
    Fs = config(3);         % sample rate        
    BW = config(2);         % LoRa bandwidth
    % SF = param_configs(1);         % LoRa spreading factor
    nsamp = Fs * 2^SF / BW;
    tsamp = (0:nsamp-1)/Fs;
    
    if nargin < 5 || isempty(is_down) || is_down == 0
        f0 = -BW/2; % start freq
        f1 = BW/2;  % end freq
    else
        f0 = BW/2;  % start freq
        f1 = -BW/2; % end freq
    end    
    chirpI = chirp(tsamp, f0, nsamp/Fs, f1, 'linear', 90);
    chirpQ = chirp(tsamp, f0, nsamp/Fs, f1, 'linear', 0);
    baseline = complex(chirpI, chirpQ);
    baseline = [baseline.*exp(1i*phase1), baseline.*exp(1i*phase2)];
    clear chirpI chirpQ

    offset = round((2^SF - k) / 2^SF * nsamp);
    sig = baseline(offset+(1:nsamp));
end