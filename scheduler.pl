run :- 

	consult('attends.pl'),
	schedule(A,B,C),
	display(A),
	nl,
	display(B),
	nl,	
	display(C).	


%% schedule/3
%% Generates a random examinations program.
schedule(A,B,C) :-
	getLessons(L),
	sort(L,SortedL),
	permutation(SortedL,PermL),
	take(1,3,PermL,A),
	take(4,6,PermL,B),
	take(7,8,PermL,C).


%% take/4
%% Returs a SubList based on the indexes as follows [From,.....,To].
take(From,To,List,SubList) :-
	take_aux(From,To,List,SubList,[]),
	!.


%% take_aux/5
%% Asssting function in order to extract the right SubList.
take_aux(From,To,List,SubList,Temp) :-	
	To >= From,
	nth1(To,List,Element),
	NewTo is To - 1,
	take_aux(From,NewTo,List,SubList,[Element|Temp]).

take_aux(_,_,_,SubList,SubList).


%% getLessons/1
%% Returns a list filled with the distinct lessons.
getLessons(L) :- 
	getLessons_aux(L,[]),
	!.


%% getLessons_aux/2
%% Asssting function in order to fill L list.
getLessons_aux(L,Temp) :-
	attends(_,Y),
	not(member(Y,Temp)),	
	getLessons_aux(L,[Y|Temp]).		

getLessons_aux(L,L).

	
	
