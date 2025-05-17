%META 1

% 1. e 2. Criação da estrutura de dados e importação dos sinais de áudio
% ---------------------------------------------------------------
% Cria uma estrutura para armazenar informações de cada áudio: diretório, nome, participante, dígito, repetição, sinal e taxa de amostragem.
% O loop extrai essas informações de cada ficheiro .wav e armazena na estrutura 'dados'.
% ---------------------------------------------------------------
%addpath('functions');

pastaAudios = 'audios';  
audios = dir(fullfile(pastaAudios, '*.wav'));

numeroAudios = length(audios);

%Estrutura de dados que armazena todas as informacoes relevantes dos 500 audios.
dados = struct();
           
%Extração das informações presentes nos ficheiros de audio.           
for i = 1:numeroAudios                                   
    nomeFicheiro = audios(i).name;
    diretorio = fullfile(pastaAudios, nomeFicheiro);
    
    partesNome = split(nomeFicheiro, '_'); 
    
    digito = str2double(partesNome{1});      
    participante = partesNome{2};  
    
    partesRepeticao = split(partesNome{3}, '.');  
    repeticao = str2double(partesRepeticao{1});
    
    [sinal, taxaAmostragem] = audioread(diretorio);

    dados(i).('diretorio') = diretorio;
    dados(i).('nomeFicheiro') = nomeFicheiro;
    dados(i).('participante') = participante;
    dados(i).('digito') = digito;
    dados(i).('repeticao') = repeticao;
    dados(i).('sinal') = sinal;
    dados(i).('taxaAmostragem') = taxaAmostragem;
end

%Apenas para ser apresentavel.
tabela = struct2table(dados); 
tabela = sortrows(tabela, ["digito" "repeticao"]);
disp(tabela);

% 3. Reproduzir e representar graficamente um exemplo dos sinais importados
% ---------------------------------------------------------------
% Seleciona um áudio e plota o seu gráfico, identificando o dígito e repetição.
% O eixo horizontal representa o tempo em segundos.
% ---------------------------------------------------------------
i = 500; %i = input('Linha: '); 
audio = dados(i);
plotarGrafico(audio);

% 4. e 5. Pré-processamento dos sinais
% ---------------------------------------------------------------
% Remove silêncio inicial (usando energia do sinal), normaliza a amplitude e ajusta a duração dos áudios.
% Garante que todos os sinais têm início, amplitude e duração padronizados para melhor comparação.
% ---------------------------------------------------------------
duracao = 0.8 %Duracao desejada
limiteEnergia = 0.001; %Valor de energia minima utilizado para detetar quando o ator começa a falar.

for i = 1:numeroAudios
    sinal = dados(i).sinal;
    tamanhoAudio = duracao * dados(i).taxaAmostragem;
    
    % Remover silêncio no início.
    energia = movsum(abs(sinal).^2, 1000); %1000 em 1000 amostras                       
    indiceInicio = find(energia > limiteEnergia, 1, 'first');
    sinal = sinal(indiceInicio:end);  

    % Normalizar a amplitude do sinal.
    sinal = (sinal - mean(sinal)) / std(sinal);                                   

    % Colocar a mesma duração para todos os audios.
    if length(sinal) < tamanhoAudio                               
        sinal = [sinal; zeros(tamanhoAudio - length(sinal), 1)];
    else
        sinal = sinal(1:tamanhoAudio);
    end

    dados(i).sinal = sinal;
end

% Apresentar audio após processamento.
% Repete o ponto 3 para um áudio já pré-processado.
i = 40; %i = input('Linha: '); 
audio = dados(i);
plotarGrafico(audio);

% 6. Comparação visual dos gráficos antes e depois do pré-processamento
% ---------------------------------------------------------------
% Observa diferenças visuais entre os sinais dos dígitos, como amplitude, duração e posição temporal.
% Plota todos os dígitos para facilitar a comparação visual.
% ---------------------------------------------------------------
repeticao=0; %repeticao = input('Repeticao: ');
plotarGraficosJuntos(dados,repeticao);

% 7. Extração de características temporais
% ---------------------------------------------------------------
% Calcula e armazena na estrutura cinco características temporais: taxa de cruzamento de zero, energia total, momento da amplitude máxima, razão de amplitude e desvio padrão.
% Estas características ajudam a diferenciar os dígitos com base no sinal no tempo.
% ---------------------------------------------------------------
for i = 1:numeroAudios
    sinal = dados(i).sinal;  
     
    dados(i).('taxaCruzamentoZeros') = sum(abs(diff(sign(sinal)))) / (2*length(sinal)); % 2 vezes o diff conta positivo para o negativo e vice-versa.
    dados(i).('energiaTotal') = sum(abs(sinal).^2); 
    dados(i).tAmplitudeMaxima = find(sinal == max(sinal), 1, 'first') / dados(i).taxaAmostragem;
    dados(i).('razaoAmplitude') = abs(max(sinal))/abs(min(sinal));
    dados(i).('desvioPadrao') = std(sinal);
end

% Apenas para ser apresentavel.
% Exibe a tabela com as novas características.
tabela = struct2table(dados);
tabela = sortrows(tabela, ["digito" "repeticao"]);
disp(tabela);

% 8. Representação gráfica das características temporais
% ---------------------------------------------------------------
% Utiliza boxplots e gráficos 3D para visualizar a distribuição das características temporais por dígito.
% Permite identificar quais características melhor discriminam os dígitos.
% ---------------------------------------------------------------
% Inicializar as caracteristicas a cruzar...
sinais = [dados.sinal];
valores1 = [dados.razaoAmplitude];
valores2 = [dados.energiaTotal];
valores3 = [dados.taxaCruzamentoZeros];
digitos = [dados.digito];

figure;
scatter3(valores1, valores2, valores3, 20, digitos, 'filled');  
xlabel('Momento da Amplitude Maxima');
ylabel('Energia Total');
zlabel('Zero Crossing Rate');
grid on;
title('Distribuição das Características do Áudio');

colormap(jet(10));  
caxis([0 9])
cor = colorbar;
cor.Ticks = 0:9;  
cor.TickLabels = {'0','1','2','3','4','5','6','7','8','9'};
boxplot(valores1,digitos);
xlabel('Digitos');
ylabel('Razão da Amplitude');
title('Distribuição da Razão da Amplitude');
boxplot(valores2,digitos);
xlabel('Digitos');
ylabel('Energia Total');
title('Distribuição da Energia Total');
boxplot(valores3,digitos);
xlabel('Digitos');
ylabel('Zero Crossing Rate');
title('Distribuição do Zero Crossing Rate');
boxplot([dados.tAmplitudeMaxima],digitos);
xlabel('Digitos');
ylabel('Momento da Amplitude Maxima');
title('Distribuição do Momento da Amplitude Maxima');

% 9. Remoção dos sinais de áudio da estrutura e salvamento em ficheiro .mat
% ---------------------------------------------------------------
% Remove os sinais de áudio da estrutura (para economizar espaço) e salva a estrutura em 'dados.mat'.
% ---------------------------------------------------------------
save('dados.mat',"dados")

META 2

% 10. Carregamento da estrutura de dados
% ---------------------------------------------------------------
% Carrega a estrutura de dados salva anteriormente para continuar o processamento.
% ---------------------------------------------------------------
dados = load("dados.mat").dados;

tabela = struct2table(dados); 
disp(tabela);

% 11. Cálculo dos coeficientes de Fourier
% ---------------------------------------------------------------
% Calcula a FFT (coeficientes de Fourier) de cada sinal e armazena na estrutura.
% Utiliza zero-padding para melhor resolução espectral.
% ---------------------------------------------------------------
for i = 1:length(dados)
    sinal = dados(i).sinal;
    tamanhoSinal = length(sinal);
    
    % Zero-padding na FFT para melhor resolução de frequência
    tamanhoPadding = 2^nextpow2(tamanhoSinal); 

    % Calculo da transformada com padding e com normalização 
    coeficientesFourier = fft(sinal, tamanhoPadding) / tamanhoSinal;
    
    % Calculo sem padding com e normalização
    %coeficientesFourier = fft(sinal) / tamanhoSinal;

    dados(i).coeficientesFourier = coeficientesFourier;
end

% 12. Cálculo do espectro de amplitude mediano e quartis
% ---------------------------------------------------------------
% Para cada dígito, calcula o espectro de amplitude mediano, 1º e 3º quartis, considerando apenas frequências positivas.
% Plota os resultados para comparação entre dígitos.
% ---------------------------------------------------------------
taxaAmostragem=48000;

for digito = 0:9
    indices = find([dados.digito] == digito);
    espectro= [];

    for i = indices
        coeficientesFourier = dados(i).coeficientesFourier;

        % Extrair apenas as frequências positivas (0 Hz até TaxaAmostragem/2)
        magnitudes = abs(coeficientesFourier(1:length(coeficientesFourier)/2));

        espectro = [espectro; magnitudes(:)'];
    end

    % Cálculo das estatísticas (Mediana, 1º quartil, 3º quartil)
    mediana = median(espectro, 1);
    q1 = quantile(espectro, 0.25, 1);
    q3 = quantile(espectro, 0.75, 1);

    % Criar vetor de frequências (todas as amostras têm o mesmo vetor)
    frequencias = linspace(0, taxaAmostragem / 2, length(magnitudes));

    % Plotar espectro do dígito
    figure();
    plot(frequencias, mediana, 'b'); hold on;
    plot(frequencias, q1, 'r');
    plot(frequencias, q3, 'g');
    title(digito);
    xlabel('Frequência');
    ylabel('Magnitude');
    legend('Mediana', 'Q1', 'Q3');
    xlim([0 1000]);
    set(gcf, 'Position', [100, 100, 1200, 500]);
    grid on;
end

% 13. Extração de características espectrais
% ---------------------------------------------------------------
% Calcula e armazena cinco características espectrais: frequência dominante, PAR, entropia espectral, SEF e inclinação espectral.
% Estas características ajudam a diferenciar os dígitos no domínio da frequência.
% ---------------------------------------------------------------
for i = 1:length(dados)
    taxaAmostragem = dados(i).taxaAmostragem;
    coeficientesFourier = dados(i).coeficientesFourier;

    % Apenas as frequências positivas
    magnitudes = abs(coeficientesFourier(1:length(coeficientesFourier)/2));
    frequencias = linspace(0, taxaAmostragem/2, length(magnitudes));
    
    % Frequência Dominante
    indiceMaximo = find(magnitudes == max(magnitudes), 1, 'first');
    frequenciaDominante = frequencias(indiceMaximo);
    dados(i).frequenciaDominante = frequenciaDominante;
    
    % Peak to Average Ratio (PAR)
    par = max(magnitudes) / mean(magnitudes);
    dados(i).par = par;
    
    % Entropia Espectral
    espectroNormalizado = magnitudes / sum(magnitudes);  
    entropia = -sum(espectroNormalizado .* log(espectroNormalizado)); 
    dados(i).entropia = entropia;

    % Spectral Edge Frequency (SEF 90%)
    energiaTotal = sum(magnitudes.^2);
    energiaAcumulada = cumsum(magnitudes.^2);
    sef = interp1(energiaAcumulada, frequencias, 0.90 * energiaTotal, 'linear', 'extrap');
    dados(i).sef = sef;

    % Spectral Slope 
    X = [ones(length(frequencias), 1), frequencias(:)]; % Matriz de regressão
    Y = magnitudes(:);
    coef = (X' * X) \ (X' * Y); % Regressão linear
    spectralSlope = coef(2); % Coeficiente angular da reta ajustada
    dados(i).spectralSlope = spectralSlope;
end

% 14. Representação gráfica das características espectrais
% ---------------------------------------------------------------
% Utiliza boxplots e gráficos 3D para visualizar a distribuição das características espectrais por dígito.
% Permite identificar quais características melhor discriminam os dígitos.
% ---------------------------------------------------------------
% Inicializar as caracteristicas a cruzar...
sinais = [dados.sinal];
valores1 = [dados.par];
valores2 = [dados.entropia];
valores3 = [dados.spectralSlope];
digitos = [dados.digito];

figure;
scatter3(valores1, valores2, valores3, 20, digitos, 'filled');  
xlabel('Par'); 
ylabel('Entropia'); 
zlabel('Spectral Slope');
grid on;
title('Distribuição das Características Espectrais');

colormap(jet(10));  
caxis([0 9]); 
cor = colorbar;
cor.Ticks = 0:9;  
cor.TickLabels = {'0','1','2','3','4','5','6','7','8','9'};
boxplot(valores1,digitos);
xlabel('Digitos');
ylabel('Peak to Average Ratio');
title('Distribuição do Peak to Average Ratio');

boxplot(valores2, digitos);
xlabel('Digitos');
ylabel('Entropia');
title('Distribuição da Entropia');

boxplot(valores3, digitos);
xlabel('Digitos');
ylabel('Spectral Slope');
title('Distribuição do Spectral Slope');

% 15. Atualização do ficheiro .mat com as novas características
% ---------------------------------------------------------------
save('dados.mat',"dados")

META 3

% 16. Carregamento da estrutura de dados
% ---------------------------------------------------------------
% Carrega a estrutura de dados salva anteriormente para continuar o processamento.
% ---------------------------------------------------------------
dados = load("dados.mat").dados;

% 17. Aplicação de um classificador para a identificação automatizada dos dígitos
% ---------------------------------------------------------------
% Utiliza um modelo à sua escolha (Minimum Distance ou um sistema de regras if/else)
% utilizando como features as características extraídas dos sinais no tempo e frequência.
% Guarda o resultado da classificação na estrutura de dados.
% ---------------------------------------------------------------
features = [dados.energiaTotal; dados.taxaCruzamentoZeros; dados.razaoAmplitude; dados.desvioPadrao;
            dados.par; dados.entropia; dados.spectralSlope; dados.sef]';

digitoReal = [dados.digito]';

featuresTreino = [];
digitoRealTreino = [];
featuresTeste = [];
digitoRealTeste = [];

for digito = 0:9
    indices = find(digitoReal == digito);
    
    tamanhoTotal = length(indices);
    tamanhoTreino = 0.7 * tamanhoTotal;
    
    indicesTreino = indices(1:tamanhoTreino);
    indicesTeste = indices(tamanhoTreino+1:end);
    
    featuresTreino = [featuresTreino; features(indicesTreino, :)];
    digitoRealTreino = [digitoRealTreino; digitoReal(indicesTreino)];
    featuresTeste = [featuresTeste; features(indicesTeste, :)];
    digitoRealTeste = [digitoRealTeste; digitoReal(indicesTeste)];
end

centroides = zeros(10, size(features,2));
for digito = 0:9
    indices = find(digitoRealTreino == digito);
    centroides(digito + 1, :) = mean(featuresTreino(indices, :), 1);
end

digitoPrevisto = zeros(length(featuresTeste), 1);
for i = 1:length(featuresTeste)
    distancias = sqrt(sum((centroides - featuresTeste(i, :)).^2, 2));
    [~, digitoPrevisto(i)] = min(distancias);
end

% Indice 1 corresponde ao dígito 0
digitoPrevisto = digitoPrevisto - 1;

% 18. Comparação dos dígitos atribuídos com os dígitos reais
% ---------------------------------------------------------------
% Calcula a percentagem de acertos e comenta os resultados.
% ---------------------------------------------------------------
percentagemAcerto = sum(digitoPrevisto == digitoRealTeste) / length(digitoRealTeste) * 100;
fprintf('Percentagem de acerto: %.2f%%\n', percentagemAcerto);

% 19. Comparação de três tipos de janela diferentes
% ---------------------------------------------------------------
% Aplica diferentes janelas em intervalos de tempo e comenta os resultados.
% Escreve no relatorio spectral leakage
% ---------------------------------------------------------------
janelas = struct;
tamanho = length(dados(1).sinal);
janelas.hamming = window(@hamming, tamanho);
janelas.kaiser = window(@kaiser, tamanho, 5);
janelas.blackman = window(@blackman, tamanho);
nomes = fieldnames(janelas);

taxaAmostragem = dados(1).taxaAmostragem;  
espectros= struct();

for j = 1:length(nomes)
    nomeJanela = nomes{j};
    janela = janelas.(nomeJanela); 

    for digito = 0:9
        indices = find([dados.digito] == digito);
        espectro = [];

        for i = indices
            sinal = dados(i).sinal;
            sinalJanela = sinal .* janela;
            coeficientesFourier = fft(sinalJanela) / tamanho;

            magnitudes = abs(coeficientesFourier(1:length(coeficientesFourier)/2));
            espectro = [espectro; magnitudes(:)'];
        end

        espectros(digito+1).(nomeJanela)=espectro;

    end
end

digito = 4;

for j = 1:length(nomes)
    nomeJanela = nomes{j};

    espectro = espectros(digito + 1).(nomeJanela);  

    mediana = median(espectro, 1);
    q1 = quantile(espectro, 0.25, 1);
    q3 = quantile(espectro, 0.75, 1);

    frequencias = linspace(0, taxaAmostragem / 2, size(espectro, 2));

    figure;
    plot(frequencias, mediana, 'b'); 
    hold on;
    plot(frequencias, q1, 'r');
    plot(frequencias, q3, 'g');
    title(['Dígito ', num2str(digito), ' - Janela ', nomeJanela]);
    xlabel('Frequência (Hz)');
    ylabel('Magnitude');
    legend('Mediana', 'Q1', 'Q3');
    xlim([0 1000]);
    set(gcf, 'Position', [100, 100, 1200, 500]);
    grid on;
end

% 20. Atualização do ficheiro .mat com as novas características
% ---------------------------------------------------------------
save('dados.mat', 'dados');

META 4

% 21. Carregamento da estrutura de dados
% ---------------------------------------------------------------
% Carrega a estrutura de dados salva anteriormente para continuar o processamento.
% ---------------------------------------------------------------
dados = load("dados.mat").dados;

tabela = struct2table(dados); 
disp(tabela);

% 22. Cálculo da STFT para uma repetição de cada dígito (apenas até ao fim do áudio real)
% ---------------------------------------------------------------
% Gera apenas um gráfico de espectrograma para cada dígito, usando uma repetição fixa (ex: repetição 1)
% e uma combinação de parâmetros (tj=512, ov=0.5, nfft=512),
% mostrando apenas até ao fim do áudio real (sem zona de zeros).
% ---------------------------------------------------------------
taxaAmostragem = 48000
tamanhoJanela = 512; 
overlap = 0.5; 
numFFT = 512;
repeticao = 1; 

for digito = 0:9
    indice = find([dados.digito] == digito & [dados.repeticao] == repeticao, 1, 'first');
    sinal = dados(indice).sinal;
    numOverlap = round(tamanhoJanela * overlap);
    figure;
    spectrogram(sinal, tamanhoJanela, numOverlap, numFFT, taxaAmostragem, 'yaxis');
    xlabel('Tempo (ms)');
    ylabel('Frequência (Hz)');
    title(['Dígito ', num2str(digito), ' | Repetição ', num2str(repeticao), ...
        ' | Janela: ', num2str(tamanhoJanela), ' | Overlap: ', num2str(overlap*100), '% | NFFT: ', num2str(numFFT)]);
end

% 23. Extração de características de tempo-frequência (corrigido e comentado)
% ---------------------------------------------------------------
% Calcula e armazena pelo menos 5 características de tempo-frequência para cada áudio.
% ---------------------------------------------------------------
for i = 1:length(dados)
    sinal = dados(i).sinal;
    [s,f,t,p] = spectrogram(sinal, tamanhoJanela, numOverlap, numFFT, taxaAmostragem);
    p = abs(p).^2;
    meanP = mean(p,2); % Média da potência por frequência
    % 1. Frequência média (weighted mean)
    dados(i).specMeanFreq = sum(f .* meanP) / sum(meanP);
    % 2. Frequência máxima (frequência com maior energia média)
    [~, idxMax] = max(meanP);
    dados(i).specMaxFreq = f(idxMax);
    % 3. Largura de banda (desvio padrão da distribuição de energia)
    dados(i).specBandwidth = sqrt(sum(((f - dados(i).specMeanFreq).^2) .* meanP) / sum(meanP));
    % 4. Entropia espectral
    p_norm = meanP / sum(meanP);
    dados(i).specEntropy = -sum(p_norm .* log(p_norm + eps));
    % 5. Energia total
    dados(i).specEnergy = sum(p(:));
end

% 24. Representação gráfica das características tempo-frequência
% ---------------------------------------------------------------
% Utiliza boxplots para visualizar a distribuição das características tempo-frequência por dígito.
% ---------------------------------------------------------------
digitos = [dados.digito]';
features = [[dados.specMeanFreq]', [dados.specMaxFreq]', [dados.specBandwidth]', ...
            [dados.specEntropy]', [dados.specEnergy]'];

feature_names = {'Frequência Média', 'Frequência Máxima', ...
                 'Largura de Banda', 'Entropia Espectral', 'Energia'};

for i = 1:5
    figure;
    boxplot(features(:,i), digitos);
    title(feature_names{i});
    xlabel('Dígito');
end

% 25. Aplicação da DWT
% ---------------------------------------------------------------
% Aplica a Transformada de Wavelet Discreta (DWT) para obter os coeficientes de detalhe e de aproximação.
% Obter os valores de energia a partir dos coeficientes e representar os resultados, utilizando gráficos semelhantes aos exemplificados na Figura 3.
% Compare e discuta os resultados obtidos com a STFT e com a DWT.
% ---------------------------------------------------------------


% 26. Atualização do ficheiro .mat com as novas características
% ---------------------------------------------------------------
save('dados.mat', 'dados');
