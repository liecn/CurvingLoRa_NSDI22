function [code_array, n_payload_corrected] = frame_decoder_comp(sig, outfile, sf, coefficient_matrix, final_data_frequency_packet)

    %
    % parameter
    %
    bw = config(2);
    fs = config(3);
    DEBUG = config(0); % DEBUG
    nsamp = fs * 2^sf / bw;
    nfft = nsamp * config(4);
    
    n_preamble_upchirp = config(5);
    n_payload = config(7);
    % final_data_frequency_packet = [zeros(n_preamble_upchirp, 1); squeeze(final_data_frequency_packet)];
    % % signal should be oversampled
    if fs < 2 * bw
        fprintf('SAMPLE RATE TOO LOW!\n');
        return;
    end

    fid = fopen(outfile, 'w');

    if nargin > 1 &&~isempty(outfile)
        fprintf(fid, '%s\n', 'win,peak,freq,bin,value,phase,compensation,groundtruth');
    end

    %
    % synchronization
    %
    %     sig = frame_sync_zero(sig);

    %
    % decode
    %
    sig = sig(floor(12.25*nsamp)+1:end);
    if length(final_data_frequency_packet)~=n_payload
        final_data_frequency_packet=final_data_frequency_packet(n_preamble_upchirp+1:end);
    end
    % n_payload = floor(numel(sig) / nsamp);
    
    n_payload_corrected = 0;
    

    n_packet=length(final_data_frequency_packet);
    code_array = zeros(1, n_packet);
    for lp = 0:n_packet - 1
        target = sig(lp * nsamp + (1:nsamp));

%         if (lp < n_preamble_upchirp)
%             rz_o = chirp_dechirp_fft(target, nfft, sf, [1]);
%         else
%             rz_o = chirp_dechirp_fft(target, nfft, sf, coefficient_matrix);
%         end
        rz_o = chirp_dechirp_fft(target, nfft, sf, coefficient_matrix);
        target_nfft = round(bw / fs * nfft);

        comp = 0;
        step = 0.01;
        pk_tp = -1;

        for pc = 0:step:1 - step
            tmp = rz_o(1:target_nfft) + rz_o(end - target_nfft + 1:end) * exp(1i * 2 * pi * pc);

            if max(abs(tmp)) > pk_tp
                pk_tp = max(abs(tmp));
                rz = tmp;
                az = abs(tmp);
                comp = 2 * pi * pc;
            end

        end

        [peak_h, I] = max(az);
        peak_p = angle(rz(I));
        peak_i = I / (nfft / nsamp);
        peak_f = peak_i / 2^sf * bw;

        if DEBUG
            pk_phase(lp + 1) = peak_p;
            init_phase(lp + 1) = angle(target(1));
            comp_phase(lp + 1) = comp;
            %             figure;
            %                 subplot(3,1,1);
            %                     plot(abs(rz_o(1:target_nfft)));
            %                     title(['win ',num2str(lp+1)]);
            %                 subplot(3,1,2);
            %                     plot(abs(rz_o(end-target_nfft+1:end)));
            %                     title(['comp ',num2str(comp)]);
            %                 subplot(3,1,3);
            %                   plot(az);
            %                   title(['win ',num2str(lp+1)]);
            %                   xlim([I-300 I+300]);
        end

        %         code_array(lp+1) = floor(peak_i);
        code_array(lp + 1) = mod(round(peak_i), 2^sf);

        if DEBUG
            fprintf('\n window %d\n', lp + 1);
            fprintf("peak=%d,  freq=%d,  bin=%.2f[%d], phase=%.2f, comp=%.2f\n", ...
                peak_h, peak_f, peak_i, mod(round(peak_i), 2^sf), peak_p, comp);
        end

        if code_array(lp + 1) == final_data_frequency_packet(lp + 1)
            n_payload_corrected = n_payload_corrected + 1;
        end

        if nargin > 1 &&~isempty(outfile)
            fprintf(fid, '%s\n', [num2str(lp + 1), ', ',num2str(peak_h),', ' ...
                            , num2str(peak_f), ', ',num2str(peak_i),', ' ...
                            , num2str(mod(round(peak_i), 2^sf)), ',' ...
                            , num2str(peak_p), ',', num2str(comp), ',', num2str(final_data_frequency_packet(lp + 1))]);
        end

    end

    if DEBUG
        idx = [1:10, 13.25:n_payload + 2.25];
        figure;
        plot(idx, pk_phase, 'p-', 'LineWidth', 1);
        title('Peak Phase');
        grid on; box on;

        figure;
        plot(idx, unwrap(pk_phase), 'p-', 'LineWidth', 1);
        title('Unwrap--Peak Phase');
        grid on; box on;

        figure;
        plot(idx, init_phase, 'p-', 'LineWidth', 1);
        title('Initial Phase');
        grid on; box on;

        figure;
        comp_phase(comp_phase > pi) = comp_phase(comp_phase > pi) - 2 * pi;
        plot(idx, comp_phase, 'p-', 'LineWidth', 1);
        title('Compensation Phase');
        ylim([-pi pi]);
        grid on; box on;
    end


    if nargin > 1 &&~isempty(outfile)
        fclose(fid);
    end

end
