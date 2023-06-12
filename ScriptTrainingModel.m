%  ====== LOAD DOS OBJETOS ======

addpath("objects");

%  === CONFIGURAÇÕES DO MODELO ===

targetFolder = TrainingFolder.train1;
trainingType = TrainingType.MIX;

% Modelos de trein
arrayModelos = [
    TrainingModel( ...
        815, ... % identificador
        5, ... % num de camadas escondidas
        [100 100 75 75 75], ... % num neuronios
        {'tansig','tansig','tansig','tansig','tansig', 'softmax'}, ... % funcoes de ativacao
        'trainscg', ... % funcao de treino
        2000, ... % epochs
        'dividerand', ... % funcao de divisao
        {.70, .15, .15}, ... % divisao de valores
        { 'learngdm', 'learngdm','learngdm','learngdm','learngdm'}, ... % funcoes de aprendizagem
        0.05 ... % taxa de aprendizagem (0 = nao usa)
    )
];

% Num de vezes que vai repetir o modelo e para ajudar na média
totalExecutions = 30;

% Configuracao de tamanho da imagem (25x25), para ser usado no resize
% e convertido para um vetor binario na vertical
imageSize = 25;

% ===============================

% Path to the data folder
dataDir = fullfile('data', 'datasets', char(targetFolder));
disp("Loaded folder: " + dataDir);
categories = {};

% Definicao dos diretorios das imagens configurados
disp("Selected training type: " + char(trainingType));
if strcmp(char(trainingType), char(TrainingType.MIX))
    categories = {'0','1','2','3','4','5','6','7','8','9','add','sub','mul','div'};
elseif strcmp(char(trainingType), char(TrainingType.OP))
    categories = {'add','sub','mul','div'};
elseif strcmp(char(trainingType), char(TrainingType.NUM))
    categories = {'0','1','2','3','4','5','6','7','8','9'};
end

% Load das imagens
imds = imageDatastore(fullfile(dataDir, categories), 'LabelSource', 'foldernames');

% Total de ficheiros e categorias
numFiles = numel(imds.Files);
numCategories = numel(categories);

% Inicializacao de uma matriz de saida vazia com o tamanho das categorias e ficheiros a zero
outputMatrix = zeros(numCategories, numFiles);

% Preenche a matriz de saida com os valores i nas posicoes corretas
for i = 1:numFiles
    [~, target] = fileparts(fileparts(imds.Files{i}));
    targetIndex = find(strcmp(categories, target));
    outputMatrix(targetIndex, i) = 1;
end

% Inicializacao de uma matriz de entrada vazia com o tamanho das imagens e ficheiros a zero
inputBinaryImages = zeros(imageSize * imageSize, numFiles);

% Para cada ficheiro
for i = 1:numFiles
    % Ler o ficheiro
    fileDir = imds.Files{i};
    img = imread(fileDir);

    %converte a imagem para grayscale caso nao seja
    if ndims(img) == 3
        img = rgb2gray(img);
    end
    

    % Resize da imagem para o tamanho definido
    resizedImg = imresize(img, [imageSize imageSize]);

    % Converter a imagem para binario
    binaryImg = imbinarize(resizedImg);

    % Converter a imagem para um vetor binario em coluna
    binaryColumn = binaryImg(:);

    % Adicionar o vetor binario a matriz de entrada
    inputBinaryImages(:, i) = binaryColumn;
end

% Mostrar informação sobre os dados carregados
disp("Total number of columns (images) in the input matrix: " + size(inputBinaryImages, 2));
disp("Total number of lines (images) in the input: " + size(inputBinaryImages, 1));
disp("Total number of repetitions per model: " + totalExecutions);

% Cria um registo para guardar os resultados
resultsCell = {};

for i = 1:numel(arrayModelos)

    % Vetores temporários para armazenar os resultados das repetições
    accuracyValues = zeros(1, totalExecutions);
    accuracyTesteValues = zeros(1, totalExecutions);


    for repetition = 1:totalExecutions

        % Modelo Base para o treino
        trainingModel = arrayModelos(i);

        % Configuração e criação da rede
        net = feedforwardnet(trainingModel.numNeuronios);

        % Definir as funções de ativação para cada camada
        for j = 1:trainingModel.numCamadas - 1
            net.layers{j}.transferFcn = trainingModel.funcoesAtivacao{j};
        end

        % Define a função de treino e o número de epochs
        net.trainFcn = trainingModel.funcaoDeTreino;
        net.trainParam.epochs = trainingModel.epochs;

        % Define a função de divisão dos dados
        net.divideFcn = trainingModel.divisaoFuncao;

        % Define a divisão dos dados para treino, validação e teste
        net.divideParam.trainRatio = trainingModel.divisaoValores{1};
        net.divideParam.valRatio = trainingModel.divisaoValores{2};
        net.divideParam.testRatio = trainingModel.divisaoValores{3};

        % para permitir mais falhas de validação
        net.trainParam.max_fail = 75; 
        
        % define as funcoes de aprendizagem
        if ~isempty(trainingModel.funcoesAprendizagem)
            for j = 1:trainingModel.numCamadas
                disp("Defined learning function: " + trainingModel.funcoesAprendizagem{j} + " for hidden layer: " + j);
                net.layerWeights{j+1,j}.learnFcn = trainingModel.funcoesAprendizagem{j};
            end
        end

        % Se a taxa de aprendizado for maior que zero, defina a taxa de aprendizado
        if trainingModel.taxaAprendizagem > 0
            net.trainParam.lr = trainingModel.taxaAprendizagem;
            disp("Defined learning rate: " + trainingModel.taxaAprendizagem);
        end


        % Treina a rede neural, com os dados de entrada e saida
        [net, tr] = train(net, inputBinaryImages, outputMatrix);

        % Simula a rede  para o accuracy global
        out = sim(net, inputBinaryImages);

        % Calcular  o Accuracy da rede
        r = 0;
        for k=1:size(out,2)
            [a b] = max(out(:,k));
            [c d] = max(outputMatrix(:,k));
            if b == d
              r = r+1;
            end
        end

        accuracy = r/size(out,2)*100;

        % Pega nos dados de teste e simula a rede para o accuracy de teste
        Tintput = inputBinaryImages(:, tr.testInd);
        Ttargets = outputMatrix(:, tr.testInd);
        out = sim(net, Tintput);
        out = out>=0.5;
        r=0;
        for index=1:size(tr.testInd,2)                
          [a b] = max(out(:,index));           
          [c d] = max(Ttargets(:,index));   
          if b == d                       
              r = r+1;
          end
        end
        accuracyTeste = r/size(tr.testInd,2)*100; 

        accuracyValues(repetition) = accuracy;
        accuracyTesteValues(repetition) = accuracyTeste;

        % Gravar o modelo
        filename = ['model','_' ,num2str(trainingModel.id),'_' , num2str(fix(accuracy)), '_', num2str(fix(accuracyTeste)), '.mat'];
        folder = fullfile('models');

        % Verificar se o diretório de destino existe
        if ~isfolder(folder)
            mkdir(folder);
        end

        modelFileDir = fullfile('models',filename);
        save(modelFileDir, 'net');

        resultsCell(end+1, :) = {filename, trainingModel.numCamadas, mat2str(trainingModel.numNeuronios), strjoin(trainingModel.funcoesAtivacao, ' '), trainingModel.funcaoDeTreino, trainingModel.epochs, trainingModel.divisaoFuncao, trainingModel.divisaoValores{1}, trainingModel.divisaoValores{2}, trainingModel.divisaoValores{3}, accuracy, accuracyTeste, strjoin(trainingModel.funcoesAprendizagem, ' '), trainingModel.taxaAprendizagem};
    end

    % Calcula a média dos valores de accuracy e accuracyTeste
    accuracy = mean(accuracyValues);
    accuracyTeste = mean(accuracyTesteValues);
    mediaText = ['Média de ID: ' num2str(trainingModel.id)];

    resultsCell(end+1, :) = {mediaText, trainingModel.numCamadas, mat2str(trainingModel.numNeuronios), strjoin(trainingModel.funcoesAtivacao, ' '), trainingModel.funcaoDeTreino, trainingModel.epochs, trainingModel.divisaoFuncao, trainingModel.divisaoValores{1}, trainingModel.divisaoValores{2}, trainingModel.divisaoValores{3}, accuracy, accuracyTeste, strjoin(trainingModel.funcoesAprendizagem, ' '), trainingModel.taxaAprendizagem};

end

resultsFolder = fullfile('results');
% Verificar se o diretório de destino existe
if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end

% Guarda a tabela como um arquivo CSV
results = cell2table(resultsCell, 'VariableNames', {'FileName' 'NumberLayers', 'NumberNeurons', 'ActivationFunctions', 'TrainingFunction', 'Epochs', 'Division', 'TrainRatio', 'ValRatio', 'TestRatio', 'Accuracy' , 'TestAccuracy', 'Learning Functions', 'Learning Rate'});

% adicionar no nome do ficheiro o id do modelo
filename = fullfile('results', [ num2str(arrayModelos(i).id) '_'  datestr(now, 'yyyymmddHHMM') '_results.csv']);
writetable(results, filename, 'Delimiter', ';', 'WriteMode', 'append');

disp(results);
