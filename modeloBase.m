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

net = feedforwardnet(10);
net.layers{2}.transferFcn = 'purelin';
net.layers{1}.transferFcn = 'tansig';
net.trainFcn = 'trainlm';
net.trainParam.epochs = 1000;

numRuns = 1;

for run = 1:numRuns
    % Train the network
    [net, tr] = train(net, inputBinaryImages, outputMatrix);
    
    % Simulate
    out = sim(net, inputBinaryImages);

    % Plot confusion
    plotconfusion(outputMatrix, out);

    %plotperf(tr)

    r = 0;
    for i=1:size(out,2)
        [a b] = max(outputMatrix(:,i));
        [c d] = max(outputMatrix(:,i));
        if b == d
          r = r+1;
        end
    end
    
    accuracy = r/size(out,2)*100;
    fprintf('Total precision %.2f\n', accuracy);
end
