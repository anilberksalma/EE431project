clear; clc;

% --- Simulation Configuration ---
num_bits = 20000; % İstatistiksel olarak doğru BER sonuçları için bit sayısını artırdım
EbN0_dB = 0:1:8;  % Simüle edilecek Eb/N0 aralığı (dB cinsinden)
msg_bits = randi([0 1], 1, num_bits);

% BER sonuçlarını saklamak için boş diziler tanımı
ber_hamming = zeros(1, length(EbN0_dB));
ber_conv = zeros(1, length(EbN0_dB));

fprintf('==================================================\n');
fprintf('     EE431 AWGN SIMULATION - ANIL BERK SALMA      \n');
fprintf('==================================================\n');
fprintf('Running simulation for Eb/N0 range: %d to %d dB...\n\n', EbN0_dB(1), EbN0_dB(end));

% Kod Hızları (Code Rates) - Gürültü gücü hesaplaması için
R_hamming = 4/7;
R_conv = 1/2; 

num_blocks = num_bits / 4;

% --- Eb/N0 Döngüsü Başlangıcı ---
for i = 1:length(EbN0_dB)
    current_db = EbN0_dB(i);
    ebn0_linear = 10^(current_db / 10); % dB değerini lineer ölçeğe çevirme
    
    % =========================================================================
    % --- 1. Hamming (7,4) Coded Pipeline over AWGN ---
    % =========================================================================
    % Blok bazlı kodlama
    hamming_encoded = [];
    for b = 1:num_blocks
        block = msg_bits(4*b-3 : 4*b);
        hamming_encoded = [hamming_encoded, hamming_encode(block)];
    end
    
    % BPSK Modülasyonu (0 -> +1, 1 -> -1)
    tx_hamming = 1 - 2 * hamming_encoded;
    
    % AWGN Kanalı Gürültü Hesabı: sigma = sqrt(1 / (2 * R * Eb/N0))
    sigma_hamming = sqrt(1 / (2 * R_hamming * ebn0_linear));
    noise_hamming = sigma_hamming * randn(1, length(tx_hamming));
    rx_signals_hamming = tx_hamming + noise_hamming;
    
    % Sert Karar Demodülasyon (Hard-Decision Demodulation)
    rx_bits_hamming = rx_signals_hamming <= 0;
    
    % Blok bazlı kod çözme ve hata düzeltme
    hamming_decoded = [];
    for b = 1:num_blocks
        block = rx_bits_hamming(7*b-6 : 7*b);
        [dec_block, ~] = hamming_decode(block);
        hamming_decoded = [hamming_decoded, dec_block];
    end
    
    % Hamming için BER hesaplama
    ber_hamming(i) = sum(msg_bits ~= hamming_decoded) / num_bits;
    
    
    % =========================================================================
    % --- 2. Convolutional Coded Pipeline over AWGN ---
    % =========================================================================
    % Evrişimli Kodlama
    conv_encoded = conv_encode(msg_bits);
    
    % BPSK Modülasyonu (0 -> +1, 1 -> -1)
    tx_conv = 1 - 2 * conv_encoded;
    
    % AWGN Kanalı Gürültü Hesabı
    sigma_conv = sqrt(1 / (2 * R_conv * ebn0_linear));
    noise_conv = sigma_conv * randn(1, length(tx_conv));
    rx_signals_conv = tx_conv + noise_conv;
    
    % Sert Karar Demodülasyon
    rx_bits_conv = rx_signals_conv <= 0;
    
    % Viterbi Kod Çözücü (ACS ve Traceback)
    conv_decoded = viterbi_decode(rx_bits_conv);
    
    % Evrişimli kod için BER hesaplama
    ber_conv(i) = sum(msg_bits ~= conv_decoded) / num_bits;
    
    % Döngü esnasında anlık log basma
    fprintf('Eb/N0 = %d dB | Hamming BER: %1.5f | Convolutional BER: %1.5f\n', ...
        current_db, ber_hamming(i), ber_conv(i));
end

fprintf('\n==================================================\n');
fprintf('Simulation loop completed. Ready for visualization.\n');