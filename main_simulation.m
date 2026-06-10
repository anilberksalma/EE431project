clear; clc;

% --- Simulation Configuration ---
num_bits = 40000; % Eğrilerin pürüzsüz çıkması için bit sayısını daha da artırdım
EbN0_dB = 0:1:8;  
msg_bits = randi([0 1], 1, num_bits);

ber_hamming = zeros(1, length(EbN0_dB));
ber_conv = zeros(1, length(EbN0_dB));

fprintf('==================================================\n');
fprintf('     EE431 FINAL SIMULATION - ANIL BERK SALMA     \n');
fprintf('==================================================\n');
fprintf('Running complete simulation pipeline...\n\n');

R_hamming = 4/7;
R_conv = 1/2; 
num_blocks = num_bits / 4;

% --- Eb/N0 Döngüsü ---
for i = 1:length(EbN0_dB)
    current_db = EbN0_dB(i);
    ebn0_linear = 10^(current_db / 10);
    
    % 1. Hamming (7,4) Pipeline
    hamming_encoded = [];
    for b = 1:num_blocks
        block = msg_bits(4*b-3 : 4*b);
        hamming_encoded = [hamming_encoded, hamming_encode(block)];
    end
    tx_hamming = 1 - 2 * hamming_encoded;
    sigma_hamming = sqrt(1 / (2 * R_hamming * ebn0_linear));
    noise_hamming = sigma_hamming * randn(1, length(tx_hamming));
    rx_signals_hamming = tx_hamming + noise_hamming;
    rx_bits_hamming = rx_signals_hamming <= 0;
    
    hamming_decoded = [];
    for b = 1:num_blocks
        block = rx_bits_hamming(7*b-6 : 7*b);
        [dec_block, ~] = hamming_decode(block);
        hamming_decoded = [hamming_decoded, dec_block];
    end
    ber_hamming(i) = sum(msg_bits ~= hamming_decoded) / num_bits;
    
    % 2. Convolutional / Viterbi Pipeline
    conv_encoded = conv_encode(msg_bits);
    tx_conv = 1 - 2 * conv_encoded;
    sigma_conv = sqrt(1 / (2 * R_conv * ebn0_linear));
    noise_conv = sigma_conv * randn(1, length(tx_conv));
    rx_signals_conv = tx_conv + noise_conv;
    rx_bits_conv = rx_signals_conv <= 0;
    
    conv_decoded = viterbi_decode(rx_bits_conv);
    ber_conv(i) = sum(msg_bits ~= conv_decoded) / num_bits;
    
    fprintf('Eb/N0 = %d dB | Hamming BER: %1.5f | Convolutional BER: %1.5f\n', ...
        current_db, ber_hamming(i), ber_conv(i));
end

% =========================================================================
% --- 3. Theoretical Uncoded BPSK Performance ---
% =========================================================================
% Pb = Q(sqrt(2 * Eb/N0))
ber_theoretical = qfunc(sqrt(2 * 10.^(EbN0_dB/10)));

% =========================================================================
% --- 4. Data Visualization (Comparative Plot) ---
% =========================================================================
fprintf('\nGenerating performance comparative curves...\n');
figure('Name', 'EE431 BER Performance Analysis', 'NumberTitle', 'off');

% Logaritmik y-ekseni grafiği
semilogy(EbN0_dB, ber_theoretical, 'k--', 'LineWidth', 2); hold on;
semilogy(EbN0_dB, ber_hamming, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 6);
semilogy(EbN0_dB, ber_conv, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 6);
hold off;

% Grafik Estetiği ve Labellar
grid on;
set(gca, 'YGrid', 'on', 'XGrid', 'on', 'YMinorGrid', 'on');
xlabel('E_B/N_0 (dB)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 11, 'FontWeight', 'bold');
title('BER Performance Comparison: Hamming vs. Convolutional vs. Uncoded', 'FontSize', 12, 'FontWeight', 'bold');
legend('Theoretical Uncoded BPSK', 'Simulated Hamming (7,4)', 'Simulated Convolutional (K=4, R=1/2)', ...
       'Location', 'southwest', 'FontSize', 10);
axis([EbN0_dB(1) EbN0_dB(end) 1e-5 1]);

fprintf('Simulation successfully completed!\n');