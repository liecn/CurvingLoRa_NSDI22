function par = config(p_id)
    HOME_DIR='D:\papers/CurvingLoRa_NSDI22/'
    % LoRa PHY transmitting parameters
    LORA_BW = 125e3;        % LoRa bandwidth
    
    % Receiving device parameters
    RX_Sampl_Rate = 125e3*8;  % recerver's sampling rate 
    FFT_Samp_Factor = 50;       % down sampling factor
    
    DEBUG = false;

    N_Payload=60;
    N_Preamble_Upchirp=8;
    N_Preamble_Downchirp=2;
    
    Max_Peak_Num = 12;
    
    switch(p_id)
        case 0,
            par = DEBUG;
        case 1,
            par = HOME_DIR;
        case 2,
            par = LORA_BW;           
        case 3,
            par = RX_Sampl_Rate;
        case 4,
            par = FFT_Samp_Factor;
        case 5,
            par = N_Preamble_Upchirp;           
        case 6,
            par = N_Preamble_Downchirp;
        case 7,
            par = N_Payload;
        case 8,
            par = Max_Peak_Num;

        otherwise,
    end
end