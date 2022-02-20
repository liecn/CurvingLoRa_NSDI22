clear;
clc;
sf1_selected_list = [1:2:6]; %[1:3],4,5,6
%%
start_phase=-pi/2;
end_phase=pi/2;
x = linspace(start_phase,end_phase,100);
y = 0.5*(sin(x)-sin(start_phase));
p_1 = polyfit(x,y,5);

start_phase=-3*pi/8;
end_phase=3*pi/8;
x = linspace(start_phase,end_phase,100);
y = 0.5*(sin(x)-sin(start_phase));
p_2 = polyfit(x,y,5);

sf_list = [7, 8, 9, 10, 11, 12];
CurvingLoRa = {[1], [1, 0], [-1, 2], [1, 0, 0, 0], [-1, 4, -6, 4],p_1(1:end-1),p_2(1:end-1)}; 
bw = config(2);
fs = 125000;
fft_scaling = config(4);
SIR_high = 1;
SIR_low = -30;
SIR_list = [SIR_high:-1:SIR_low];
interp_space = 0.2;
SIR_list_interp = [SIR_high:-interp_space:SIR_low];

simu_iters = 10000;
data_root = [config(1), '2_simulation/result/'];
key_words = 'sir2ser_fs125k_SF';

% LoRa_SIR_map
SIR_LoRa_map = zeros(length(sf_list) * length(CurvingLoRa), length(sf_list) * length(CurvingLoRa), length(SIR_list));
SIR_LoRa_map_threshold = zeros(length(sf_list) * length(CurvingLoRa));

for sf1_index = sf1_selected_list
    sf1 = sf_list(sf1_index);

    for chirp1_index = 1:length(CurvingLoRa)
        chirp1 = CurvingLoRa{chirp1_index};
        x_index = (sf1_index - 1) * length(CurvingLoRa) + chirp1_index;

        for sf2_index = 1:length(sf_list)
            sf2 = sf_list(sf2_index);
            for chirp2_index = chirp1_index
                chirp2 = CurvingLoRa{chirp2_index};
                y_index = (sf2_index - 1) * length(CurvingLoRa) + chirp2_index;
                fprintf('sf1=%d,sf2=%d\n', sf1, sf2);
                fprintf('x=%d,y=%d\n', x_index, y_index);
                SIR_LoRa_map_single = SIRbetweenChirps(sf1, chirp1, sf2, chirp2, bw, fs, SIR_list, simu_iters, fft_scaling);

                SIR_LoRa_map_single_interp = interp1(SIR_list, SIR_LoRa_map_single, SIR_list_interp, 'spline');

                SIR_LoRa_map_threshold(x_index, y_index) = SIR_high - find((SIR_LoRa_map_single_interp) > 0.01, 1, 'first') * interp_space;

                SIR_LoRa_map(x_index, y_index, :) = SIR_LoRa_map_single;
            end
        end
    end
    save([data_root, key_words, num2str(sf1), '.mat'], 'SIR_LoRa_map', 'SIR_LoRa_map_threshold', 'SIR_list');
end
