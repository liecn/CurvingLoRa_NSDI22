function [payload_samples, peak_pos_calibration] = preamble_detection_curving(filename,sf,coefficient_matrix,bw,fs, n_payload, start_bit,threshold,fft_scaling)
% This CurvLoRa_matcher uses the same peak positions of three consecutive windows when matching the SFD frames
% considering frequency offset.

fileID = fopen(filename,'r');
output = fread(fileID,'float');
fclose(fileID);

output = reshape(output, 2, []);
output = output(1,:) + 1i* output(2,:);

output = output(start_bit:end);

baseline_bin = repmat('0',1,sf);
upchirp = symbol_generation_by_bits(baseline_bin,coefficient_matrix,bw,fs);
downchirp = conj(upchirp);

n_chips = 2^sf;
n_sample = n_chips*fs/bw;


preamble_count = 0;

while(1)
    for i = 1:size(output,2)-n_sample % detect from the first
        % Energy detection has not been implemented. Code here implements
        % dechirp to detect argmax and find preambles.
        
        first_dechirp = downchirp .* output((i-1)*n_sample+1 : i*n_sample);
        second_dechirp = downchirp .* output(i* n_sample+1:(i+1) * n_sample);
        
        chirp_fft_raw = (fft(first_dechirp, n_sample * fft_scaling));
        chirp_peak_overlap = abs(chirp_abs_alias(chirp_fft_raw, fs / bw));
        [~, first_peak_pos] = max(chirp_peak_overlap);
        first_peak_pos=first_peak_pos/fft_scaling;
        first_peak_pos=mod(round(first_peak_pos),2^sf);
        
        chirp_fft_raw = (fft(second_dechirp, n_sample * fft_scaling));
        chirp_peak_overlap = abs(chirp_abs_alias(chirp_fft_raw, fs / bw));
        [~, second_peak_pos] = max(chirp_peak_overlap);
        second_peak_pos=second_peak_pos/fft_scaling;
        second_peak_pos=mod(round(second_peak_pos),2^sf);
        
        %         first_FFT = abs(fft(first_dechirp)); % a symbol-length fft over the former
        %         second_FFT = abs(fft(second_dechirp));
        %         [first_peak_value,first_peak_pos] = max(first_FFT(1:n_chips)+first_FFT(end-n_chips+1:end));  %
        %         [~,second_peak_pos] = max(second_FFT(1:n_chips)+second_FFT(end-n_chips+1:end));
        
        
        %         if abs(first_peak_pos - second_peak_pos)<10 && first_peak_value > 1
        if abs(first_peak_pos - second_peak_pos)<10
            preamble_count = preamble_count+1;
        else
            preamble_count = 0;
        end
        if preamble_count == 5  %% detection of 5 upchirps
            preamble_end = (i+1)*n_sample;
            break;
        end
    end
    
    % To synchronize with SFD, we start from the next bit, i.e. preamble_end + 1, right after coarse detection
    % of preambles.
    
    SFD = [upchirp, repmat(downchirp,1,2)]; % 3 windows, upchirp, downchirp, downchirp
    SFD_conjugate = conj(SFD);
    
    
    i = preamble_end + 1 - 2*n_sample; % the earliest possible SFD start index.
    
    
    offset_thres = threshold;
    flag = 0;
    SFD_start_bit = [];
    while 1
        if(i >= preamble_end) % the latest possible SFD start index
            break;
        end
        de_SFD = SFD_conjugate .* output(i:i+3*n_sample-1);
        
        de_1 = de_SFD(1:end/3);
        de_2 = de_SFD(end/3+1:end/3*2);
        de_3 = de_SFD(end/3*2+1:end);
        SFD_FFT_1 = abs(fft(de_1));
        SFD_FFT_2 = abs(fft(de_2));
        SFD_FFT_3 = abs(fft(de_3));
        
        [p1_v,p1] = max(SFD_FFT_1(1:n_chips)+SFD_FFT_1(end-n_chips+1:end));
        [p2_v,p2] = max(SFD_FFT_2(1:n_chips)+SFD_FFT_2(end-n_chips+1:end));
        [p3_v,p3] = max(SFD_FFT_3(1:n_chips)+SFD_FFT_3(end-n_chips+1:end));
        if (p1 <= offset_thres || p1>=n_chips - offset_thres)
            if ( p1 == p2 && p2 == p3 && p1_v>10 && p2_v>10 && p3_v>10) % compare three consecutive windows' peaks
                flag = 1;
                peak_2b_calibrated = p1;
                % if only logging one SFD_start_bit, there may exist
                % one bit payload error offset, which should be fixed by
                % logging all SFD_start_bits and finding the mid of it,
                % which can locate the sync more accurately.
                SFD_start_bit = [SFD_start_bit, i]; % detect all the bits that result in three consecutive same peaks
            else
                if(flag == 1)
                    break
                end
            end
            i = i+1;
        else
            i = i + min(abs(p1-offset_thres),abs(n_chips-offset_thres-p1))*fs/bw;
        end
    end
    if isempty(SFD_start_bit)
        output = output(preamble_end+1:end); %% To avoid detecting no proper consecutive peaks
    else
        break
    end
end
SFD_start_bit = floor((SFD_start_bit(1)+SFD_start_bit(end) ) / 2);
SFD_end_bit = SFD_start_bit + 3 * n_sample - 1;
payload_samples = output( SFD_end_bit+1 : SFD_end_bit + n_payload * n_sample);
peak_pos_calibration = mod(1 - peak_2b_calibrated, n_chips);  %% calibrate from SFD_FFT_peak to 1, which should have been needed.
