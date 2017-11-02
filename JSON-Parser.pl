%%%% -*- Mode: Prolog -*-
%%%% JSON-Parser.pl
%%%% Premature optimization is root of all evil

% JSON parse definition
% json_parse/2
json_parse(String) :-
    string_codes(String, StringCodes),
    is_JSON(StringCodes).

% JSON object definition
% is_JSON/1
is_JSON(X) :-
    is_object(X),
    !.

is_JSON(X) :-
    is_array(X),
    !.

% OBJECT definition
% is_object/1
is_object([X, Y]) :-
    X = 0'{,
    Y = 0'},
    !.

is_object(AsciiList) :-
    AsciiList = [0'{ | Rest],
    delete_last(Rest, RestModified, LastElement),
    LastElement = 0'},
    is_member(RestModified),
    !.

% MEMBERS definition
% is_members/1
is_members(AsciiList) :-
    is_pair(AsciiList). %__________________________________________________________continua qui

%%%% Helper Functions Definition

% Delete Last definition
% delete_last/3
/*This predicate operates on List and
returns two elements, Ris which is
List without the last element and
Element which is the removed element	*/

delete_last(List, Ris, Element) :-
    reverse(List, [Element | T]),
    reverse(T, Ris).

%%%% End JSON-Parser.pl
%
%   % is_pair ritorna due valori, l'oggetto parsato e una lsita che contiene tutto ciò che c'è dopo la , compresa, se il primo elemento è una virgola
% richiamo is_member, se ho lista vuota ho solo un pair e se non ho nessuno dei due casi fallisco, ho es 123.123a
