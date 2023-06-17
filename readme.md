# ISEC - Conhecimento e raciocinio

### Treino de uma rede neuronal para identificação de números e operadores


<br/><br/>

---
## Como executar a aplicação?

Para executar a aplicação basta escrever o comando que se segue em baixo no Matlab:
```
 UserInterface
```

<br/>

![User Interface Image](/docs/images/application/user-interface2.png)
<br/>
![User Interface Image 2](/docs/images/application/user-interface3.png)

<br/>
<br/><br/>


# Identificação dos elementos presente na expressão

```
Para identificar elementos individuais numa expressão, quer sejam números ou operadores, tivemos que adaptar a nossa abordagem. Isto deve-se ao facto de as nossas redes neuronais esperarem receber apenas um caractere de cada vez.

Assim, criámos um novo botão, denominado 'Verify Expression'. Este botão analisa a imagem carregada pelo utilizador, detecta números e operadores, divide a imagem em partes individuais, redimensiona cada parte para 25x25 pixels e, finalmente, converte cada parte numa matriz binária e numa matriz de colunas.

A detecção de números e operadores baseia-se nas cores presentes nas colunas, uma vez que as imagens são sempre a preto e branco. Observa a imagem abaixo para uma melhor compreensão:


Como podemos observar, na primeira coluna, todos os 'bits' da imagem são brancos, o que significa que nenhum número ou operador foi detectado. No entanto, na segunda coluna, detectamos um bit preto, o que marca o início da detecção do primeiro dígito. Na quarta coluna, todos os bits são brancos, indicando o fim da deteção daquela imagem, já que a imagem termina na terceira coluna.

Com esta abordagem, conseguimos detectar facilmente os dígitos presentes na imagem e redimensioná-los para o tamanho 25x25, onde de seguida são utilizados como entrada para o modelo que está carregado na interface.

```

> Observe abaixo uma imagem, onde através de uma expressão matemática, conseguimos identificar corretamente os elementos presentes e o resultado da operação.


![User Interface Image 3](/docs/images/application/user-interface4.png)