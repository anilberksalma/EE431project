clear; clc;

% main_bsc_simulation.m simülasyonundan elde edilen ortalama değerler
channel_bers = [0.001, 0.01, 0.05, 0.10, 0.15];

hamming_ber = [0.00000, 0.01042, 0.08333, 0.18750, 0.26042];
viterbi_ber = [0.00000, 0.00000, 0.02083, 0.10417, 0.19792];

figure('Color', [1 1 1]);
semilogy(channel_bers, channel_bers, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Uncoded (Theoretical)');
hold on;
semilogy(channel_bers, hamming_ber, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'DisplayName', 'Hamming (7,4)');
semilogy(channel_bers, viterbi_ber, 'r-s', 'LineWidth', 2, 'MarkerFaceColor', 'r', 'DisplayName', 'Convolutional (Viterbi K=4, R=1/2)');

grid on;
ax = gca;
ax.GridLineStyle = ':';
ax.GridAlpha = 0.6;

title('BER Performance Comparison over Binary Symmetric Channel', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Channel Error Probability (p)', 'FontSize', 11);
ylabel('Bit Error Rate (BER)', 'FontSize', 11);
legend('Location', 'best', 'FontSize', 10);

% Grafiği yüksek çözünürlüklü imaj olarak kaydetme
saveas(gcf, 'bsc_performance_curves.png');
fprintf('Performance graph has been successfully plotted and saved as "bsc_performance_curves.png"!\n');