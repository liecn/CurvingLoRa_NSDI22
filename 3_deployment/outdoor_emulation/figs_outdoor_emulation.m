clear;
clc;
close all;

%% Set Parameters for Loading Data

fig = figure;
fig = figure;
set(fig,'DefaultAxesFontSize',50);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[7*3 3.3*3]);

label_curving_list = {'LoRaWAN','Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2'};
sf_selected_list = [4];

sf_list = 7:12;

color_disk = distinguishable_colors(15);
color_disk(4, :) = color_disk(3, :);
color_disk(2, :) = color_disk(6, :);
color_disk(1, :) = color_disk(5, :);
color_disk(3, :) = color_disk(8, :);
color_disk(5, :) = color_disk(9, :);

for sf_index = sf_selected_list
    sf = sf_list(sf_index);
    
    key_words = ['outdoor_'];
    error_path = [config(1), '3_deployment/result/outdoor/', key_words, num2str(sf), '.mat'];
    data_matrix = struct2cell(load(error_path))
    ser_curving = data_matrix{1};
    ser_count_curving  = data_matrix{2};
    res=zeros(size(ser_curving));

    for aa = 1:size(ser_curving, 1)
        for ii = 1:size(ser_curving, 2)
            for jj = 2:size(ser_curving, 3)
                a = squeeze(ser_curving{aa, ii, jj});
                b = squeeze(ser_count_curving{aa, ii, jj});
                res(aa, ii, jj) = sum(a) / (jj*mean(b));
            end
        end
    end

    res = nanmean(res(:, :, 2:end), 2);

    plot_data = 1 - squeeze(res)';

    b = bar(2:12, plot_data);

    for k = 1:size(plot_data, 2)
        b(k).FaceColor = color_disk(k, :);
    end

    xlabel('Concurrency');
    ylabel('Symbol Error Rate');
        ylim([0, 1]);
    legend(label_curving_list, 'Position', [0.56 0.9 0. 0.], 'NumColumns', 4, 'FontSize', 40);
    set(gcf,'WindowStyle','normal','Position', [0,0,800*2,360*2]);
    saveas(gcf, [config(1), 'figs/', 'fig_outdoor_emulation_', num2str(sf_list(sf_index)), '.png']);

end
