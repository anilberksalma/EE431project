function [msg_bits, syndrome] = hamming_decode(rx_codeword)

    % Giriş dizisini satır vektörüne çevirme
    if iscolumn(rx_codeword)
        rx_codeword = rx_codeword';
    end

    H = [1 0 1 1 1 0 0;
         1 1 1 0 0 1 0;
         0 1 1 1 0 0 1];

    % Sendrom hesaplama: s = rx * H^T (modulo 2)
    syndrome = mod(rx_codeword * H', 2);
    
    % s = [s1 s2 s3] -> s1*4 + s2*2 + s3*1
    syn_dec = syndrome(1)*4 + syndrome(2)*2 + syndrome(3)*1;
    
    % Hata vektörünü (coset leader) başlangıçta sıfır kabul ediyoruz (hata yokmuş gibi)
    error_vector = zeros(1, 7);
    
    % H matrisinin sütun eşleşmelerine göre hata konumunu belirliyoruz:
    switch syn_dec
        case 0 % [0 0 0]
            % Hata yok
            error_vector = zeros(1, 7);
        case 6 % [1 1 0] -> H matrisinin 1. sütunu
            error_vector = [1 0 0 0 0 0 0];
        case 3 % [0 1 1] -> H matrisinin 2. sütunu
            error_vector = [0 1 0 0 0 0 0];
        case 7 % [1 1 1] -> H matrisinin 3. sütunu
            error_vector = [0 0 1 0 0 0 0];
        case 5 % [1 0 1] -> H matrisinin 4. sütunu
            error_vector = [0 0 0 1 0 0 0];
        case 4 % [1 0 0] -> H matrisinin 5. sütunu
            error_vector = [0 0 0 0 1 0 0];
        case 2 % [0 1 0] -> H matrisinin 6. sütunu
            error_vector = [0 0 0 0 0 1 0];
        case 1 % [0 0 1] -> H matrisinin 7. sütunu
            error_vector = [0 0 0 0 0 0 1];
    end
    
    % Hatayı modulo-2 ile düzeltiyoruz: corrected = rx_codeword XOR error_vector
    corrected_code = mod(rx_codeword + error_vector, 2);
    
    % Sistematik kod yapısında (G = [I_4 | P]) ilk 4 bit orijinal mesajdır
    msg_bits = corrected_code(1:4);
end