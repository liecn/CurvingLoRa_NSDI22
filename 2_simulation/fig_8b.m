
clear;
clc;
close all;

%% Set Parameters for Loading Data
lineA = ["-", ":", "--", '-.'];
lineC = ["*", "s", "o", "^", "+", "p", "d"];
lineS = ["-*", "--s", ":^", '-.p'];

fig = figure;
set(fig, 'DefaultAxesFontSize', 20);
set(fig, 'DefaultAxesFontWeight', 'bold');
set(fig, 'PaperSize', [6.8 4]);

data_root=config(1);
key_words = 'code2ser_fs125k';

figure_type = {'b^-','bx-','b+-','bo-','b*-','bp-','bh-','m^--','mx--','m+--','mo--','m*--','mp--','mh--','k^:','kx:','k+:','ko:','k*:','kp:','kh:'};

label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2','Sine1', 'Sine2'};


SF = [7,9,11];

for sf_index = 1:length(SF)
    sf = SF(sf_index);
    error_path = [data_root, '2_simulation/result/', key_words,'_SF', num2str(sf), '.mat'];
    data_matrix = struct2cell(load(error_path));
    SER = data_matrix{1};

    maker_idx=1:5:40;
    for coeff_index=1:length(label_curving_list)
        size(SER(coeff_index,:))
        h=cdfplot(SER(coeff_index,:));
        h.LineWidth=2;
        h.MarkerSize=10;
        h.MarkerIndices=maker_idx;
        h.Marker=lineC(coeff_index);
        hold on;
    end

end
xt = [0.13 0.31 0.46];
yt = [0.8 0.8 0.8];
str = {'SF=11','SF=9','SF=7'};
text(xt+0.08,yt-0.6,str,'FontSize',25,'FontWeight', 'bold')

xlabel('Symbol Error Rate for Various Codes');
ylabel('CDF');
title('');
legend(label_curving_list, 'Location', 'east','NumColumns',3,'FontSize',18);
set(gcf, 'WindowStyle', 'normal', 'Position', [0, 0, 640, 480]);
saveas(gcf, [data_root, 'figs/fig8b_',key_words, '.png'])
