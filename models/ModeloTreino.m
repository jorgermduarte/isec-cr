classdef ModeloTreino
    properties
        id
        numCamadas
        numNeuronios
        funcoesAtivacao
        funcaoDeTreino
        epochs
        divisaoFuncao,
        divisaoValores
    end
    
    methods
        function obj = ModeloTreino(id, numCamadas, numNeuronios, funcoesAtivacao, funcaoDeTreino, epochs, divisaoFuncao, divisaoValores )
            if nargin > 0
                obj.id = id;
                obj.numCamadas = numCamadas;
                obj.numNeuronios = numNeuronios;
                obj.funcoesAtivacao = funcoesAtivacao;
                obj.funcaoDeTreino = funcaoDeTreino;
                obj.epochs = epochs;
                obj.divisaoFuncao = divisaoFuncao;
                obj.divisaoValores = divisaoValores;
            end
        end
    end
end