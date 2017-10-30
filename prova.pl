%%% -*- Mode: prolog -*-

project([], []).
project([X | Rest], [X1 | Rest1]) :-
    functor(X, _, Arity),
    Arity > 1,
    !,
    arg(2, X, X1),
    project(Rest, Rest1).
project([X | Rest], [X1 | Rest1]) :-
    functor(X, _, Arity),
    Arity < 2,
    !,
    project(Rest, [X1 | Rest1]).
