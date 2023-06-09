clc
% Carregar o arquivo contendo a definição da classe ModeloTreino
addpath("models");


%  === CONFIGURAÇÕES INICIAIS ===

% Escolher a pasta
%dirImg = 'start';
dirImg = 'train1';
%dirImg = 'custom';

tipoTreino = 'mix'; % numeros e operadoes
%tipoTreino = 'op'; % só operadores
%tipoTreino = 'mun'; % só numeros

% Casos de Teste
% ModeloTreino
arrayModelos = [];

% O número e dimensão das camadas encondidas influencia o desempenho?
arrayModelos = [arrayModelos, ModeloTreino(0, 1, [10], {'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(1, 2, [5 5], {'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(2, 2, [10 1], {'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(3, 2, [1 10], {'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(4, 2, [10 10], {'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% arrayModelos = [arrayModelos, ModeloTreino(5, 2, [20 20], {'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(6, 3, [5 5 5], {'tansig', 'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(7, 3, [10 1 1], {'tansig', 'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(8, 3, c[1 10 1], {'tansig', 'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(9, 3, [10 10 10], {'tansig', 'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
% feito - arrayModelos = [arrayModelos, ModeloTreino(10, 3, [10 5 10], {'tansig', 'tansig', 'tansig', 'pureline'}, 'trainlm', 1000, 'dividerand', {.70, .15, .15})];
 
%A função de treino influencia o desempenho?
%arrayModelos = [arrayModelos, ModeloTreino(2, 2, [10 1], {'tansig', 'tansig', 'pureline'}, 'traingd', 1000, 'dividerand', {.70, .15, .15})];
%arrayModelos = [arrayModelos, ModeloTreino(2, 2, [10 1], {'tansig', 'tansig', 'pureline'}, 'traingdx', 1000, 'dividerand', {.70, .15, .15})];
%arrayModelos = [arrayModelos, ModeloTreino(2, 2, [10 1], {'tansig', 'tansig', 'pureline'}, 'traingd', 1000, 'dividerand', {.70, .15, .15})];



% Num de x que vai repetir o modelo e para ajudar na média
numRepeticoesModelo = 10; % TODO: Alterar para 10

% Transform the images into vertical binary vectors
imageSize = 25;

% ===============================

% Path to the data folder
dataDir = fullfile('data', 'datasets', dirImg);
currentDateTime = datestr(now, 'yyyymmddHHMM');

% Load the training data
if strcmp(tipoTreino, 'mix')
    categories = {'0','1','2','3','4','5','6','7','8','9','add','sub','mul','div'};
elseif strcmp(tipoTreino, 'op')
    categories = {'add','sub','mul','div'};
elseif strcmp(tipoTreino, 'mun')
    categories = {'0','1','2','3','4','5','6','7','8','9'};
end

imds = imageDatastore(fullfile(dataDir, categories), 'LabelSource', 'foldernames');

% Get the number of files and categories
numFiles = numel(imds.Files);
numCategories = numel(categories);

% Create a matrix of zeros
outputMatrix = zeros(numCategories, numFiles);

% Fill the matrix with the targets
for i = 1:numFiles
    [~, target] = fileparts(fileparts(imds.Files{i}));
    targetIndex = find(strcmp(categories, target));
    outputMatrix(targetIndex, i) = 1;
end


inputBinaryImages = zeros(imageSize * imageSize, numFiles);
for i = 1:numFiles
    fileDir = imds.Files{i};
    img = imread(fileDir);

    % Resize the image to the desired size
    resizedImg = imresize(img, [imageSize imageSize]);

    % Convert the resized image to binary
    binaryImg = imbinarize(resizedImg);
    
    % Convert the binaryImg to a column vector
    binaryColumn = binaryImg(:);

    % Add the image to the matrix
    inputBinaryImages(:, i) = binaryColumn;
end

disp("Total number of columns (images) in the input matrix: " + size(inputBinaryImages, 2));
disp("Total number of lines (images) in the input: " + size(inputBinaryImages, 1));
disp("Total number of repetitions per model: " + numRepeticoesModelo);

% Cria um registro para guardar os resultados
resultsCell = {};

for i = 1:numel(arrayModelos)

    % Vetores temporários para armazenar os resultados das repetições
    accuracyValues = zeros(1, numRepeticoesModelo);
    accuracyTesteValues = zeros(1, numRepeticoesModelo);
    
    for repetition = 1:numRepeticoesModelo
        % Modelo Base para o treino
        modeloTreino = arrayModelos(i);
    
        % Configuração e criação da rede 
        net = feedforwardnet(modeloTreino.numNeuronios);
    
        % Validar se tem uma funcção de treino para cada camada
        numFuncoesTreino = numel(modeloTreino.funcoesAtivacao) - 1;
        
        if(modeloTreino.numCamadas == numFuncoesTreino)
            for j = 1:numFuncoesTreino 
                % Definir a função de treino para cada camada
                net.layers{j}.transferFcn = modeloTreino.funcoesAtivacao{j};
            end
        else
            disp("Número de camadas ou o numero de funções de ativação não estão corretas")
        end
     
        %disp(modeloTreino.divisao(1))
        %return
        net.trainFcn = modeloTreino.funcaoDeTreino;
        net.trainParam.epochs = modeloTreino.epochs;
        net.divideFcn = modeloTreino.divisaoFuncao;
        net.divideParam.trainRatio = modeloTreino.divisaoValores{1};
        net.divideParam.valRatio = modeloTreino.divisaoValores{2};
        net.divideParam.testRatio = modeloTreino.divisaoValores{3};
        
        % Treina e testa a rede neural
        [net, tr] = train(net, inputBinaryImages, outputMatrix);

        % Simulate
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
        
        % Fazer um teste
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

        % Gravar o treino
        filename = ['train','_' ,num2str(modeloTreino.id),'_' , num2str(fix(accuracy)), '_', num2str(fix(accuracyTeste)), '.mat'];
        folder = fullfile('trains');
        
        % Verificar se o diretório de destino existe
        if ~isfolder(folder)
            mkdir(folder);
        end
        
        file = fullfile(folder, filename);
        save(file, 'net');

        resultsCell(end+1, :) = {file, modeloTreino.numCamadas, mat2str(modeloTreino.numNeuronios), strjoin(modeloTreino.funcoesAtivacao, ' '), modeloTreino.funcaoDeTreino, modeloTreino.epochs, modeloTreino.divisaoFuncao, modeloTreino.divisaoValores{1}, modeloTreino.divisaoValores{2}, modeloTreino.divisaoValores{3}, accuracy, accuracyTeste};

    end
   
    % Calcula a média dos valores de accuracy e accuracyTeste
    accuracy = mean(accuracyValues);
    accuracyTeste = mean(accuracyTesteValues);
    mediaText = ['Média de ID: ' num2str(modeloTreino.id)];
    resultsCell(end+1, :) = {mediaText, modeloTreino.numCamadas, mat2str(modeloTreino.numNeuronios), strjoin(modeloTreino.funcoesAtivacao, ' '), modeloTreino.funcaoDeTreino, modeloTreino.epochs, modeloTreino.divisaoFuncao, modeloTreino.divisaoValores{1}, modeloTreino.divisaoValores{2}, modeloTreino.divisaoValores{3}, accuracy, accuracyTeste};
 
end

% Salvar a tabela como um arquivo CSV
results = cell2table(resultsCell, 'VariableNames', {'FileName' 'NumberLayres', 'NumberNeurons', 'ActivationFunctions', 'TrainingFunction', 'Epochs', 'Division', 'TrainRatio', 'ValRatio', 'TestRatio', 'Accuracy' , 'TestAccuracy'});

folder = fullfile('trains');
filename = fullfile(folder, [currentDateTime 'results.csv']);
writetable(results, filename, 'Delimiter', ';', 'WriteMode', 'append');

disp(results);
