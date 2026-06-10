clear; clc;

personal_str = 'ECC2026-S06F';
binary_matrix = dec2bin(personal_str, 8) - '0';
msg_bits = reshape(binary_matrix', 1, []); % 96-bit ana mesaj

noise_seeds = [8677, 13981, 21493];
EbNo_dB = 0:1:8; % Simülasyon aralığı

fprintf('==================================================\n');
fprintf('     EE431 EXPERIMENT RUN WITH NOISE SEEDS        \n');
fprintf('==================================================\n');

% 3 Farklı tohum için döngü başlatma
for s = 1:length(noise_seeds)
    current_seed = noise_seeds(s);
    rng(current_seed); % MATLAB Rastgele sayı üretecini sabitleme
    
    fprintf('\n---> Running Experiment with Seed: %d\n', current_seed);
    
    % Evrişimli Kodlama (K=4, Rate 1/2) + 3 adet Tail Bit
    encoded_bits = conv_encode(msg_bits); 
    
    % BPSK Modülasyonu (0 -> +1, 1 -> -1)
    tx_signals = 1 - 2 * encoded_bits;
    
    % Örnek olarak Eb/No = 4 dB için kanal gürültüsü ekleyip test etme
    EbNo_linear = 10^(4/10);
    % Rate = 1/2 gürültü varyansı hesaplama
    sigma = sqrt(1 / (2 * (1/2) * EbNo_linear)); 
    
    % Sabitlenmiş gürültü üretimi
    noise = sigma * randn(size(tx_signals));
    rx_signals = tx_signals + noise;
    
    % Demodülasyon (Hard Decision)
    rx_bits = rx_signals <= 0;
    
    % Viterbi ile Kod Çözme
    decoded_bits = viterbi_decode(rx_bits);
    
    % Çözülen veriyi tekrar metne dönüştürme
    decoded_str = char(bin2dec(reshape(char(decoded_bits + '0'), 8, [])'))';
    
    fprintf('Seed %d Çıktısı: %s ', current_seed, decoded_str);
    if strcmp(personal_str, decoded_str)
        fprintf('[Kusursuz Çözüldü]\n');
    else
        fprintf('[Kanaldan Dolayı Hatalı Çözüldü]\n');
    end
end