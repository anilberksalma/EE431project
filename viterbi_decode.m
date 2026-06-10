function msg_bits = viterbi_decode(rx_bits)

    if iscolumn(rx_bits)
        rx_bits = rx_bits';
    end

    % K=4 için toplam durum (state) sayısı: 2^(K-1) = 8 durum (0'dan 7'ye)
    num_states = 8;
    num_steps = length(rx_bits) / 2; % Rate 1/2 olduğu için her adımda 2 bit incelenir

    % Trellis (Kafes) Yapısı Matrisleri
    % next_state(current_state + 1, input + 1)
    % outputs(current_state + 1, input + 1, :) = [c1, c2]
    next_state = zeros(num_states, 2);
    outputs = zeros(num_states, 2, 2);

    % Tüm olası durumlar (0-7) için geçiş tablolarını önceden hesaplıyoruz (Pre-computation)
    for s = 0:num_states-1
        % Durumun bit bileşenlerini çıkarıyoruz: s = [m1, m2, m3]
        m1 = bitand(bitshift(s, -2), 1);
        m2 = bitand(bitshift(s, -1), 1);
        m3 = bitand(s, 1);

        for input_bit = 0:1
            % g1 = [1 1 1 1] (octal 17) ve g2 = [1 0 1 1] (octal 13) polinomları
            c1 = mod(input_bit + m1 + m2 + m3, 2);
            c2 = mod(input_bit + m2 + m3, 2);

            % Yeni durum: girdi başa gelir, eski bitler sağa kayar -> [input, m1, m2]
            ns = input_bit*4 + m1*2 + m2;

            % MATLAB 1-tabanlı indeksleme kullandığı için +1 ekliyoruz
            next_state(s+1, input_bit+1) = ns;
            outputs(s+1, input_bit+1, :) = [c1, c2];
        end
    end

    % --- Branch Metric (Dal Uzaklığı) Hesaplama Şablonu ---
    % Bu kısım her zaman dilimi (t) için gelen ikili semboller ile  trellis üzerindeki olası çıkışlar arasındaki Hamming mesafesini hesaplar.    
    % NOT: Path Metric güncellemeleri, ACS (Add-Compare-Select) mekanizması ve nihai Traceback (Geriye doğru izleme) adımları Commit 6'da tamamlanacaktır.
    
    msg_bits = []; % Geçici boş çıkış (Geliştirme aşaması göstergesi)
end