clear;
close all;

%% Set Parameters for Loading Data
lineA = ["-", ":", "--", '-.'];
lineC = ["*", "s", "o", "^", "+", "p", "d"];
lineS = ["-*", "--s", ":^", '-.p'];

fig = figure;
set(fig, 'DefaultAxesFontSize', 40);
set(fig, 'DefaultAxesFontWeight', 'bold');
set(fig, 'PaperSize', [6.8 4]);

data_root=config(1);
data_dir = [data_root,'3_deployment/result/symbol_emulation/'];
key_words = 'basic_code2ser_';

figure_type = {'b^-','bx-','b+-','bo-','b*-','bp-','bh-','m^--','mx--','m+--','mo--','m*--','mp--','mh--','k^:','kx:','k+:','ko:','k*:','kp:','kh:'};
label_curving_list = {'Linear', 'Quadratic1', 'Quadratic2', 'Quartic1', 'Quartic2'};

SF = [7,9,11];

for sf_index = 1:length(SF)
    sf = SF(sf_index);
    error_path = [data_dir,key_words, num2str(sf), '.mat'];
    data_matrix = struct2cell(load(error_path));
    SER = data_matrix{1};

    for coeff_index=1:length(label_curving_list)
        plot_data=(squeeze(SER(coeff_index,:)));
        h=cdfplot(plot_data);
        length(plot_data)
        maker_idx=1:5:80;
        h.LineWidth=2;
        h.MarkerSize=10;
        h.MarkerIndices=maker_idx;
        h.Marker=lineC(coeff_index);
        hold on;
    end

end
xt = [0.06 0.22 0.38];
yt = [0.8 0.8 0.8];
str = {'SF=11','SF=9','SF=7'};
text(xt-0.02,yt-0.3,str,'FontSize',40,'FontWeight', 'bold')

xlabel('Symbol Error Rate for Various Codes');
ylabel('CDF');
title('');
legend(label_curving_list, 'Location', 'southeast','NumColumns',1,'FontSize',35);
set(gcf, 'WindowStyle', 'normal', 'Position', [0, 0, 640*2, 480*2]);
saveas(gcf, [data_root,'figs/fig_16b.png'])