clear; clc;

personal_str = 'ECC2026-S06F'; 

fprintf('==================================================\n');
fprintf('        EE431 PART 3 - PERSONAL MESSAGE          \n');
fprintf('==================================================\n');
fprintf('Original String: %s (%d characters)\n', personal_str, length(personal_str));

% Her karakteri 8-bit ikilik sisteme (MSB ilk gelecek şekilde) çeviriyoruz
binary_matrix = dec2bin(personal_str, 8) - '0'; 

% Matrisi tek bir satırda 96 bitlik dizi haline getiriyoruz
msg_bits = reshape(binary_matrix', 1, []);

fprintf('\nResulting 96-bit string:\n\n');
for k = 1:length(msg_bits)
    fprintf('%d', msg_bits(k));
    if mod(k, 8) == 0 && k < length(msg_bits)
        fprintf(' '); % Her karakter sonrası boşluk bırak (okunabilirlik için)
    end
end
fprintf('\n\nTotal bits generated: %d bits\n', length(msg_bits));