classdef cwin < handle
%PEAKINFO Summary of this class goes here
%   Detailed explanation goes here
    
    properties
        symset
        size
        id
    end
    
    methods
        function obj = cwin(id)
            if nargin > 0
                obj.id = id;
            else
                obj.id = 0;
            end
            obj.size = 0;
            obj.symset = [];
        end
        
        function addSymbol(obj, sym)
            obj.symset = [obj.symset sym];
            obj.size = obj.size + 1;
        end
        
        function ret = rmSymbol(obj, sym)
            for i = 1:obj.size
                if sym.equal(obj.symset(i))
                    obj.symset = [obj.symset(1:i-1), obj.symset(i+1:end)];
                    ret = true;
                    return;
                end
            end
            ret = false;
        end
        
        function show(obj)
            fprintf('Symbol Set %d (%d items):\n',obj.id, obj.size);
            for sym = obj.symset
                sym.show();
            end
        end
    end
end