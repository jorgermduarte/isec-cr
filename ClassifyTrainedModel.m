%  ====== LOAD DOS OBJETOS ======
addpath("objects");

targetFolder = TrainingFolder.train1;
trainingType = TrainingType.MIX;
modelName = "model_815_96_83_MIX.mat";

% Configuracao de tamanho da imagem (25x25), para ser usado no resize
% e convertido para um vetor binario na vertical
imageSize = 25;

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

% Cria um registo para guardar os resultados
resultsCell = {};

% todo: load da rede neural que queremos testar (ex: net = net_1_99_99.mat)

load( fullfile('models', modelName));

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

disp("Model name: " + modelName);
disp("Accuracy: " + accuracy + "%");

