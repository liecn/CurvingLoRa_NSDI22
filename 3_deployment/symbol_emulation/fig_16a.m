% MAIN
% Version 30-Nov-2019
% Help on http://liecn.github.com
clear;
% clc;
close all;

%% Set Parameters for Loading Data
lineA = ["-", ":", "--", '-.'];
lineC = ["*", "s", "o", "^", "+", "p", "d"];
lineS = ["-*", "--s", ":^", '-.p'];

fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.9*3 4.4*3]);

data_root=config(1);
data_dir = [data_root,'3_deployment/result/symbol_emulation/'];
key_words = 'basic_snr2ser_SF7911';
error_path = [data_dir, key_words, '.mat'];

sf_selected_list = [1,3,5];
% sf_selected_list = [2,4,6];
data_matrix = struct2cell(load(error_path))

figure_type = {'^-', 'x-', '+-', 'o-', '*-', '^--', 'x--', '+--', 'o--', '*--',  '^:', 'x:', '+:', 'o:', '*:'};
SNR = data_matrix{2};
SER = data_matrix{1};

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2'};
label_sf_list = {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'};
color_disk = distinguishable_colors(10);
color_disk(2, :) = color_disk(6, :);
color_disk(1, :) = color_disk(5, :);
color_disk(3, :) = color_disk(8, :);


for ii = sf_selected_list

    for jj = 1:length(label_curving_list)
        label_index=(floor((ii+1)/2)-1)*length(label_curving_list)+jj;
        plot(SNR, smooth(squeeze(SER(ii,jj, :))), figure_type{label_index}, 'LineWidth', 4, 'MarkerSize', 15, 'Color', color_disk(floor((ii+1)/2), :));
        hold on;
    end

end

n_axis = length(label_curving_list) * length(sf_selected_list);
ticklabels = cell(n_axis, 1);

for label_sf_index = 1:length(sf_selected_list)
    sf_selected=sf_selected_list(label_sf_index);
    label_sf = label_sf_list{sf_selected};
    for label_curving_index = 1:length(label_curving_list)
        label_curving = label_curving_list{label_curving_index};
        ticklabels_index = (label_sf_index - 1) * length(label_curving_list) + label_curving_index;
        ticklabels{ticklabels_index, 1} = [label_sf, '-', label_curving];
    end

end
xt = [-30 -22 -15];
yt = [0.04 0.04 0.04];
str = {'SF=11','SF=9','SF=7'};
text(xt,yt,str,'FontSize',60,'FontWeight', 'bold')

xlabel('SNR(dB)');
ylabel('Symbol Error Rate');
set(gca, 'YScale', 'log');
legend(label_curving_list, 'Position', [0.56 0.3 0. 0.], 'NumColumns', 3, 'FontSize', 40);
% grid on
ylim([1E-5, 1]);
% set(gca,'Ytick',0:0.2:1)
set(gcf,'WindowStyle','normal','Position', [0,0,640*2,480*2]);
saveas(gcf, [data_root,'figs/fig_16a.png'])