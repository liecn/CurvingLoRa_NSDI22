classdef cpacket_v2 < handle
%PEAKINFO Summary of this class goes here
%   Detailed explanation goes here
    
    properties
        start_win
        start_sample
        cfo
        to
        bin
    end
    
    methods
        function obj = cpacket_v2(frame_st,offset_f,offset_t,bin)
            %PEAKINFO Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 3
                return;
            end
            if nargin < 4
                bin = 0;
            end
            obj.start_sample = frame_st;
            obj.cfo = offset_f;
            obj.to = offset_t;
            obj.bin = bin;
        end
        
        function show(obj)
            fprintf('\t[packet] start from sample%d, cfo = %.2f, to = %.2f\n',obj.start_sample,obj.cfo,obj.to);
        end
    end
end