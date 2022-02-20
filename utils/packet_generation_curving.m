function [output] = packet_generation_curving(Payload,sf,coefficient_matrix,bw,fs)
% CurvingLoRa Packet Compositions
[preamble,SFD] = preamble_generation_curving(sf,coefficient_matrix,bw,fs);
%% Split Payload into Chirps. 
% In CurvingLoRa prototype design, payload length is equal to integral multiples of SF
len = length(Payload);
n_payload = len / sf;
payload_chirps = [];
for i = 1:n_payload % if n is a float number, the decimal part will be omitted.
    payload_chirps = [payload_chirps, symbol_generation_by_bits(Payload((i-1)*sf+1:i*sf),coefficient_matrix,bw,fs)];
end

%% Concatenate parts into one output
y = [preamble,SFD,payload_chirps];
output = [real(y);imag(y)];
end