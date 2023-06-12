function UserInterface

    categories = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'add', 'sub', 'mul', 'div'};

    defaultModel = "model_815_96_83_MIX.mat";


    % Criar a interface gráfica
    fig = uifigure('Name', 'Simple Calculator', 'Position', [300 300 500 400]);
    
    % Carregar a rede treinada
    trainedNet = load('models/' + defaultModel);
    net = trainedNet.net;
    

    % Adicionar botões de rádio para selecionar categories
    categoryButtonGroup = uibuttongroup(fig, 'Position', [10 120 130 130], 'Title', 'Categories', 'SelectionChangedFcn', @changeCategories);
    uiradiobutton(categoryButtonGroup, 'Text', 'All', 'Position', [10 70 80 20], 'UserData', {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'add', 'sub', 'mul', 'div'});
    uiradiobutton(categoryButtonGroup, 'Text', 'Numbers', 'Position', [10 40 80 20], 'UserData', {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'});
    uiradiobutton(categoryButtonGroup, 'Text', 'Operations', 'Position', [10 10 80 20], 'UserData', {'add', 'sub', 'mul', 'div'});


    % Adicionar texto para mostrar o modelo de rede atual
    modelLabel = uilabel(fig, 'Text', 'Current model: ' + defaultModel , 'Position', [10 345 300 20]);

    categoriesLabel = uilabel(fig, 'Text', ['Current categories: ' + string(strjoin(categories,','))], 'Position', [10 365 300 20]);

    
    % Adicionar botão para carregar outro modelo
    loadModelButton = uibutton(fig, 'push', 'Text', 'Load Model', ...
        'Position', [10 300 100 30], 'ButtonPushedFcn', @loadModel);

    % Adicionar botão para selecionar imagem
    selectImageButton = uibutton(fig, 'push', 'Text', 'Select Image', ...
        'Position', [10 260 100 30], 'ButtonPushedFcn', @selectImage);

    % Adicionar área de visualização de imagem
    imgAx = uiaxes(fig, 'Position', [150 135 200 200]);

    % Adicionar botão para identificar números e símbolos na imagem
    identifyButton = uibutton(fig, 'push', 'Text', 'Identify', ...
        'Position', [390 160 100 30], 'ButtonPushedFcn', @identifyExpression);

    % Adicionar botão para desenhar uma imagem
    drawButton = uibutton(fig, 'push', 'Text', 'Draw Image', ...
        'Position', [390 240 100 30], 'ButtonPushedFcn', @drawImage);

    % Adicionar área de texto para exibir resultado
    resultText = uitextarea(fig, 'Position', [10 50 350 50], 'Editable', 'off');

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

    function changeCategories(src, event)
        categories = event.NewValue.UserData;
        categoriesLabel.Text = sprintf("Current Categories: %s", string(strjoin(categories,',')) )
    end

    function identifyExpression(src, event)
        if isempty(img)
            resultText.Value = 'No image selected or drawn.';
        else
            % converte a imagem para grayscale caso nao seja
            if ndims(img) == 3
                img = rgb2gray(img);
            end
            
            % converter imagem para uma matrix binaria
            binaryImg = imbinarize(img);

            % redimensionar a imagem para
            resizedImg = imresize(binaryImg, [25 25]);

            % converter a matriz para uma matriz vertical e coloca-la num array 3D
            inputMatrixVertical = resizedImg(:);
            inputArray3D = zeros(1, 1, numel(inputMatrixVertical));
            inputArray3D(1,1,:) = inputMatrixVertical;
        

            % envia imagem para a rede neural e retorna o resultado da classificação
            outputMatrix = net(inputMatrixVertical);

            [~, result] = max(outputMatrix);
            disp("Identified -> " + categories{result});
            
            % exibe o resultado
            resultText.Value = sprintf('Identified character: %s', categories{result});
        end
    end


    function drawImage(src, event)
        canvas = figure('Name', 'Draw Image', 'Position', [600 300 150 150]);
        imgAx2 = axes(canvas, 'Position', [0 0 1 1]);
        axis(imgAx2, 'equal');
        hold(imgAx2, 'on');
        
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
                cp = imgAx2.CurrentPoint;
                x = round(cp(1, 1));
                y = round(cp(1, 2));
                
                raio = 10;
                % Desenhar um círculo preto com raio de 5 pixels
                for dx = -raio:raio
                    for dy = -raio:raio
                        if dx^2 + dy^2 <= raio^2
                            ix = x + dx;
                            iy = y + dy;
                            if ix > 0 && ix <= 150 && iy > 0 && iy <= 150
                                img(iy, ix) = 0;
                            end
                        end
                    end
                end
                
                imshow(img, 'Parent', imgAx2);
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