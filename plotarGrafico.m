function plotarGrafico(audio)
    digito = audio.digito;
    repeticao = audio.repeticao;
    sinal = audio.sinal{1}; 
    taxaAmostragem = audio.taxaAmostragem;
    
    duracao = (0:length(sinal)-1) / taxaAmostragem;
    
    figure;
    plot(duracao, sinal);
    xlabel('Tempo (segundos)');
    ylabel('Amplitude');
    grid on;
    title(['Dígito: ', num2str(digito), ' ; Repetição: ', num2str(repeticao)]);
end
