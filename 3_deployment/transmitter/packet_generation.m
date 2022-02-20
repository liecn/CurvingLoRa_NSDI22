function [data,data_frequency] = packet_generation(n_payload,sf,coefficient,bw,fs)
% CurvingLoRa Packet Compositions
[preamble,SFD] = preamble_generation(sf,coefficient,bw,fs);
%% Split n_payload into Chirps.
% In CurvingLoRa prototype design, payload length is equal to integral multiples of SF
payload_chirps = [];
data_frequency=zeros(1,n_payload);
for ii = 1:n_payload % if n is a float number, the decimal part will be omitted.
    data_frequency_per=randi([0,2^sf-1],1);
%     if coefficient==1
%         payload_chirps = [payload_chirps, utils.gen_symbol(data_frequency_per,false,fs,bw,sf)];
%     else
        payload_chirps = [payload_chirps, symbol_generation_by_frequency(data_frequency_per,sf,coefficient,bw,fs)];
%     end
    data_frequency(ii)=data_frequency_per;
end
payload_chirps=[payload_chirps,zeros(1,2^sf*fs/bw)];
%% Concatenate parts into one output
y = [zeros(1,2^sf*fs/bw),preamble,SFD,payload_chirps];
data = [real(y);imag(y)];
end