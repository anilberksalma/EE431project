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
  
    % --- Path Metrics (Yol Uzaklıkları) İlklendirme ---
    % Kodlayıcı sıfır durumundan başladığı için State 0 = 0, diğerleri sonsuz (inf)
    path_metrics = inf(1, num_states);
    path_metrics(1) = 0;

    % Geriye doğru izleme (Traceback) için hayatta kalan yolları saklama matrisleri
    survivor_state = zeros(num_states, num_steps);
    survivor_input = zeros(num_states, num_steps);

    % --- Add-Compare-Select (ACS) Döngüsü ---
    for t = 1:num_steps
        rx_pair = rx_bits(2*t-1 : 2*t); % Kanalardan gelen 2 bitlik sembol
        new_path_metrics = inf(1, num_states);
        
        temp_surv_state = zeros(1, num_states);
        temp_surv_input = zeros(1, num_states);

        for s = 0:num_states-1
            if isinf(path_metrics(s+1))
                continue; % Ulaşılamayan durumları geç
            end
            
            for input_bit = 0:1
                ns = next_state(s+1, input_bit+1);
                out_bits = squeeze(outputs(s+1, input_bit+1, :))';
                
                % Hard-Decision Branch Metric: Hamming Mesafesi hesaplama
                branch_metric = sum(rx_pair ~= out_bits);
                
                % ADD (Ekle)
                candidate_metric = path_metrics(s+1) + branch_metric;
                
                % COMPARE & SELECT (Karşılaştır ve Seç)
                if candidate_metric < new_path_metrics(ns+1)
                    new_path_metrics(ns+1) = candidate_metric;
                    temp_surv_state(ns+1) = s;          % Gelinen önceki durum
                    temp_surv_input(ns+1) = input_bit;  % Bu geçişe sebep olan girdi biti
                end
            end
        end
        % Metrikleri ve yolları güncelle
        path_metrics = new_path_metrics;
        survivor_state(:, t) = temp_surv_state';
        survivor_input(:, t) = temp_surv_input';
    end

    % --- Traceback (Geriye Doğru İzleme) Algoritması ---
    % State Termination sayesinde kodlayıcının kesinlikle State 0'da bittiğini biliyoruz
    curr_state = 0; 
    estimated_inputs = zeros(1, num_steps);

    % Sondan başa doğru kafes üzerinde yürüyoruz
    for t = num_steps:-1:1
        estimated_inputs(t) = survivor_input(curr_state+1, t);
        curr_state = survivor_state(curr_state+1, t);
    end

    % Kodlayıcı kapatılırken eklenen K-1 (3 adet) kuyruk sıfırını atarak orijinal mesajı elde ediyoruz
    msg_bits = estimated_inputs(1 : end-3);
end