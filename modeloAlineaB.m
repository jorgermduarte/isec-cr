% Path to the data folder
dataDir = fullfile('data', 'datasets', 'start');

% Load the training data
categories = {'0','1','2','3','4','5','6','7','8','9','add','sub','mul','div'};
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

% Transform the images into vertical binary vectors
imageSize = 25;
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


% Define o número de neurónios na camada escondida
%hiddenLayerSizes = [10, 20, 30];
hiddenLayerSizes = [3];

% Define as funções de ativação
%activationFunctions = {'logsig', 'tansig', 'purelin'};
activationFunctions = {'logsig', 'tansig' };

% Define os algoritmos de treinamento
%trainingFunctions = {'trainlm', 'traingd', 'trainbfg'};
trainingFunctions = {'trainlm'};

% Cria um registro para guardar os resultados
results = [];

% Loop sobre todos as configurações possíveis
for hiddenLayerSize = hiddenLayerSizes
    for hiddenLayerActivationFunction = activationFunctions
        for outputLayerActivationFunction = activationFunctions
            for trainingFunction = trainingFunctions

                % Cria a rede neural
                net = feedforwardnet(hiddenLayerSize);
                net.layers{1}.transferFcn = hiddenLayerActivationFunction{1};
                net.layers{2}.transferFcn = outputLayerActivationFunction{1};
                net.trainFcn = trainingFunction{1};
                net.trainParam.epochs = 1000;

                % Treina e testa a rede neural
                [net, tr] = train(net, inputBinaryImages, outputMatrix);
                out = sim(net, inputBinaryImages);
                [c, d] = max(out, [], 1);
                [a, b] = max(outputMatrix, [], 1);
                correctPredictions = sum(b == d);
                accuracy = correctPredictions/size(out,2)*100;

                % Armazena os resultados
                results = [results; hiddenLayerSize, hiddenLayerActivationFunction, outputLayerActivationFunction, trainingFunction, accuracy];

            end
        end
    end
end

% Exibe os resultados
results = cell2table(results, 'VariableNames', {'HiddenLayerSize', 'HiddenLayerActivationFunction', 'OutputLayerActivationFunction', 'TrainingFunction', 'Accuracy'});
disp(results);
