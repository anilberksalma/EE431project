function analyze_errors(tx_bits, rx_bits, decoded_bits, system_name)
    % Çözülemeyen nihai bit hataları (Her iki sistemde de giriş/çıkış 96 bittir)
    total_errors = sum(tx_bits ~= decoded_bits);
    
    % Kanal hataları hesaplanırken boyut kontrolü (Boyut uyumsuzluğunu çözen kısım)
    if length(tx_bits) == length(rx_bits)
        channel_errors = sum(tx_bits ~= rx_bits);
    else
        channel_errors = sum(tx_bits ~= decoded_bits) + (length(rx_bits) - length(tx_bits)); 
        channel_errors = length(rx_bits) - sum(tx_bits == decoded_bits); 
    end
    
    % Eğer kanal hatasını bulmanın en temiz yolunu istiyorsan, sadece genel özete odaklanalım:
    fprintf('\n  [DIAGNOSTIC REPORT: %s]\n', upper(system_name));
    fprintf('  -> Total Bits Transmitted: %d\n', length(tx_bits));
    fprintf('  -> Residual (Uncorrected) Errors after Decoding: %d\n', total_errors);
    
    if total_errors > 0
        error_indices = find(tx_bits ~= decoded_bits);
        if length(error_indices) > 1
            avg_distance = mean(diff(error_indices));
            fprintf('  -> Diagnostic Insight: Errors are spaced by an average of %.1f bits.\n', avg_distance);
            if avg_distance < 4
                fprintf('  -> Analysis: Dense error cluster detected (Burst error penalty).\n');
            end
        end
    else
        fprintf('  -> Diagnostic Insight: Code achieved 100%% perfect correction for this block.\n');
    end
    fprintf('------------------------------------------------------\n');
end