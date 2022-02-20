function [iq_stream,count] = io_read_line(fileID, N)
    %RFILE read row signal from files
    %   [Data,N] = rfile(filename) returns the signal array and the number of samples
    %   [Data,N] = rfile(filename,samples) returns the first samples signal points
    if nargin < 2 || isempty(N)
        N = Inf;
    end
    
    if fileID == -1 error('FileID Error!'); end
    
    % gr_complex<float> is composed of two float32
    [row,count] = fread(fileID, N*2, 'float');
    
    if isinf(N)
        N=length(row)/2;
        fclose(fileID);
    end
    % reach file end
    if length(row) < N*2
        N = 0;
        iq_stream = [];
        return;
    end
    
    iq_stream = zeros(1,N);
    iq_stream(1:N) = row(1:2:2*N) + row(2:2:2*N)*1i;
end