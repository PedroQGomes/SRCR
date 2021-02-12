# MIEI - 3ºAno - Sistemas de Representação de Conhecimento e Raciocínio

## Trabalho individual 

O trabalho individual pratico proposto consiste em desenvolver um sistema, na linguagem **Prolog**, que importe dados sobre cidades Portuguesas e construa um base de conhecimento permitindo posteriormente fazer um sistema de recomendação. Nos dados fornecidos não existem as ligações entre as cidades e por isso foi implementado um programa em Java que calcula as ligações entre as cidades.

O sistema tem as seguintes funcionalidades

* Selecionar apenas cidades, com uma determinada característica, para um determinado trajeto
* Excluir uma ou mais características de cidades de um percurso
* Identificar num determinado percurso qual a cidade com o maior numero de ligações
* Escolher o menor percurso (usando o critério do menor numero de cidades percorridas)
* Escolher o percurso mais rápido(usando o critério distancia)
* Escolher um percurso que passe por apenas por cidades "minor"
* Escolher uma ou mais cidades por onde o percurso devera obrigatoriamente passar

## Dependências

Para correr o script em python necessario para o projeto são necessários os módulos pandas e openpyxl

```
pip3 install pandas
```

```
pip3 install openpyxl
```

## Compilação e Testes

Para compilar o projeto em primeiro lugar é corrido o script em **python** que transforma o ficheiro **cidades.xlsx** em **cidades.csv**.

```
python3 script.py
```

De seguida é compilado e executado a aplicação em **Java** que calcula as cidades que tem ligações entre si.Para isso é aconselhado o uso de um **IDE**, no caso de escolher o **Intellij** é apenas criar um projeto "from existing sources" e escolher a diretoria do repositório. De seguida é executar a classe **Main.java** e o ficheiro **ligacoes.csv** é criado.

Por fim é executar o prolog e consultar o ficheiro **trabalho_recurso.pl** e correr o comando

```
import.
```
