function plotarGraficosJuntos(tabelaDados, repeticao)
figure;
sgtitle('Gráficos dos Áudios Processados'); 
numeroAudios = 1+repeticao:50:500; % Digits from 0 to 9

for i = 1:10
    indice = numeroAudios(i) 
    audio = tabelaDados(indice, :);
    sinal = audio.sinal{1};
    taxaAmostragem = audio.taxaAmostragem;
    
    duracao = (0:length(sinal)-1) / taxaAmostragem; 
    
    subplot(5, 2, i); 
    plot(duracao, sinal);
    xlabel('Tempo [s]');
    ylabel('Amplitude');
    title(['Dígito ', num2str(i-1), ' ; Repetição ', num2str(repeticao)]);
    grid on;
end
end

