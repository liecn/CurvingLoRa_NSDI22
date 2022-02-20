function [preamble,SFD] = preamble_generation(sf,coefficient,bw,fs)
% CurvingLoRa Packet Compositions

%% Preamble * 8
n_preamble_upchirp=config(5);
n_preamble_downchirp=config(6);
% if coefficient==1
%     upchirp = utils.gen_symbol(0,false,fs,bw,sf);
% else
    upchirp = symbol_generation_by_frequency(0,sf,[1],bw,fs);
% end

preamble = repmat(upchirp,1,n_preamble_upchirp);

midchirp_1 = symbol_generation_by_frequency(0,sf,coefficient,bw,fs);
midchirp_2 = symbol_generation_by_frequency(0,sf,coefficient,bw,fs);

preamble=[preamble,midchirp_1,midchirp_2];
%% Start Frame Delimiter
downchirp = conj(upchirp);
SFD = repmat(downchirp,1,n_preamble_downchirp);
SFD=[SFD,SFD(1:length(SFD)/n_preamble_downchirp/4)];
end