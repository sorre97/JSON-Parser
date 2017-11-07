%%%% -*- Mode: Prolog -*-
%%%% JSON-Parser.pl
%%%% Premature optimization is root of all evil

% JSON parse definition
% json_parse/2
json_parse(String, JSONString) :-
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
    is_members(RestModified),
    !.
    
% MEMBERS definition
% is_members/1
is_members(AsciiList) :-
    is_pair(AsciiList, [0', | Rest]),
    !,  % to check
    is_member(Rest).
    
is_members(AsciiList) :-
    is_pair(AsciiList, []),
    !. % to check
    
% PAIR definition
% is_pair/2 
is_pair(AsciiList, Rest) :-
    is_string(AsciiList, [0': | Rest2]),
    is_string(Rest2, Rest). %todo<------
    %is_value(Rest2, Rest).
    

% STRING definition
% is_string/2
is_string([0'" | AsciiList], Rest) :-
        skip_chars(AsciiList, Rest).
        


% VALUE definition
% is_value/2


%%%% Helper Functions Definitions

% Delete Last definition
% delete_last/3
/*  This predicate operates on List and 
        returns two elements, Ris which is 
        List without the last element and
        Element which is the removed element    */
    
delete_last(List, Ris, Element) :-
    reverse(List, [Element | T]),
    reverse(T, Ris).
    
% SKIP CHARS
% skip_chars/2

skip_chars([X | Xs], Ris) :-
    X \= 0'",
    !,
    skip_chars(Xs, Ris).
    
skip_chars([X | Xs], Xs) :-
    X = 0'",
    !.

%%%% End JSON-Parser.pl

