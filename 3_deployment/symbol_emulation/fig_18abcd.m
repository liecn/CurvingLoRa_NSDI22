clear;
clc;
close all;

%% Set Parameters for Loading Data
fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.9*3 3.3*3]);

key_words = 'basic_sir2ser_symbol';

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2'};
label_sf_list = {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'};

color_disk = distinguishable_colors(10);
color_disk(4, :) = color_disk(3, :);
color_disk(2, :) = color_disk(6, :);
color_disk(1, :) = color_disk(5, :);
color_disk(3, :) = color_disk(8, :);
color_disk(5, :) = color_disk(9, :);

figure_type = {'^-','p-','s-','o-','+-','x-','h-','^--','p--','s--','o--','+--','x--','h--','^:','p:','s:','o:','+:','x:','h:'};

data_root=config(1);
data_dir = [data_root,'3_deployment/result/symbol_emulation/'];

%% sir line
sf_list=7:12;
sf_selected_list=[2,4,6];

ser=zeros(6,5,32,5);

for sf_index = sf_selected_list
    sf=sf_list(sf_index);
    error_path = [data_dir, 'basic_sir2ser_symbol_',num2str(sf),'.mat'];
    data_matrix = struct2cell(load(error_path));
    ser(sf_index,:,:,:) = data_matrix{1};
    sir=data_matrix{2};
    for coeff_index = 1:length(label_curving_list)
        data_list_raw=squeeze(mean(ser(sf_index,coeff_index,:,:),[4]))';
        plot(sir, smooth(data_list_raw),figure_type{coeff_index}, 'LineWidth', 6, 'MarkerSize', 15,'MarkerFaceColor',color_disk(coeff_index,:));
        hold on;
    end
    plot(sir, ones(length(sir),1)*0.01,'k--', 'LineWidth', 6);
    set(gca, 'YScale', 'log');
    xlabel('SIR(dB)');
    ylabel('Symbol Error Rate');
    if sf_index==1
        legend(label_curving_list, 'Location', 'southwest', 'NumColumns',1,'FontSize',40);
    end
     ylim([1E-3, 1]);
     set(gcf,'WindowStyle','normal','Position', [0,0,640*2,360*2]);
    saveas(gcf, [data_root, 'figs/fig_18_',label_sf_list{sf_index}, '.png'])
    clf
end

offset_list = {'10%', '20%', '30%', '40%', '50%'};

sir2ser_threshold = squeeze(mean(ser(sf_selected_list, :, 1:12, :), [1, 3]));
sir2ser_threshold = sir2ser_threshold';
b = bar(sir2ser_threshold);

for k = 1:size(sir2ser_threshold, 2)
    b(k).FaceColor = color_disk(k, :);
end

% end
xticklabels(offset_list);
set(gca, 'YScale', 'log');
ylim([1e-4 9]);
yticks([1e-4 1e-2 1e0])
xlabel('Offsets (% of symbol duration)');
ylabel('Symbol Error Rate');
legend(label_curving_list, 'Position', [0.58 0.88 0 0], 'NumColumns', 3, 'FontSize', 40);
set(gcf, 'WindowStyle', 'normal', 'Position', [0, 0, 640 * 2, 360 * 2]);
saveas(gcf, [data_root, 'figs/fig_18d.png'])