function list_filtered = list_filter(list_selected, sf_selected, coeff_index_selected)
    list_filtered=[];
    for feature_data_index = 1:size(list_selected, 1)
        feature_data_name = list_selected(feature_data_index).name;

        if strcmp(feature_data_name, '.') == 1 || strcmp(feature_data_name, '..') == 1
            continue;
        end

        raw_data_name_components = strsplit(feature_data_name, '_');
        % file_name = [num2str(sf), '_', num2str(coeff_index), '_', num2str(packet),'_', num2str(symbol), '_', num2str(value), '_', num2str(true_code)];

        sf = str2num(raw_data_name_components{1});
        coeff_index = str2num(raw_data_name_components{2});
        symbol_index = str2num(raw_data_name_components{4});
        estimated_code = str2num(raw_data_name_components{5});
        true_code = str2num(raw_data_name_components{6});

        if sf~=sf_selected || coeff_index~=coeff_index_selected || mod(round(estimated_code), 2^sf) ~= true_code || symbol_index < 10
            continue;
        end

        list_filtered=[list_filtered,list_selected(feature_data_index)];

    end

end
