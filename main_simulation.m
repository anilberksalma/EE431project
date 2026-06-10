clear; clc;

% --- Simulation Configuration ---
num_bits = 4000; % Toplam bilgi biti sayısı (Hamming için 4'ün katı olmalı)
msg_bits = randi([0 1], 1, num_bits);

fprintf('==================================================\n');
fprintf('  EE431 SIMULATION FRAMEWORK - ANIL BERK SALMA   \n');
fprintf('==================================================\n');
fprintf('Generated %d random transceiver test bits.\n\n', num_bits);

% =========================================================================
% --- 1. Pipeline Verification for Hamming (7,4) Code ---
% =========================================================================
fprintf('Testing Hamming (7,4) Chain... ');
num_blocks = num_bits / 4;
hamming_encoded = [];

% Blok bazlı kodlama (Block-by-block encoding)
for b = 1:num_blocks
    block = msg_bits(4*b-3 : 4*b);
    hamming_encoded = [hamming_encoded, hamming_encode(block)];
end

% BPSK Modülasyonu (Mapping: 0 -> +1, 1 -> -1)
tx_signals_hamming = 1 - 2 * hamming_encoded; 

% İdeal Kanal (Şimdilik gürültüsüz, direkt sert karar eşiği)
rx_bits_hamming = tx_signals_hamming <= 0; 

% Blok bazlı kod çözme (Block-by-block decoding)
hamming_decoded = [];
for b = 1:num_blocks
    block = rx_bits_hamming(7*b-6 : 7*b);
    [dec_block, ~] = hamming_decode(block);
    hamming_decoded = [hamming_decoded, dec_block];
end

hamming_errors = sum(msg_bits ~= hamming_decoded);
fprintf('Done. Errors under ideal channel: %d\n', hamming_errors);


% =========================================================================
% --- 2. Pipeline Verification for Convolutional Code ---
% =========================================================================
fprintf('Testing Convolutional Code Chain... ');

% Evrişimli Kodlama
conv_encoded = conv_encode(msg_bits);

% BPSK Modülasyonu
tx_signals_conv = 1 - 2 * conv_encoded;

% İdeal Kanal (Sert karar eşiği)
rx_bits_conv = tx_signals_conv <= 0;

% Viterbi Kod Çözücü
conv_decoded = viterbi_decode(rx_bits_conv);

conv_errors = sum(msg_bits ~= conv_decoded);
fprintf('Done. Errors under ideal channel: %d\n', conv_errors);
fprintf('==================================================\n');