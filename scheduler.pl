:- dynamic my_counter/1.    % my_counter(Value:int).
:- dynamic metrics/2.       % metrics(Score:int, Errors:int)
:- dynamic program/3.       % program(A:list, B:list, C:list).

% == UTILITY PREDICATES START == %

%! increment_counter(+Diff:int).
%  Increments the global variable 'my_counter' by the amount specified.
increment_counter(Diff) :-
    retract(my_counter(OldValue)),      % pop the current counter's value
    NewValue is OldValue + Diff,        % increment it by Diff
    assertz(my_counter(NewValue)), !.   % push it back to the memory

%! get_key_value(+Pair:tuple, -K:any, -V:any).
%  Extracts the key and value pair from a tuple.
get_key_value(Pair,K,V) :- Pair =.. [_,K|[V]].

%! filter(+Value:int, +Target:int).
%  Filters based on an equality check between the value and the target.
filter(Value,Target) :- Value \== Target, !, fail.   % if the value doesn't match the target, cut alternatives and fail
filter(_, _).                                        % in any other case, return succesfully

% == UTILITY PREDICATES END == %

%! schedule(-A:list, -B:list, -C:list).
%  Generates a random exam schedule.
%  Provides all permutations through backtracking.
schedule(A,B,C) :-
    findall(Course,(attends(_,Course)),L),  % get all courses
    sort(L, Sorted),                        % sort them to remove duplicates
    permutation(Sorted,PermL),              % permutate them to generate all results
    length(A,3), length(B,3),               % force A and B to have a length of 3
    append(A,Tmp,PermL), append(B,C,Tmp).   % split the list to A, B and C

%! schedule_errors(+A:list, +B:list, +C:list, -E:int).
%  Counts the amount of students that are dissatisfied with a schedule.
schedule_errors(A,B,_C,E) :-
    assertz(my_counter(0)),                     % initialize the counter with 0
    findall(Student,(attends(Student,_)),L),    % get all students
    sort(L,SortedL),                            % sort to remove duplicates
    schedule_errors_aux(A,B,SortedL),           % call the auxiliary predicate
    retract(my_counter(E)), !.                  % get the counter's value

%! schedule_errors_aux(+A:list, +B:list, +Students:list).
%  Auxiliary predicate used to recusrively count schedule "errors".
schedule_errors_aux(A,B,Students) :-
    select(S,Students,Rest),            % pop the first student from the list
    findall(C,(attends(S,C)),Courses),  % get all courses that the student attends
    schedule_errors_aux2(A,Courses),    % check for errors in A
    schedule_errors_aux2(B,Courses),    % check for errors in B
    schedule_errors_aux(A,B,Rest).      % recursively call for the rest of the students
    
schedule_errors_aux(_,_,[]) :- !.       % return when the list is empty

%! schedule_errors_aux2(+Week:list, +Courses:list).
%  Secondary auxiliary predicate to update the counter when an error exists.
schedule_errors_aux2(Week,Courses) :-
    subset(Week,Courses),       % check if a student's course list is a superset of the week's list
    increment_counter(1), !.    % then increase the error by 1

schedule_errors_aux2(_,_).      % alternative predicate if the subset clause fails -- do nothing

%! minimal_schedule_errors(-A:list, -B:list, -C:list, -E:int).
%  Calculates the schedule with the fewest possible "errors".
minimal_schedule_errors(A,B,C,E) :-
    % generate all possible schedules and calculate their corresponding errors
    bagof(E-program(D1,D2,D3),(schedule(D1,D2,D3),schedule_errors(D1,D2,D3,E)),P),
    keysort(P,Sorted),              % sort the results based on the key (errors)
    append([First],_,Sorted),       % get the first value from the sorted list
    get_key_value(First,MinE,_),    % extract the error value from the tuple
    member(Pair,Sorted),            % get a schedule from the genrated list
    get_key_value(Pair,E,Prog),     % extract the program and the errors
    filter(E,MinE),                 % filter out results that don't have the min amount of errors
    program(A,B,C) = Prog.          % extract the schedule's lists from the program

%! score_schedule(+A:list, +B:list, +C:list, -S:int).
%  Scores a given schedule based on the students' preferences.
score_schedule(A,B,C,S) :-
    assertz(my_counter(0)),                     % initialize counter to 0
    findall(Student,(attends(Student,_)),L),    % get all students that attend a class
    sort(L,Sorted),                             % sort them to remove duplicates
    score_schedule_aux(A,B,C,Sorted),           % call auxiliary predicate to calculate score
    retract(my_counter(S)), !.                  % pop the value from the counter

%! score_schedule_aux(+A:list, +B:list, +C:list, +Students:list).
%  Auxiliary predicate that checks for student preferences given a certain schedule.
score_schedule_aux(_,_,_,[]) :- !.                  % return when there are no more students

score_schedule_aux(A,B,C,Students) :-
    select(Student,Students,Rest),                  % pop a student from the list
    findall(Course,(attends(Student,Course)),L),    % find all courses they attend
    score_schedule_aux2(A,L),                       % call secondary predicate for the first week
    score_schedule_aux2(B,L),                       %           ----           for the second week
    score_schedule_aux2(C,L),                       %           ----           for the third week
    score_schedule_aux(A,B,C,Rest).                 % recursion to check the rest of the students list

%! score_schedule_aux2(+Week:list, +Courses:list).
%  Checks the given lists and adjusts the counter for the score accordingly.
score_schedule_aux2(Week,Courses) :-
    length(Week,3),          % if the week has 3 courses
    subset(Week,Courses),    % and they're all in the student's list
    increment_counter(-7).   % then give a penalty of -7

score_schedule_aux2(Week,Courses) :-
    length(Week,2),          % if the week has 2 courses
    subset(Week,Courses),    % check if they're all in the student's list
    increment_counter(1).    % then increase the score by 1

score_schedule_aux2(Week,Courses) :-
    length(Week,3),         % if the week has 3 courses
    append(MW,[_],Week),    % extract the first 2 of them
    subset(MW,Courses),     % check if they're in the student's list
    increment_counter(1).   % then increase the score by 1

score_schedule_aux2(Week,Courses) :-
    length(Week,3),         % if the week has 3 courses
    append([_],WF,Week),    % extract the last 2 of them
    subset(WF,Courses),     % check if they're in the student's list
    increment_counter(1).   % then increase the score by 1

score_schedule_aux2(Week,Courses) :-
    length(Week,3),         % if the week has 3 courses
    append(MW,[F],Week),    % extract the last one
    append([M],[_],MW),     % extract the first one
    append([M],[F],MF),     % merge them
    subset(MF,Courses),     % check if they're in the student's list
    increment_counter(3).   % then increase the score by 3

score_schedule_aux2(Week,Courses) :-
    intersection(Week,Courses,Common),   % get the common courses from this week and the student's list
    length(Common,1),                    % check if there's only 1 course in common
    increment_counter(7).                % then increase the score by 7

score_schedule_aux2(_,_).                % do nothing if all the cases above fail

%! maximum_score_schedule(-A:list, -B:list, -C:list, -E:int, -S:int).
%  Returns the best schedules based on both errors and score.
maximum_score_schedule(A,B,C,E,S) :-
    % collect all schedules with the minimal error and score them accordingly
    bagof(metrics(S,E)-program(A,B,C),(minimal_schedule_errors(A,B,C,E),score_schedule(A,B,C,S)),Results),
    keysort(Results,Sorted),        % sort results based on the score
    reverse(Sorted,Rev),            % reverse the list to get the greatest one
    append([First],_,Rev),          % extract the result with the top score
    get_key_value(First,MaxM,_),    % get the max metric (score - error)
    member(Pair,Rev),               % get a result from the reverse sorted list
    get_key_value(Pair,M,Prog),     % extract the metric and the program from the pair
    filter(M,MaxM),                 % filter out pairs that don't have the max metric
    program(A,B,C) = Prog,          % extract the schedule lists from the program
    metrics(S,E) = M.               % extract the score and error from the metric
