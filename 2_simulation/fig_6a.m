
clear;
clc;
close all;

%% Set Parameters for Loading Data

fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.9*3 3.3*3]);

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2','Sine1', 'Sine2'};
label_sf_list = {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'};
data_root=config(1);
key_words = 'sir2ser_fs125k';
error_path = [data_root, '2_simulation/data/', key_words,'_SF789.mat'];

data_matrix = struct2cell(load(error_path));

SIR_LoRa_map_threshold = data_matrix{1};

sf_refer_list = [4];
for ii = sf_refer_list
    error_path = [data_root, '2_simulation/data/result/', key_words,'_', label_sf_list{ii}, '.mat'];
    data_matrix = struct2cell(load(error_path));
    SIR_LoRa_map_threshold = SIR_LoRa_map_threshold + data_matrix{1};
end


figure_type = {'r^-','rx-','r+-','ro-','r*-','rp-','rh-','k^:','kx:','k+:','ko:','k*:','kp:','kh:'};
color_disk = distinguishable_colors(10);
color_disk(1, :) = color_disk(5, :);
color_disk(2, :) = color_disk(8, :);

n_legend = length(label_curving_list) * length(sf_refer_list);
legendlabels = cell(n_legend, 1);

SIR_high = 1;
SIR_low = -30;
SIR_list = [SIR_high:-1:SIR_low];
interp_space = 0.2;
SIR_list_interp = [SIR_high:-interp_space:SIR_low];

sir_2_ser=zeros(length(sf_refer_list),length(label_curving_list),length(SIR_list));


for sf_refer_index = 1:length(sf_refer_list)
    sf_refer=sf_refer_list(sf_refer_index);
    label_sf = label_sf_list{sf_refer};
    for label_curving_index = 1:2
        label_curving = label_curving_list{label_curving_index};
        
        matrix_label=(sf_refer - 1) * length(label_curving_list) + label_curving_index;
        
        ticklabels_index = (sf_refer_index - 1) * length(label_curving_list) + label_curving_index;
        
        legendlabels{ticklabels_index, 1} = [label_sf, '-', label_curving];
        
        SIR_LoRa_map_single=smooth(squeeze(SIR_LoRa_map_threshold(matrix_label,matrix_label,:)));  
        plot(SIR_list,SIR_LoRa_map_single,figure_type{ticklabels_index},'LineWidth',8,'MarkerSize',10,'Color',color_disk(label_curving_index,:));
        hold on;
    end
end
xlabel('SIR(dB)');
ylabel('Symbol Error Rate');
set(gca, 'YScale', 'log' );
legend({'Linear', 'Non-linear'},'Location','southwest','FontSize',50);
ylim([1E-3,1]);
xlim([-30,1]);
set(gcf,'WindowStyle','normal','Position', [0,0,640*2,360*2]);
saveas(gcf, [data_root,'figs/fig6a_',key_words, '.png'])

