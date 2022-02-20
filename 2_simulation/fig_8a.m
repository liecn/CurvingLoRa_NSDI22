clear;
clc;
close all;

%% Set Parameters for Loading Data
lineA=["-",":","--",'-.'];
lineC=["*","s","o","^","+","p","d"];
lineS=["-*","--s",":^",'-.p'];

fig = figure;
set(fig,'DefaultAxesFontSize',40);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[5.9*3 4.4*3]);


key_words='snr2ser_fs125k';
data_root=config(1);
error_path = [data_root,'2_simulation/result/',key_words,'.mat'];

data_matrix = struct2cell(load(error_path));

figure_type = {'^-','x-','+-','o-','*-','p-','h-','^--','x--','+--','o--','*--','p--','h--','^:','x:','+:','o:','*:','p:','h:'};
SNR=data_matrix{2};
SER=data_matrix{1};

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2','Sine1','Sine2'};
label_sf_list = {'SF7', 'SF9', 'SF11'};
color_disk = distinguishable_colors(10);
color_disk(2, :) = color_disk(6, :);
color_disk(1, :) = color_disk(5, :);
color_disk(3, :) = color_disk(8, :);

for i=1:size(SER,1)
    plot(SNR,SER(i,:),figure_type{i},'LineWidth',6,'MarkerSize',15,'Color',color_disk(ceil(i/length(label_curving_list)),:));
    hold on;
end


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

xt = [-27 -18 -10];
yt = [0.1 0.1 0.1];
str = {'SF=11','SF=9','SF=7'};
text(xt,yt,str,'FontSize',50,'FontWeight', 'bold')

xlabel('SNR(dB)');
ylabel('Symbol Error Rate');
set(gca, 'YScale', 'log' );
legend(label_curving_list,'Location','southwest','NumColumns',1,'FontSize',30);
ylim([1E-4,1]);
xlim([-35,-5]);
set(gcf,'WindowStyle','normal','Position', [0,0,640*2,480*2]);
saveas(gcf,[data_root,'figs/fig8a_',key_words,'.png'])

