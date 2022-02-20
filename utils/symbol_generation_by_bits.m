function [y] = symbol_generation_by_bits(data, coefficient_vector, BW, sample_rate)
%%% CurvingLoRa data symbol module

% 1111111   CurvingLoRa_symbol('1111111',1,125e3,125e3)
% f(x) = a1x1 + a2x2  + anxn  LoRa  : [1] => f(x) = x => in the rectangle with a width of BW and a length of 2^SF/BW 
% BW = sample_rate = 125kHz 
% output: complex sequence  exp{-1i*2*pi*f*t}

%% Initialization
% input a binary data whose length is between 7 and 12.
SF = length(data);
end_t = (2^SF)/BW;
symbol = bin2dec(data);
init_frequecy = symbol / end_t ;

%% Coefficient Processing
% To transform the coefficient vector into the real spectrum
total = sum(coefficient_vector);
% normalization
coefficient_vector = coefficient_vector / total; 
% degree of polynomial function
degree = length(coefficient_vector); 
divisors = end_t.^(degree + 1 - (1:degree));
coefficient_vector = BW * coefficient_vector ./  divisors;
coeff = [coefficient_vector, - BW/2];  

%% From Phase to Signals
t = 0:1/sample_rate:end_t;
y = exp(1i * (2*pi * polyval( polyint(coeff), t) ) ) .* exp(1i * 2*pi * init_frequecy * t);
y = y(1:end-1);
end