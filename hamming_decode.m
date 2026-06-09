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
    
    % Geçici olarak çıkışı sıfır atama (Commit 3'te hata düzeltmeyle tamamlanacak)
    msg_bits = zeros(1, 4);
end