function plotarGraficosJuntos(dados, repeticao)
    figure()
    sgtitle('Gráficos dos Áudios Processados');
    
    tiledlayout(5, 2, 'Padding', 'compact', 'TileSpacing', 'compact'); % Melhor espaçamento
    set(gcf, 'Position', [100, 100, 900, 700]) %Maior tamanho

    for i = 1:10
        indices = find([dados.repeticao] == repeticao & [dados.digito] == (i-1));
        indice = indices(1); 
        
        audio = dados(indice);
        sinal = audio.sinal;
        taxaAmostragem = audio.taxaAmostragem;

        duracao = (0:length(sinal)-1) / taxaAmostragem; 
        
        nexttile;
        plot(duracao, sinal);
        ylim([-5 5]);
        xlabel('Tempo [s]');
        ylabel('Amplitude');
        title(['Dígito ', num2str(i-1), ' ; Repetição ', num2str(repeticao)]);
        grid on;
    end
end
