function freq_pwr = symb_freq_alias(datain)
    %
    % parameter
    %
    Fs = config(3);         % sample rate        
    BW = config(2);         % LoRa bandwidth

    nfft = numel(datain);
    target_nfft = round(BW/Fs*nfft);
    
    freq_pwr = abs(datain(1:target_nfft)) + abs(datain(end-target_nfft+1:end));
end