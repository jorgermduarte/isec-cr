% Carregar imagens do diretório e preparar os dados de treinamento
dataFolder = 'data/datasets';
startFolder = fullfile(dataFolder, 'start');
trainFolder = fullfile(dataFolder, 'train1');
classFolders = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'add', 'div', 'mul', 'sub'};

% Carregar imagens da pasta "start" e pré-processar
[startImages, startLabels] = loadAndPreprocessImages(startFolder, classFolders);

% Carregar imagens da pasta "train1" e pré-processar
[trainImages, trainLabels] = loadAndPreprocessImages(trainFolder, classFolders);

% Converter rótulos para dados categóricos
startLabels = categorical(startLabels);
trainLabels = categorical(trainLabels);

% Criar e treinar a rede neural
inputSize = [150, 150];
numClasses = numel(classFolders);
layers = [
    imageInputLayer(inputSize)
    fullyConnectedLayer(10)
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.05, ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 64, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

net = trainNetwork(startImages, startLabels, layers, options);

% Testar a rede com imagens da pasta "train1"
YPred = classify(net, trainImages);
YValidation = double(trainLabels);
accuracy = sum(YPred == trainLabels) / numel(YValidation);
fprintf('Accuracy: %.2f\n', accuracy);

% Salvar a rede treinada
save('trainedNet.mat', 'net');