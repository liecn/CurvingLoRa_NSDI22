classdef utils < handle
    
    methods (Static = true)
        function amp_interfere_gain = interfere_gain_to_mix_signal(data_refer,data_interfere,sir)
            amp_refer = mean(abs(data_refer));
            amp_interfere=mean(abs(data_interfere));
            amp_interfere_gain = amp_refer/(10^(sir/20))/amp_interfere;
            %             amp_refer = (sqrt(sum(abs(data_refer).^2)));
            %             amp_interfere=(sqrt(sum(abs(data_interfere).^2)));
            %             amp_interfere_gain = amp_refer/(10^(sir/20))/amp_interfere;
        end
        function dataout = mix_signal_by_sir(data_refer,data_interfere,sir)
            %             if nargin < 3
            %                 Fs = param_configs(3);         % sample rate
            %                 BW = param_configs(2);         % LoRa bandwidth
            %                 SF = param_configs(1);         % LoRa spreading factor
            %             end
            %             datain = utils.frame_amp_cut(datain,Fs,BW,SF);
            amp_refer = mean(abs(data_refer));
            amp_interfere=mean(abs(data_interfere));
            amp_interfere_gain = amp_refer/(10^(sir/20))/amp_interfere;
            dataout  = data_refer + amp_interfere_gain/sqrt(2)*data_interfere;
        end
        function dataout = add_noise_outdoor(datain,data_noise,snr)
            %             if nargin < 3
            %                 Fs = param_configs(3);         % sample rate
            %                 BW = param_configs(2);         % LoRa bandwidth
            %                 SF = param_configs(1);         % LoRa spreading factor
            %             end
            %             datain = utils.frame_amp_cut(datain,Fs,BW,SF);
            amp_sig = mean(abs(datain));
            amp_noise_level=mean(abs(data_noise));
            amp_noise = amp_sig/10^(snr/20)/amp_noise_level;
            dataout  = datain + amp_noise/sqrt(2)*data_noise ;
        end
        function dataout = add_noise(datain,snr,Fs,BW,SF)
            amp_sig = mean(abs(datain));
            amp_noise = amp_sig/10^(snr/20);
            dlen = length(datain);
            dataout  = datain + (amp_noise/sqrt(2) * randn([1 dlen]) + 1i*amp_noise/sqrt(2) * randn([1 dlen]));
        end
        %         function [real_sig,len] = gen_multiple_symbol(codeArray, invert, Fs,BW,SF)
        %             if nargin < 2 || isempty(invert)
        %                 invert = 0;
        %             end
        %
        %             real_sig=[];
        %             for i = codeArray(1:end)
        %                 %                 tmp_symb
        %                 %                 =
        %                 %                 utils.gen_symbol(2^SF-i,invert,Fs,BW,SF);
        %                 tmp_symb = utils.gen_symbol(i,invert,Fs,BW,SF);
        %                 real_sig = [real_sig,tmp_symb];
        %             end
        %             len = length(real_sig);
        %         end
        %
        function symb = gen_symbol(code_word,down,Fs,BW,SF)
            %             if nargin < 3 || isempty(Fs) || Fs < 0
            %                 Fs = param_configs(3);         % default sample rate
            %                 BW = param_configs(2);         % LoRa bandwidth
            %                 SF = param_configs(1);         % LoRa spreading factor
            %             end
            org_Fs = Fs;
            if Fs < BW
                Fs = BW;
            end
            T = 0:1/Fs:2^SF/BW-1/Fs;       % time vector a chirp
            num_samp = Fs * 2^SF / BW;     % number of samples of a chirp
            
            % I/Q traces
            f0 = -BW/2; % start freq
            f1 = BW/2;  % end freq
            chirpI = chirp(T, f0, 2^SF/BW, f1, 'linear', 90);
            chirpQ = chirp(T, f0, 2^SF/BW, f1, 'linear', 0);
            baseline = complex(chirpI, chirpQ);
            if nargin >= 2 && down
                baseline = conj(baseline);
            end
            baseline = repmat(baseline,1,2);
            %             baseline =
            %             [baseline,
            %             baseline*exp(1i*(0))];
            clear chirpI chirpQ
            
            % Shift for
            % encoding
            offset = round((2^SF - code_word) / 2^SF * num_samp);
            symb = baseline(offset+(1:num_samp));
            
            if org_Fs ~= Fs
                overSamp = Fs/org_Fs;
                symb = symb(1:overSamp:end);
            end
        end
        
        %         function [real_sig,len] = gen_packet(codeArray, invert, Fs,BW,SF)
        %             %GENPAKCKET
        %             %generate raw
        %             %signal data
        %             %   Detailed
        %             %   explanation
        %             %   goes here
        %             %             if nargin < 3 || isempty(Fs) || Fs < 0
        %             %                 Fs = param_configs(3);         % default sample rate
        %             %                 BW = param_configs(2);         % LoRa bandwidth
        %             %                 SF = param_configs(1);         % LoRa spreading factor
        %             %             end
        %             if nargin < 2 || isempty(invert)
        %                 invert = 0;
        %             end
        %
        %             codeChirp = utils.gen_symbol(0,invert,Fs,BW,SF);
        %             syncChirp = utils.gen_symbol(0,~invert,Fs,BW,SF);
        %
        %
        %             real_sig = repmat(codeChirp,1,8);
        %             real_sig = [real_sig,utils.gen_symbol(2^SF-24,invert,Fs,BW,SF),utils.gen_symbol(2^SF-32,invert,Fs,BW,SF)];
        %             real_sig = [real_sig,syncChirp,syncChirp,syncChirp(1:end/4)];
        %             for i = codeArray(1:end)
        %                 %                 tmp_symb
        %                 %                 =
        %                 %                 utils.gen_symbol(2^SF-i,invert,Fs,BW,SF);
        %                 tmp_symb = utils.gen_symbol(i,invert,Fs,BW,SF);
        %                 real_sig = [real_sig,tmp_symb];
        %             end
        %             len = length(real_sig);
        %         end
        
        function y = spectrum(data,SF,window,overlap,nfft,Fs)
            if nargin < 3
                window = 512;
                overlap = 256;
                nfft = 2048;
            end
            if isa(data,'double')
                data = data + 1e-10*1i;
            end
            
            % Param
            if nargin < 4
                Fs = config(3);         % sample rate
            end
            BW = config(2);         % LoRa bandwidth
            num_samp = Fs * 2^SF / BW;     % number of samples of a chirp
            
            if Fs <= BW*2 || SF < 8
                window = 64;
                overlap = 60;
                nfft = 2048;
            end
            
            % STFT
            s = spectrogram(data,window,overlap,nfft,'yaxis');
            
            % Cut target
            % band
            if Fs > BW
                nvalid = floor(BW / Fs * nfft);
                % Add up
                y = s(1:nvalid,:);
                for i = 1:floor(nfft/nvalid)-1
                    y = y + s(nvalid*i+(1:nvalid),:);
                end
                y = [y(ceil(nvalid/2):end,:); y(1:floor(nvalid/2),:)];
            else
                y = zeros(floor(BW/Fs * nfft), size(s,2));
                
                base = round(size(y,1) /2 );
                h1 = ceil(nfft/2);
                h2 = nfft-h1;
                y(base+1:base+h1,:) = s(1:h1,:);
                y(base-h2+1:base,:) = s(h1+1:end,:);
                %                 y(flength/2+(0:floor(nfft/2)-1))
                %                 =
                %                 s(1:floor(nfft/2),:);
                %                 y(1:nfft,:)
                %                 =
                %                 s(1:nfft,:);
            end
            fig=figure;
            set(fig,'DefaultAxesFontSize',20);
            set(fig,'DefaultAxesFontWeight','bold');
            colormap summer
            imagesc([1 num_samp],[-BW/2 BW/2]/1e3,abs(y)*200);
            %                     surf(0:126,0:256,abs(y),'edgecolor','none');view(2)
            
            %                 surf(0:num_samp-1,0:BW-1,abs(y),'edgecolor',
            %                 'none');view(2)
            set(gca,'YDir','normal');
            %             title('Spectrogram');
            xlabel('PHY sample #');
            ylabel('Frequency (kHz)');
            set (gcf,'position',[0,0,640*2,360] );
            %         surf([1:size(y,2)],[1:size(y,1)],abs(y),'edgecolor', 'none');view(2);
            %         shading interp
            %         xlabel('Time (ms)');
            %         ylabel('Frequency (kHz)');
            %         xlim([1,size(y,2)])
            %         ylim([1,size(y,1)])
            %         yticks([14:50:114]);
            %         yticklabels({'-50','0','50'})
            %         xticks([1:14:30]);
            %         xticklabels({'0','0.5','1'})
            %         set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
            
        end
        
        %         function [data,len] = mixPkt(pkt1, pkt2)
        %             len = max(length(pkt1),length(pkt2));
        %             if size(pkt1,2) < len
        %                 pkt1 = [pkt1,zeros(1,len-length(pkt1))];
        %             else
        %                 pkt2 = [pkt2,zeros(1,len-length(pkt2))];
        %             end
        %             data = pkt1 + pkt2;
        %         end
        %
        %         function B = frame_amp_cut(datain,Fs,BW,SF)
        %             %AMPCUT
        %             %extract the
        %             %useful
        %             %signal based
        %             %on the
        %             %amplitude
        %
        %             % parameters
        %             % Param
        %             %             if nargin < 3
        %             %                 Fs = config(3);         % sample rate
        %             %                 BW = config(2);         % LoRa bandwidth
        %             %                 SF = config(1);         % LoRa spreading factor
        %             %             end
        %             nsamp = Fs * 2^SF / BW;
        %
        %             mwin = nsamp/2;
        %             A = movmean(abs(datain),mwin);
        %             B = datain(A >= max(A)/2);
        %         end
    end
end