clear;
clc;
close all;

%% Set Parameters for Loading Data

fig = figure;
set(fig, 'DefaultAxesFontSize', 18);
% set(fig, 'DefaultAxesFontWeight', 'bold');
set(fig, 'PaperSize', [6.8 4]);

key_words = 'sir2map_fs125k';
data_root=config(1);
error_path = [data_root, '2_simulation/data/', key_words,'_SF789.mat'];

data_matrix = struct2cell(load(error_path));

SIR_LoRa_map_threshold = data_matrix{3};


sf_list = 10:12;

for ii = 1:length(sf_list)
    error_path = [data_root, '2_simulation/result/', key_words, '_SF',num2str(sf_list(ii)),'.mat'];
    data_matrix = struct2cell(load(error_path));
    SIR_LoRa_map_threshold = SIR_LoRa_map_threshold+data_matrix{3};
end

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2'};
label_sf_list = {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'};
n_axis = length(label_curving_list) * length(label_sf_list);
ticklabels = cell(n_axis, 1);

for label_sf_index = 1:length(label_sf_list)
    label_sf = label_sf_list{label_sf_index};

    for label_curving_index = 1:length(label_curving_list)
        label_curving = label_curving_list{label_curving_index};
        ticklabels_index = (label_sf_index - 1) * length(label_curving_list) + label_curving_index;
        ticklabels{ticklabels_index, 1} = [label_sf, '-', label_curving];
    end

end

colormap(jet);
imagesc(SIR_LoRa_map_threshold');
xlim([0.5, size(SIR_LoRa_map_threshold, 2) + 0.5]); ylim([0.5, size(SIR_LoRa_map_threshold, 1) + 0.5]);
colorbar; %Use colorbar only if necessary

line_x = [0.5:length(label_curving_list):n_axis + 0.5];
line_y = [0.5:length(label_curving_list):n_axis + 0.5];

for i = 1:length(line_y)
    hold on;
    plot3(line_x, length(label_curving_list) * (i - 1) * ones(length(line_x), 1) + 0.5, ones(length(line_x), 1), "k", 'LineWidth', 3);
end

for i = 1:length(line_x)
    hold on;
    plot3(length(label_curving_list) * (i - 1) * ones(length(line_y), 1) + 0.5, line_y, ones(length(line_y), 1), "k", 'LineWidth', 3);
end

set(gca, 'Xtick', 1:1:n_axis);
set(gca, 'Ytick', 1:1:n_axis);
xticklabels(ticklabels);
yticklabels(ticklabels);
xtickangle(45);
% grid on
set(gcf, 'WindowStyle', 'normal', 'Position', [0, 0, 640 * 2, 480 * 2]);
saveas(gcf, [data_root,'figs/',key_words, '.png'])
