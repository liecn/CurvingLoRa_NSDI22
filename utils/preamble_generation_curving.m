function [preamble, SFD] = preamble_generation_curving(sf, coefficient_matrix, bw, fs)
    % CurvingLoRa Packet Compositions

    %% Preamble * 6
    baseline_bin = repmat('0', 1, sf);
    upchirp = symbol_generation_by_bits(baseline_bin, coefficient_matrix, bw, fs);
    preamble = repmat(upchirp, 1, 6);

    %% Start Frame Delimiter
    downchirp = conj(upchirp);
    SFD = repmat(downchirp, 1, 2);
end
