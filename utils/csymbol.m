classdef csymbol < handle
    %csymbol: infomation of a chirp segment
    %   including£ºposition, length, amplitude, frequency
    
    properties
        ahead       % ture if symbol if ahead of the window
        freq        % peak frequency (containing encoding shift and CFO)
        bin         % FFT bin of the correspongding peak
        amp         % amplitude
        len         % segment length
        chirp_n
        pkt_id      % belonging to which packet
    end
    
    methods
        function obj = csymbol(ahead, freq, amp, len,SF)
            % constractor
            
            % LoRa modulation & sampling parameters
            Fs = config(3);         % sample rate
            BW = config(2);         % LoRa bandwidth
            %             SF = param_configs(1);         % LoRa spreading factor
            nsamp = Fs * 2^SF / BW;
            
            obj.ahead = ahead;
            obj.freq = freq;
            obj.bin = (freq)/BW * 2^SF;
            obj.len = len;
            obj.amp = amp;
            obj.chirp_n = nsamp;
            obj.pkt_id = 0;
        end
        
        function ret = equal(obj, symbol)
            if abs(obj.bin - symbol.bin) < 2
                ret = true;
            else
                ret = false;
            end
        end
        
        function show(obj)
            fprintf('\t[peak] frequency = %.2f, value = %.1f, ',obj.freq,obj.bin);
            fprintf('symbol amplitude = %.2f, length = %d, ahead = %d, belong = %d\n', obj.amp, round(obj.len), obj.ahead, obj.pkt_id);
            if obj.ahead
                fprintf('\t       in-window offset = %d\n',round(obj.chirp_n-obj.len));
            else
                fprintf('\t       in-window offset = %d\n',round(obj.len));
            end
        end
        
        function write(obj,filename,wid,belong,value)
            fid = fopen(filename,'a');
            if obj.ahead
                offset = round(obj.chirp_n-obj.len);
            else
                offset = round(obj.len);
            end
            fprintf(fid,'\n%d,%.1f,%d,%d,%.2f,%d,%d', wid, obj.bin, offset, round(obj.len), obj.amp*100,belong,value);
            fclose(fid);
        end
        
        function belong(obj, id)
            obj.pkt_id = id;
        end
    end
end