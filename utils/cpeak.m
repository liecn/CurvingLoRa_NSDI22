classdef cpeak < handle
%PEAKINFO Summary of this class goes here
%   Detailed explanation goes here
    
    properties
        height
        freq
        bin
    end
    
    methods
        function obj = cpeak(height,freq,sf)
            %PEAKINFO Construct an instance of this class
            %   Detailed explanation goes here
            obj.height = height;
            obj.freq = freq;
            obj.bin = (125e3 - freq)/125e3 * 2^sf;
        end
        
        function ret = equal(obj, peak)
            if abs(obj.bin - peak.bin) < 2
                ret = true;
            else
                ret = false;
            end
        end
        
        function show(obj)
            fprintf('\t[peak] frequency = %.2f, height = %.2f, value = %.2f\n',obj.freq,obj.height,obj.bin);
        end
    end
end