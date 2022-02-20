clear;
clc;
close all;

%% Set Parameters for Loading Data
fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.9*3 3.3*3]);

key_words = 'sir2ser_fs125k';
data_root=config(1);
error_path = [data_root, '2_simulation/data/', key_words, '_SF789.mat'];

data_matrix = struct2cell(load(error_path));

SIR_LoRa_map_threshold = data_matrix{2};

sf_list = 10:12;

for ii = 1:length(sf_list)
    error_path = [data_root, '2_simulation/result/', key_words,'_SF', num2str(sf_list(ii)), '.mat'];
    data_matrix = struct2cell(load(error_path));
    SIR_LoRa_map_threshold = SIR_LoRa_map_threshold + data_matrix{2};
end

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2', 'Sine1', 'Sine2'};
label_sf_list = {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'};

color_disk = distinguishable_colors(10);
color_disk(1, :) = color_disk(5, :);
color_disk(2, :) = color_disk(8, :);

sf_refer_list = 1:6;
coeff_list_selected = 1:length(label_curving_list);

sir_bar = zeros(length(label_sf_list), length(coeff_list_selected));

for sf_refer_index = sf_refer_list

    for coeff_index = coeff_list_selected
        matrix_index = (sf_refer_index - 1) * length(label_curving_list) + coeff_index;
        sir_bar(sf_refer_index, coeff_index) = SIR_LoRa_map_threshold(matrix_index, matrix_index);
    end

end

sir_bar=sir_bar(:,[1,2]);
b = bar(sir_bar);

for k = 1:size(sir_bar, 2)
    b(k).FaceColor = color_disk(k, :);
end

xticklabels(label_sf_list);
xlabel('SF of Collisioned Signals');
ylabel('SIR Threshold');
legend({'Linear', 'Non-linear'}, 'Location', 'southwest', 'NumColumns', 1,'FontSize',60);
set(gcf,'WindowStyle','normal','Position', [0,0,640*2,360*2]);
saveas(gcf, [data_root,'figs/fig6b_',key_words,'.png'])
