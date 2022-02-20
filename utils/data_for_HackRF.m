function [output] = data_for_HackRF(Payload,sf,coefficient_matrix,bw,fs,dutycycle,filename)
output = packet_generation_curving(Payload,sf,coefficient_matrix,bw,fs);
output = reshape(output,1,[]);
idle_count = size(output,2)*(1/dutycycle-1);
idle = zeros(1,idle_count);
output = [output,idle];
fileID = fopen(filename,'w');
fwrite(fileID, output,'float');
fclose(fileID); 
