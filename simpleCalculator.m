function simpleCalculator
    % Criar a interface gráfica
    fig = uifigure('Name', 'Simple Calculator', 'Position', [300 300 500 400]);
    
    % Carregar a rede treinada
    trainedNet = load('models/trainedNet.mat');
    net = trainedNet.net;
    
    % Adicionar etiqueta para mostrar o modelo de rede atual
    modelLabel = uilabel(fig, 'Text', 'Current model: trainedNet', 'Position', [10 365 200 20]);
    
    % Adicionar botão para carregar outro modelo
    loadModelButton = uibutton(fig, 'push', 'Text', 'Load Model', ...
        'Position', [250 360 100 30], 'ButtonPushedFcn', @loadModel);
    
    % Adicionar botão para selecionar imagem
    selectImageButton = uibutton(fig, 'push', 'Text', 'Select Image', ...
        'Position', [10 320 100 30], 'ButtonPushedFcn', @selectImage);
    
    % Adicionar área de visualização de imagem
    imgAx = uiaxes(fig, 'Position', [150 150 200 200]);
    
    % Adicionar botão para classificar a expressão
    classifyButton = uibutton(fig, 'push', 'Text', 'Classify Expression', ...
        'Position', [390 290 100 30], 'ButtonPushedFcn', @classifyExpression);
    
    % Adicionar botão para desenhar uma imagem
    drawButton = uibutton(fig, 'push', 'Text', 'Draw Image', ...
        'Position', [390 230 100 30], 'ButtonPushedFcn', @drawImage);
    
    % Adicionar área de texto para exibir resultado
    resultText = uitextarea(fig, 'Position', [100 50 300 50], 'Editable', 'off');
    
    img = [];  % Imagem atual
    
    % Função para carregar outro modelo
    function loadModel(src, event)
        [file, path] = uigetfile('*.mat', 'Select a model');
        if file ~= 0
            trainedNet = load(fullfile(path, file));
            net = trainedNet.net;
            modelLabel.Text = sprintf('Current model: %s', file);
        end
    end



    % Função para selecionar imagem
    function selectImage(src, event)
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files'}, 'Select an image');
        if file ~= 0
            img = imread(fullfile(path, file));
            imshow(img, 'Parent', imgAx);
        end
    end

    % Função para classificar a expressão
    function classifyExpression(src, event)
        if isempty(img)
            resultText.Value = 'No image selected or drawn.';
        else
            % Pré-processar a imagem e classificar os componentes da expressão
            result = preprocessAndClassify(img, net);
            resultText.Value = sprintf('Result: %s', result);
        end
    end

    function symbols = extractSymbols(img)
        % Inverter a imagem, se necessário (garantir que os símbolos sejam brancos e o fundo seja preto)
        if mean(img(:)) > 0.5
            img = imcomplement(img);
        end
        
        % Detectar regiões da imagem
        regions = regionprops(img, 'BoundingBox');
        
        % Extrair símbolos das regiões
        symbols = cell(1, numel(regions));
        for i = 1:numel(regions)
            boundingBox = regions(i).BoundingBox;
            x = floor(boundingBox(1));
            y = floor(boundingBox(2));
            w = ceil(boundingBox(3));
            h = ceil(boundingBox(4));
            symbol = img(y:y+h-1, x:x+w-1);
            symbols{i} = symbol;
        end
        
        % Ordenar símbolos da esquerda para a direita
        centroids = arrayfun(@(r) mean(r.BoundingBox([1, 3])), regions);
        [~, sortedIdx] = sort(centroids);
        symbols = symbols(sortedIdx);
    end

    function result = preprocessAndClassify(img, net)
        % Pré-processar a imagem
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        img = imbinarize(img);
        
        % Segmentar e extrair os símbolos da imagem
        % Esta função deve ser implementada para extrair os símbolos da imagem
        % da expressão. Você deve adaptar esta função de acordo com o seu método
        % de segmentação e extração.
        symbols = extractSymbols(img);
        
        % Classificar os símbolos usando a rede neural
        classifiedSymbols = cell(1, numel(symbols));
        for i = 1:numel(symbols)
            symbol = symbols{i};
            symbol = imresize(symbol, [150 150]);
            classLabel = classify(net, symbol);
            classifiedSymbols{i} = char(classLabel);
        end
        
        % Interpretar a expressão classificada e calcular o resultado
        expression = strjoin(classifiedSymbols, '');
        result = num2str(eval(expression));
    end

    % Adicionar botão para identificar números e símbolos na imagem
    identifyButton = uibutton(fig, 'push', 'Text', 'Identify', ...
        'Position', [390 170 100 30], 'ButtonPushedFcn', @identifyExpression);
    
    function identifyExpression(src, event)
        if isempty(img)
            resultText.Value = 'No image selected or drawn.';
        else
            % Pré-processar a imagem e extrair os símbolos
            symbols = extractSymbols(img);
            
            % Classificar os símbolos usando a rede neural
            classifiedSymbols = cell(1, numel(symbols));
            for i = 1:numel(symbols)
                symbol = symbols{i};
                symbol = imresize(symbol, [150 150]);
                classLabel = classify(net, symbol);
                classifiedSymbols{i} = char(classLabel);
            end
            
            % Interpretar a expressão classificada
            expression = strjoin(classifiedSymbols, '');
            resultText.Value = sprintf('Identified Expression: %s', expression);
        end
    end



    function drawImage(src, event)
        canvas = figure('Name', 'Draw Image', 'Position', [600 300 150 150]);
        imgAx = axes(canvas, 'Position', [0 0 1 1]);
        axis(imgAx, 'equal');
        hold(imgAx, 'on');
        
        % Inicializar a imagem desenhada
        img = ones(150, 150) * 255;
        
        % Configurar o desenho interativo
        set(canvas, 'WindowButtonDownFcn', @startDrawing);
        set(canvas, 'WindowButtonUpFcn', @stopDrawing);
        set(canvas, 'WindowButtonMotionFcn', @drawLine);
        
        drawing = false;
        
        function startDrawing(src, event)
            drawing = true;
        end
        
        function stopDrawing(src, event)
            drawing = false;
        end
        
        function drawLine(src, event)
            if drawing
                cp = imgAx.CurrentPoint;
                x = round(cp(1, 1));
                y = round(cp(1, 2));
                
                % Desenhar um círculo preto com raio de 5 pixels
                for dx = -5:5
                    for dy = -5:5
                        if dx^2 + dy^2 <= 5^2
                            ix = x + dx;
                            iy = y + dy;
                            if ix > 0 && ix <= 150 && iy > 0 && iy <= 150
                                img(iy, ix) = 0;
                            end
                        end
                    end
                end
                
                imshow(img, 'Parent', imgAx);
            end
        end
        
        % Adicionar botão para salvar a imagem desenhada
        uicontrol(canvas, 'Style', 'pushbutton', 'String', 'Save Image', ...
            'Units', 'normalized', 'Position', [0.8 0.05 0.15 0.1], ...
            'Callback', @saveImage);
        
        function saveImage(src, event)
            [file, path] = uiputfile({'*.png', 'PNG Image'}, 'Save Image');
            if file ~= 0
                imwrite(img, fullfile(path, file), 'png');
            end
            close(canvas);
        end
    end


end

