function [output] = down_sample(filename, BW, sample_rate)
fileID = fopen(filename,'r');
output = fread(fileID,'float');
fclose(fileID); 

output = reshape(output, 2, []);
output = output(1,:) + 1i* output(2,:); 
output = output(1:sample_rate/BW:end);