function encoded_bits = conv_encode(msg_bits)

    if iscolumn(msg_bits)
        msg_bits = msg_bits';
    end

    % State Termination: Mesajın arkasına K-1 (3 adet) kuyruk sıfırı ekliyoruz
    terminated_bits = [msg_bits, 0, 0, 0];
    num_bits = length(terminated_bits);
    
    % Çıkış dizisini yeni uzunluğa göre (Mesaj + 3 bit) * 2 olacak şekilde önceden tanımlıyoruz
    encoded_bits = zeros(1, 2 * num_bits);

    % K=4 için 3 adet hafıza elemanı (shift register), başlangıçta hepsi sıfır
    shift_register = [0, 0, 0]; % [m1, m2, m3]

    % Kuyruk bitleri dahil tüm dizi üzerinden geçiş yapıyoruz
    for t = 1:num_bits
        current_bit = terminated_bits(t);

        % g1 = [1 1 1 1] (octal 17) -> c1 = current_bit + m1 + m2 + m3
        c1 = mod(current_bit + shift_register(1) + shift_register(2) + shift_register(3), 2);
        
        % g2 = [1 0 1 1] (octal 13) -> c2 = current_bit + m2 + m3
        c2 = mod(current_bit + shift_register(2) + shift_register(3), 2);

        % Çıkış ikililerini (c1, c2) ardışık olarak yerleştirme
        encoded_bits(2*t - 1) = c1;
        encoded_bits(2*t)     = c2;

        % Shift register kaydırma (yeni bit en başa gelir)
        shift_register = [current_bit, shift_register(1), shift_register(2)];
    end
end