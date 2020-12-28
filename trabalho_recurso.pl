:- use_module(library(csv)). 


import:-
    csv_read_file('cidades.csv', Data, [functor(cidade), skip_header(iD)]),
    csv_read_file('ligacoes.csv', DataL, [functor(ligacao), skip_header(iD)]),
    maplist(assert, DataL),
    maplist(assert, Data).

%a84c0989-9133-4253-a4d8-07dcbba64680
%cidade(ID, NOME, LATITUDE, LONGITUDE, ADMIN, CAPITAL,PATRIMONIO).
%ligacao(ID1,ID2,DISTANCIA).

% Predicado cidadesLigadas 
cidadesLigadas(ID1,ID2):- cidade(ID1,_,_,_,_,_,_),cidade(ID2,_,_,_,_,_,_),ligacao(ID1,ID2,_).
cidadesLigadas(ID1,ID2):- cidade(ID1,_,_,_,_,_,_),cidade(ID2,_,_,_,_,_,_),ligacao(ID2,ID1,_).

% Predicado cidadesLigadas com distancia
cidadesLigadasDist(ID1,ID2,D):- cidade(ID1,_,_,_,_,_,_),cidade(ID2,_,_,_,_,_,_),ligacao(ID1,ID2,D).
cidadesLigadasDist(ID1,ID2,D):- cidade(ID1,_,_,_,_,_,_),cidade(ID2,_,_,_,_,_,_),ligacao(ID2,ID1,D).

% Predicado cidadesLigadas com a mesma responsabilidade com distancia 
cidadesLigadasDist_Resp(ID1,ID2,R,D):- cidade(ID1,_,_,_,_,R,_),cidade(ID2,_,_,_,_,R,_),ligacao(ID1,ID2,D).
cidadesLigadasDist_Resp(ID1,ID2,R,D):- cidade(ID1,_,_,_,_,R,_),cidade(ID2,_,_,_,_,R,_),ligacao(ID2,ID1,D).

% Predicado cidadesLigadas com patrimonio mundial 
cidadesLigadasDist_Cult(ID1,ID2,D):- cidade(ID1,_,_,_,_,_,'yes'),cidade(ID2,_,_,_,_,_,'yes'),ligacao(ID1,ID2,D).
cidadesLigadasDist_Cult(ID1,ID2,D):- cidade(ID1,_,_,_,_,_,'yes'),cidade(ID2,_,_,_,_,_,'yes'),ligacao(ID2,ID1,D).

% Predicado cidadesLigadas com patrimonio mundial 
cidadesLigadasDist_NO_Cult(ID1,ID2,D):- cidade(ID1,_,_,_,_,_,'No'),cidade(ID2,_,_,_,_,_,'No'),ligacao(ID1,ID2,D).
cidadesLigadasDist_NO_Cult(ID1,ID2,D):- cidade(ID1,_,_,_,_,_,'No'),cidade(ID2,_,_,_,_,_,'No'),ligacao(ID2,ID1,D).


% Predicado cidadesLigadas excluindo responsabilidades  com distancia 
cidadesLigadasDist_Exc(ID1,ID2,R,D):- cidade(ID1,_,_,_,_,A,_),cidade(ID2,_,_,_,_,B,_),dif(A, R),dif(B, R),ligacao(ID1,ID2,D).
cidadesLigadasDist_Exc(ID1,ID2,R,D):- cidade(ID1,_,_,_,_,A,_),cidade(ID2,_,_,_,_,B,_),dif(A, R),dif(B, R),ligacao(ID2,ID1,D).

% Predicado cidadesLigadas do tipo minor com distancia
cidadesLigadasDist_Minor(ID1,ID2,D):- cidade(ID1,_,_,_,_,'minor',_),cidade(ID2,_,_,_,_,'minor',_),ligacao(ID1,ID2,D).
cidadesLigadasDist_Minor(ID1,ID2,D):- cidade(ID1,_,_,_,_,'minor',_),cidade(ID2,_,_,_,_,'minor',_),ligacao(ID1,ID2,D).

% Predicado caminhoLigado 
caminhoLigado([ID |[]]).
caminhoLigado([ID1,ID2|T]):- cidadesLigadas(ID1,ID2),caminhoLigado([ID2|T]).




%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pesquisa Depth-First de um trajeto possível entre duas cidades
trajetoDp(C1, C2, Percurso/Distancia) :-
    trajetoDpRec([C1], C2, InvPercurso, 0, Distancia),
    inverso(InvPercurso, Percurso).

trajetoDpRec([H | T], H, [H | T], Distancia, Distancia).
trajetoDpRec([H | T], B, Percurso, CurrDistancia, Distancia) :-
    cidadesLigadasDist(H,C,D1),
    \+member(C, [H | T]),
    NewDistancia is CurrDistancia + D1,
    trajetoDpRec([C, H | T], B, Percurso, NewDistancia, Distancia).

% Pesquisa A* do melhor trajeto entre duas cidades

trajeto_A(ID, Objetivo, Caminho/Comprimento):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela([[ID]/0/Estima], InvCaminho/Comprimento/_, Objetivo),
    inverso(InvCaminho, Caminho).

aestrela(Caminhos, Caminho, Objetivo):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela(Caminhos, SolucaoCaminho, Objetivo) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela(MelhorCaminho, ExpCaminhos, Objetivo),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela(NovoCaminhos, SolucaoCaminho, Objetivo).	

expande_aestrela(Caminho, ExpCaminhos, Objetivo) :-
	findall(NovoCaminho, adjacente(Caminho,NovoCaminho, Objetivo), ExpCaminhos).

adjacente([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo) :-
    cidadesLigadasDist(Nodo, ProxNodo, Resultado), 
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + Resultado,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).

obtem_melhor([Caminho], Caminho) :- !.

obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Custo1 + Est1 =< Custo2 + Est2, !,
	obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor(Caminhos, MelhorCaminho).


% Pesquisa em Profundidade restringindo o tipo de responsabilidades administrativas das cidade

trajetoDp_Resp(C1,C2,Responsabilidades,Percurso/Distancia):-
    trajetoDpRec_Resp([C1], C2, Responsabilidades, InvPercurso, 0, Distancia),
    inverso(InvPercurso, Percurso).

trajetoDpRec_Resp([H | T], H, _, [H | T], Distancia, Distancia).

trajetoDpRec_Resp([H | T], B, Resp, Percurso, CurrDistancia, Distancia) :-
    cidadesLigadasDist_Resp(H,C,Resp,Dist),
    \+member(C, [H | T]),
    NewDistancia is CurrDistancia + Dist,
    trajetoDpRec_Resp([C, H | T], B, Resp, Percurso, NewDistancia, Distancia).


% Pesquisa A* restringindo o tipo de responsabilidades administrativas das cidade

trajeto_A_Resp(ID, Objetivo,Resp,Caminho/Comprimento):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela_Resp([[ID]/0/Estima], InvCaminho/Comprimento/_, Objetivo,Resp),
    inverso(InvCaminho, Caminho).

aestrela_Resp(Caminhos, Caminho, Objetivo,_):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela_Resp(Caminhos, SolucaoCaminho, Objetivo,Resp) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela_Resp(MelhorCaminho, ExpCaminhos, Objetivo,Resp),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela_Resp(NovoCaminhos, SolucaoCaminho, Objetivo,Resp).	

expande_aestrela_Resp(Caminho, ExpCaminhos, Objetivo,Resp) :-
	findall(NovoCaminho, adjacente_Resp(Caminho,NovoCaminho, Objetivo,Resp), ExpCaminhos).


adjacente_Resp([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo,Resp) :-
    cidadesLigadasDist_Resp(Nodo, ProxNodo,Resp,Resultado), 
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + Resultado,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).





% Pesquisa em Profundidade restringindo o tipo de cultura das cidade

trajetoDp_Cult(C1,C2,Percurso/Distancia):-
    trajetoDpRec_Cult([C1], C2, InvPercurso, 0, Distancia),
    inverso(InvPercurso, Percurso).

trajetoDpRec_Cult([H | T], H, [H | T], Distancia, Distancia).

trajetoDpRec_Cult([H | T], B, Percurso, CurrDistancia, Distancia) :-
    cidadesLigadasDist_Cult(H,C,Dist),
    \+member(C, [H | T]),
    NewDistancia is CurrDistancia + Dist,
    trajetoDpRec_Cult([C, H | T], B, Percurso, NewDistancia, Distancia).


% Pesquisa A* restringindo o tipo de cultura das cidade

trajeto_A_Cult(ID, Objetivo,Caminho/Comprimento):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela_Cult([[ID]/0/Estima], InvCaminho/Comprimento/_, Objetivo),
    inverso(InvCaminho, Caminho).

aestrela_Cult(Caminhos, Caminho, Objetivo):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela_Cult(Caminhos, SolucaoCaminho, Objetivo) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela_Cult(MelhorCaminho, ExpCaminhos, Objetivo),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela_Cult(NovoCaminhos, SolucaoCaminho, Objetivo).	

expande_aestrela_Cult(Caminho, ExpCaminhos, Objetivo) :-
	findall(NovoCaminho, adjacente_Cult(Caminho,NovoCaminho, Objetivo), ExpCaminhos).


adjacente_Cult([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo) :-
    cidadesLigadasDist_Cult(Nodo, ProxNodo,Resultado), 
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + Resultado,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).





% Pesquisa em Profundidade para Excluir o tipo de responsabilidades administrativas das cidade

trajetoDp_Exc(C1,C2,Responsabilidades,Percurso/Distancia):-
    trajetoDpRec_Exc([C1], C2, Responsabilidades, InvPercurso, 0, Distancia),
    inverso(InvPercurso, Percurso).

trajetoDpRec_Exc([H | T], H, _, [H | T], Distancia, Distancia).

trajetoDpRec_Exc([H | T], B, Resp, Percurso, CurrDistancia, Distancia) :-
    cidadesLigadasDist_Exc(H,C,Resp,Dist),
    \+member(C, [H | T]),
    NewDistancia is CurrDistancia + Dist,
    trajetoDpRec_Exc([C, H | T], B, Resp, Percurso, NewDistancia, Distancia).


% Pesquisa A* para Excluir o tipo de responsabilidades administrativas das cidade

trajeto_A_Exc(ID, Objetivo,Resp,Caminho/Comprimento):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela_Exc([[ID]/0/Estima], InvCaminho/Comprimento/_, Objetivo,Resp),
    inverso(InvCaminho, Caminho).

aestrela_Exc(Caminhos, Caminho, Objetivo,_):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela_Exc(Caminhos, SolucaoCaminho, Objetivo,Resp) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela_Exc(MelhorCaminho, ExpCaminhos, Objetivo,Resp),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela_Exc(NovoCaminhos, SolucaoCaminho, Objetivo,Resp).	

expande_aestrela_Exc(Caminho, ExpCaminhos, Objetivo,Resp) :-
	findall(NovoCaminho, adjacente_Exc(Caminho,NovoCaminho, Objetivo,Resp), ExpCaminhos).


adjacente_Exc([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo,Resp) :-
    cidadesLigadasDist_Exc(Nodo, ProxNodo,Resp,Resultado), 
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + Resultado,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).



% Pesquisa em Profundidade para Excluir o tipo de responsabilidades administrativas das cidade

trajetoDp_ExcCult(C1,C2,Percurso/Distancia):-
    trajetoDpRec_ExcCult([C1], C2, InvPercurso, 0, Distancia),
    inverso(InvPercurso, Percurso).

trajetoDpRec_ExcCult([H | T], H, [H | T], Distancia, Distancia).

trajetoDpRec_ExcCult([H | T], B, Percurso, CurrDistancia, Distancia) :-
    cidadesLigadasDist_NO_Cult(H,C,Dist),
    \+member(C, [H | T]),
    NewDistancia is CurrDistancia + Dist,
    trajetoDpRec_ExcCult([C, H | T], B, Percurso, NewDistancia, Distancia).


% Pesquisa A* para Excluir cidades que tem patrimonio cultural das cidade

trajeto_A_ExcCult(ID, Objetivo,Caminho/Comprimento):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela_ExcCult([[ID]/0/Estima], InvCaminho/Comprimento/_, Objetivo),
    inverso(InvCaminho, Caminho).

aestrela_ExcCult(Caminhos, Caminho, Objetivo):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela_ExcCult(Caminhos, SolucaoCaminho, Objetivo) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela_ExcCult(MelhorCaminho, ExpCaminhos, Objetivo),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela_ExcCult(NovoCaminhos, SolucaoCaminho, Objetivo).	

expande_aestrela_ExcCult(Caminho, ExpCaminhos, Objetivo) :-
	findall(NovoCaminho, adjacente_ExcCult(Caminho,NovoCaminho, Objetivo), ExpCaminhos).


adjacente_ExcCult([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo) :-
    cidadesLigadasDist_NO_Cult(Nodo, ProxNodo,Resultado), 
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + Resultado,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).



% Pesquisa identificar num determinado percurso qual a cidade com o maior número de ligações

maisLigacoes([ID |[]], ID/R):- numeroLigacoes(ID,R).

maisLigacoes([ID1,ID2|T],ID1/Res):-
    cidadesLigadas(ID1,ID2),
    numeroLigacoes(ID1,Res),
    maisLigacoes([ID2|T], _/R),
    R < Res.

maisLigacoes([ID1,ID2|T],Cidades/R):-
    cidadesLigadas(ID1,ID2),
    numeroLigacoes(ID1, Res),
    maisLigacoes([ID2|T], Cidades/R),
    Res < R.

maisLigacoes([ID1,ID2|T], [ID1 |Cidades]/Res):-
    cidadesLigadas(ID1,ID2),
    numeroLigacoes(ID1,Res),
    maisLigacoes([ID2|T], Cidades/Res).



% Predicado menor percurso, o critério do menor número de cidades percorridas, A*

trajeto_A_Less(ID, Objetivo, Caminho/NCidades):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela_Less([[ID]/0/Estima], InvCaminho/NCidades/_, Objetivo),
    inverso(InvCaminho, Caminho).

aestrela_Less(Caminhos, Caminho, Objetivo):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela_Less(Caminhos, SolucaoCaminho, Objetivo) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela_Less(MelhorCaminho, ExpCaminhos, Objetivo),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela_Less(NovoCaminhos, SolucaoCaminho, Objetivo).	

expande_aestrela_Less(Caminho, ExpCaminhos, Objetivo) :-
	findall(NovoCaminho, adjacente_Less(Caminho,NovoCaminho, Objetivo), ExpCaminhos).

adjacente_Less([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo) :-
    cidadesLigadas(Nodo, ProxNodo), 
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + 1,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).





% Predicado de um percurso que passe apenas por cidades “minor” Depth-First

trajetoDp_Minor(C1,C2,Percurso/Distancia):-
    trajetoDpRec_Minor([C1], C2, InvPercurso, 0, Distancia),
    inverso(InvPercurso, Percurso).

trajetoDpRec_Minor([H | T], H, [H | T], Distancia, Distancia).

trajetoDpRec_Minor([H | T], B, Percurso, CurrDistancia, Distancia) :-
    cidadesLigadasDist_Minor(H,C,Dist),
    \+member(C, [H | T]),
    NewDistancia is CurrDistancia + Dist,
    trajetoDpRec_Minor([C, H | T], B, Percurso, NewDistancia, Distancia).

% Predicado de um percurso que passe apenas por cidades “minor” A*

trajeto_A_Minor(ID, Objetivo, Caminho/Comprimento):-
    distanciaEntreCidades(ID, Objetivo, Estima),
    aestrela_Minor([[ID]/0/Estima], InvCaminho/Comprimento/_, Objetivo),
    inverso(InvCaminho, Caminho).

aestrela_Minor(Caminhos, Caminho, Objetivo):-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [Objetivo|_]/_/_.

aestrela_Minor(Caminhos, SolucaoCaminho, Objetivo) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela_Minor(MelhorCaminho, ExpCaminhos, Objetivo),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela_Minor(NovoCaminhos, SolucaoCaminho, Objetivo).	

expande_aestrela_Minor(Caminho, ExpCaminhos, Objetivo) :-
	findall(NovoCaminho, adjacente_Minor(Caminho,NovoCaminho, Objetivo), ExpCaminhos).

adjacente_Minor([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, Objetivo) :-
    cidadesLigadasDist_Minor(Nodo, ProxNodo,Resultado),  
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + Resultado,
    distanciaEntreCidades(ProxNodo, Objetivo, Est).


% Predicado de uma ou mais cidades intermédias por onde o percurso deverá obrigatoriamente passar Depth-First

trajeto_Cidades_Intermedias(A, B, [], Caminho/Comprimento):-
    trajetoDpRec([A], B, InvCaminho, 0, Comprimento),
    inverso(InvCaminho, Caminho).

trajeto_Cidades_Intermedias(A,B,[H|T],Caminho/Comprimento):-
    trajetoDpRec([A], H, InvCaminho, 0, Comprimento1),
    inverso(InvCaminho, Caminho1),
    percurso_Cidades_Intermedias(H,B,T,CaminhoO/Comprimento2),
    Comprimento = Comprimento1 + Comprimento2,
    myappend(Caminho1,CaminhoO,Caminho).


myappend(L1,[_|T],R):- append(L1,T,R).






distanciaEntreCidades(ID1,ID2,R):- cidade(ID1,_,X1,Y1,_,_,_),cidade(ID2,_,X2,Y2,_,_,_), R is sqrt((X2-X1)^2 + (Y2-Y1)^2).



%Predicado numeroLigacoes 
numeroLigacoes(ID,R):-numeroLigacoes1(ID,R1),numeroLigacoes2(ID,R2),R is R1 + R2.
numeroLigacoes1(ID,R):- findall(ID, ligacao(ID,_,_), S), length(S,R).
numeroLigacoes2(ID,R):- findall(ID, ligacao(_,ID,_), S), length(S,R).


inverso(Xs, Ys):-
	inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs],Ys, Zs):-
	inverso(Xs, [X|Ys], Zs).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).