function codeword = hamming_encode(msg_bits)

    if iscolumn(msg_bits)
        msg_bits = msg_bits';
    end

    G = [1 0 0 0 1 1 0;
         0 1 0 0 0 1 1;
         0 0 1 0 1 1 1;
         0 0 0 1 1 0 1];

    codeword = mod(msg_bits * G, 2);
end