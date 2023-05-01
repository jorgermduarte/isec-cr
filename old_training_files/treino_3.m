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
    imageInputLayer(inputSize, 'Normalization', 'none')
    convolution2dLayer(5, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(5, 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(5, 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    
    fullyConnectedLayer(512)
    dropoutLayer(0.5)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.01, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.2, ...
    'LearnRateDropPeriod', 5, ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 64, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'Shuffle', 'every-epoch', ...
    'ExecutionEnvironment', 'auto', ...
    'ValidationData', {trainImages, trainLabels}, ...
    'ValidationFrequency', 30);

net = trainNetwork(startImages, startLabels, layers, options);

% Testar a rede com imagens da pasta "train1"
YPred = classify(net, trainImages);
YValidation = double(trainLabels);
accuracy = sum(YPred == trainLabels) / numel(YValidation);
fprintf('Accuracy: %.2f\n', accuracy);

% Salvar a rede treinada (modelo)
save('trainedNet.mat', 'net');
