clear;
clc;
close all;

%% Set Parameters for Loading Data
fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.9*3 3.3*3]);

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

sf_list=7:12;
sf_selected_list = 2:2:6;
ser=zeros(6,5,13,5);

%% snr
for sf_index=sf_selected_list
    sf=sf_list(sf_index);
    error_path = [data_dir, 'basic_snr2ser_symbol_',num2str(sf),'.mat'];
    data_matrix = struct2cell(load(error_path));
    ser(sf_index,:,:,:)=data_matrix{1};
    snr=data_matrix{2};
    ser_threshold=squeeze(mean(ser(sf_index,:,:,:),[4]))';
    ser_threshold(ser_threshold==0)=1e-4;
    for jj = 1:size(ser_threshold,2)
        plot(smooth(ser_threshold(:,jj)), figure_type{jj}, 'LineWidth', 8, 'MarkerSize', 15,'MarkerFaceColor',color_disk(jj,:));
        hold on;
    end
    xlim([1.5 12.5]);
    xticks(2:2:14)
    xticklabels(min(snr)+5:10:max(snr));
    ylim([0 1]);
    set(gca, 'YScale', 'log');
    xlabel('SNR(dB)');
    ylabel('Symbol Error Rate');
    if(sf_index==2)
    legend(label_curving_list, 'Location', 'southwest', 'NumColumns',1,'FontSize',40);
    xlim([1 12.5]);
    end
    set(gcf,'WindowStyle','normal','Position', [0,0,640*2,360*2]);
    saveas(gcf, [data_root,'figs/fig_17_',label_sf_list{sf_index}, '.png'])
    clf;
end

%% offset

offset_list = {'10%', '20%', '30%', '40%', '50%'};
plot_data_raw=squeeze(mean(ser(sf_selected_list,:,4:10,:),[1,3]));

ser_threshold=plot_data_raw';


b=bar(ser_threshold);
for k = 1:size(ser_threshold,2)
    b(k).FaceColor = color_disk(k,:);
end

xticklabels(offset_list);
set(gca, 'YScale', 'log');
xlabel('Offsets (% of symbol duration)');
ylabel('Symbol Error Rate');
legend(label_curving_list, 'Position', [0.68 0.8 0. 0.],'NumColumns',2,'FontSize',40);

set(gcf,'WindowStyle','normal','Position', [0,0,640*2,360*2]);
saveas(gcf, [data_root,'figs/fig_17d.png'])
