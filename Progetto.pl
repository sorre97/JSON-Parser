%%%% -*- Mode: Prolog -*-
%%%% JSON-Parser.pl
%%%% Premature optimization is the root of all evil

% JSON parse definition
% json_parse/2

json_parse(Atom, _JSONString) :-  % ***************** RIMUOVERE UNDERSCORE *****************
    atom(Atom),
    atom_codes(Atom, AtomCodes),
    is_JSON(AtomCodes, _).

% JSON object definition
% is_JSON/2

%is_JSON(AsciiList, _) :-
%    is_object(AsciiList, []),
%    !.

is_JSON(AsciiList, Rest) :-
    is_object(AsciiList, Rest).
%    !.

/*
is_JSON(X, Rest) :-   %***************** DA IMPLEMENTARE *****************
    is_array(X, Rest),
    !.
*/

% is_object definition
% is_object/2

is_object([0'{, 0'} | Xs], Xs) :-
    !.

is_object([0'{ | AsciiList], Rest) :-   % Caso di più object o ultimo
    is_members(AsciiList, [0'} | Rest]),
    !.


% MEMBERS definition
% is_members/2
is_members(AsciiList, Rest2) :-
    is_pair(AsciiList, [0', | Rest]),
    !,
    is_members(Rest, Rest2).

is_members(AsciiList, Rest) :-
    is_pair(AsciiList, Rest),
    !.

% PAIR definition
% is_pair/2
is_pair(AsciiList, Rest) :-
    is_string(AsciiList, [0': | Rest2]),
    is_value(Rest2, Rest).

% STRING definition
% is_string/2
is_string([0'" | AsciiList], Rest) :-
    skip_chars(AsciiList, Rest),
    !.

is_string([0'' | AsciiList], Rest) :-
    skip_chars1(AsciiList, Rest),
    !.

% VALUE definition
% is_value/2
is_value(AsciiList, Rest) :-
    is_string(AsciiList, Rest),
    !.

is_value(AsciiList, Rest) :-
    is_number(AsciiList, Rest),
    !.

is_value(AsciiList, Rest) :-
    is_JSON(AsciiList, Rest),
    !.

% NUMBER definition
% is_number/2
is_number(AsciiList, Rest) :-
    parse_int(AsciiList, Num, Rest),
    !.

is_number(AsciiList, Rest) :-
    parse_float(AsciiList, Num, Rest),
    !.

%%%% Helper Functions Definitions

% SKIP CHARS
% skip_chars/2
/*  This predicate skips every char up to the next double quote sign */

skip_chars([X | Xs], Ris) :-
    X \= 0'",
    !,
    skip_chars(Xs, Ris).

skip_chars([X | Xs], Xs) :-
    X = 0'",
    !.

skip_chars1([X | Xs], Ris) :-
    X \= 0'',
    !,
    skip_chars1(Xs, Ris).

skip_chars1([X | Xs], Xs) :-
    X = 0'',
    !.

% Skip White Spaces definition
% skip_white/2
/*  This predicate recives a list, skips every space
    up to the first encountered char and returns the modified list*/

skip_white([X | List], List1) :-
    char_type(X, white),
    !,
    skip_white(List, List1).

skip_white(List, List).

% Parse_int - float definition
% parse_int-float/3
% parse_int1/3
/*  This predicate parses the integer and returns everything
    that is not a number in Moreinput */

parse_int(List, Integer, MoreInput) :-
    skip_white(List, List1),
    parse_int1(List1, ListNum, MoreInput),
    number_codes(Integer, ListNum).

parse_int1([X | Xs], [X | Acc], MoreInput) :-
    is_digit(X),
    !,
    parse_int1(Xs, Acc, MoreInput).

parse_int1(MoreInput, [], MoreInput).

parse_float(List, Float, MoreInput) :-
    skip_white(List, List1),
    parse_int1(List1, IntegerCodes, [0'. | Rest]),
    parse_int1(Rest, DecimalCodes, MoreInput),
    IntegerCodes \= [],
    DecimalCodes \= [],
    append(IntegerCodes, [0'.], FirstPart),
    append(FirstPart, DecimalCodes, FloatCodes),
    number_codes(Float, FloatCodes).

%%%% End JSON-Parser.pl

