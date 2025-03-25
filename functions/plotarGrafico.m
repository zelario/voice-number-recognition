function plotarGrafico(audio)
    %Plota o gráfico de um sinal de áudio no domínio do tempo.

    digito = audio.digito;
    repeticao = audio.repeticao;
    sinal = audio.sinal; 
    taxaAmostragem = audio.taxaAmostragem;
    
    %Duracao = tamanhoDoVetorDeAmplitudes / taxaDeAmostragem
    duracao = (0:length(sinal)-1) / taxaAmostragem; 
    
    figure;
    plot(duracao, sinal);
    xlabel('Tempo (segundos)');
    ylabel('Amplitude');
    grid on;
    title(['Dígito: ', num2str(digito), ' ; Repetição: ', num2str(repeticao)]);
end
