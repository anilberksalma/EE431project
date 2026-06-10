function analyze_errors(tx_bits, rx_bits, decoded_bits, system_name)
    % Bu fonksiyon, çözülemeyen hataların karakteristiğini analiz eder.
    
    total_errors = sum(tx_bits ~= decoded_bits);
    channel_errors = sum(tx_bits ~= rx_bits);
    
    fprintf('\n========== DIAGNOSTIC REPORT: %s ==========\n', upper(system_name));
    fprintf('Total Bits Transmitted: %d\n', length(tx_bits));
    fprintf('Errors Introduced by BSC Channel: %d\n', channel_errors);
    fprintf('Residual (Uncorrected) Errors: %d\n', total_errors);
    
    if total_errors > 0
        % Hataların nerede yoğunlaştığını bulma (Burst error analizi)
        error_indices = find(tx_bits ~= decoded_bits);
        if length(error_indices) > 1
            avg_distance = mean(diff(error_indices));
            fprintf('Diagnostic Insight: Errors are spaced by an average of %.1f bits.\n', avg_distance);
            if avg_distance < 4
                fprintf('Analysis: System suffered from a dense error cluster (Burst-like behavior).\n');
            end
        end
    else
        fprintf('Diagnostic Insight: Code achieved 100%% error correction for this block.\n');
    end
    fprintf('======================================================\n');
end