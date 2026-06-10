clear; clc;

% ==========================================
% 1. PARAMETRELERİN TANIMLANMASI
% ==========================================
personal_str = 'ECC2026-S06F';
binary_matrix = dec2bin(personal_str, 8) - '0';
msg_bits = reshape(binary_matrix', 1, []); % 96-bit ana mesaj

noise_seeds = [8677, 13981, 21493];        % Soru 4: Tohumlar
channel_bers = [0.001, 0.01, 0.05, 0.10, 0.15]; % Soru 5: Kanal Hata Oranları

fprintf('==================================================================\n');
fprintf('         EE431 FINAL SIMULATION - BINARY SYMMETRIC CHANNEL        \n');
fprintf('==================================================================\n');

% Sonuçları saklamak için matrisler (Satır: Tohumlar, Sütun: BER'ler)
hamming_results = zeros(length(noise_seeds), length(channel_bers));
viterbi_results = zeros(length(noise_seeds), length(channel_bers));

% ==========================================
% 2. SİMÜLASYON DÖNGÜSÜ
% ==========================================
for s = 1:length(noise_seeds)
    current_seed = noise_seeds(s);
    
    fprintf('\n------------------------------------------------------------------\n');
    fprintf('Running Experiments for Noise Seed: %d\n', current_seed);
    fprintf('------------------------------------------------------------------\n');
    fprintf('%-12s | %-15s | %-15s\n', 'Kanal BER', 'Hamming Çıkış BER', 'Viterbi Çıkış BER');
    fprintf('------------------------------------------------------------------\n');
    
    for b = 1:length(channel_bers)
        p = channel_bers(b);

        rng(current_seed);
        
        % ------------------------------------------
        % A) HAMMING (7,4)
        % ------------------------------------------
        % Mesajı 4'er bitlik bloklara bölüp kodlama
        hamming_encoded = [];
        for i = 1:4:length(msg_bits)
            hamming_encoded = [hamming_encoded, hamming_encode(msg_bits(i:i+3))];
        end
        
        % BSC Kanalı: p olasılığıyla bitleri ters çevir (Hata Ekle)
        hamming_noise = rand(size(hamming_encoded)) < p;
        hamming_rx = xor(hamming_encoded, hamming_noise);
        
        % Hamming Kod Çözme
        hamming_decoded = [];
        for i = 1:7:length(hamming_rx)
            hamming_decoded = [hamming_decoded, hamming_decode(hamming_rx(i:i+6))];
        end
        
        % Hamming Bit Hata Oranı (BER) Hesaplama
        hamming_results(s, b) = sum(msg_bits ~= hamming_decoded) / length(msg_bits);
        
        % ------------------------------------------
        % B) CONVOLUTIONAL / VITERBI
        % ------------------------------------------
        % Evrişimli Kodlama (Tail bitler dahil)
        viterbi_encoded = conv_encode(msg_bits);
        
        % BSC Kanalı: p olasılığıyla bitleri ters çevir
        viterbi_noise = rand(size(viterbi_encoded)) < p;
        viterbi_rx = xor(viterbi_encoded, viterbi_noise);
        
        % Viterbi Kod Çözme
        viterbi_decoded = viterbi_decode(viterbi_rx);
        
        % Viterbi Bit Hata Oranı (BER) Hesaplama
        viterbi_results(s, b) = sum(msg_bits ~= viterbi_decoded) / length(msg_bits);
        
        % Sonuçları anlık olarak ekrana bas
        fprintf('%-12.3f | %-15.5f | %-15.5f\n', p, hamming_results(s, b), viterbi_results(s, b));
    end
end

% ==========================================
% 3. RAPOR İÇİN ÖZET TABLO
% ==========================================
fprintf('\n==================================================================\n');
fprintf('                      SIMULATION COMPLETE                         \n');
fprintf('==================================================================\n');