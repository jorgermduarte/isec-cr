classdef TrainingModel
    properties
        id
        numCamadas
        numNeuronios
        funcoesAtivacao
        funcaoDeTreino
        epochs
        divisaoFuncao,
        divisaoValores,
        funcoesAprendizagem,
        taxaAprendizagem,
    end

    methods
        function obj = TrainingModel(id, numCamadas, numNeuronios, funcoesAtivacao, funcaoDeTreino, epochs, divisaoFuncao, divisaoValores, funcoesAprendizagem, taxaAprendizagem )
            if nargin > 0
                obj.id = id;
                obj.numCamadas = numCamadas;
                obj.numNeuronios = numNeuronios;
                obj.funcoesAtivacao = funcoesAtivacao;
                obj.funcaoDeTreino = funcaoDeTreino;
                obj.epochs = epochs;
                obj.divisaoFuncao = divisaoFuncao;
                obj.divisaoValores = divisaoValores;
                obj.funcoesAprendizagem = funcoesAprendizagem;
                obj.taxaAprendizagem = taxaAprendizagem;
            end
        end
    end
end