%%%% -*- Mode: Prolog -*-
%%%% JSON-Parser.pl
%%%% Premature optimization is the root of all evil

% JSON parse definition
% json_parse/2

json_parse(Atom, _JSONString) :-  % ***************** RIMUOVERE UNDERSCORE *****************
    atom(Atom),
    atom_codes(Atom, AtomCodes),
    is_JSON(AtomCodes, Rest),
    skip_white(Rest, []).

% JSON object definition
% is_JSON/2

is_JSON(AsciiList, Rest1) :-
        skip_white(AsciiList, AsciiList1),
    is_object(AsciiList1, Rest),
    skip_white(Rest, Rest1),
    !.

is_JSON(AsciiList, Rest1) :- 
        skip_white(AsciiList, AsciiList1),
        is_array(AsciiList1, Rest),
    skip_white(Rest, Rest1),
    !.


% OBJECT definition
% is_object/2

is_object([0'{| Xs], Rest) :-
    skip_white(Xs, [0'} | Rest]),
    !.

is_object([0'{ | AsciiList], Rest1) :-   % Caso di più object o ultimo
        skip_white(AsciiList, AsciiList1),
    is_members(AsciiList1, [0'} | Rest]),
    skip_white(Rest, Rest1),
    !.

% ARRAY definition
% is_array/2

is_array([0'[| Xs], Rest) :-
    skip_white(Xs, [0'] | Rest]),
    !.

is_array([0'[ | AsciiList], Rest1) :-   % Caso di più array o ultimo
        skip_white(AsciiList, AsciiList1),
    is_elements(AsciiList1, [0'] | Rest]),
    skip_white(Rest, Rest1),
    !.

% ELEMENTS definition
% is_elements/2
is_elements(AsciiList, Rest3) :-
        skip_white(AsciiList, AsciiList1),
    is_value(AsciiList1, [0', | Rest]),
    !,
    skip_white(Rest, Rest1),
    is_elements(Rest1, Rest2),
    skip_white(Rest2, Rest3).

is_elements(AsciiList, Rest1) :-
        skip_white(AsciiList, AsciiList1),
    is_value(AsciiList1, Rest),
    skip_white(Rest, Rest1),
    !.

% MEMBERS definition
% is_members/2
is_members(AsciiList, Rest3) :-
        skip_white(AsciiList, AsciiList1),
    is_pair(AsciiList1, [0', | Rest]),
    !,
    skip_white(Rest, Rest1),
    is_members(Rest1, Rest2),
    skip_white(Rest2, Rest3).

is_members(AsciiList, Rest1) :-
        skip_white(AsciiList, AsciiList1),
    is_pair(AsciiList1, Rest),
    !,
    skip_white(Rest, Rest1).

% PAIR definition
% is_pair/2
is_pair(AsciiList, Rest3) :-
        skip_white(AsciiList, AsciiList1),
    is_string(AsciiList1, [0': | Rest]),
    skip_white(Rest, Rest1),
    is_value(Rest1, Rest2),
    skip_white(Rest2, Rest3).

% STRING definition
% is_string/2
is_string([0'" | AsciiList], Rest1) :-
    skip_chars(AsciiList, Rest),
    !,
    skip_white(Rest, Rest1).

is_string([0'' | AsciiList], Rest1) :-
    skip_chars1(AsciiList, Rest),
    !,
    skip_white(Rest, Rest1).

% VALUE definition
% is_value/2
is_value(AsciiList, Rest1) :-
        skip_white(AsciiList, AsciiList1),
    is_string(AsciiList1, Rest),
    !,
    skip_white(Rest, Rest1).

is_value(AsciiList, Rest1) :-
    is_number(AsciiList, Rest),
    skip_white(Rest, Rest1),
    !.

is_value(AsciiList, Rest1) :-
    is_JSON(AsciiList, Rest),
    !,
    skip_white(Rest, Rest1).

% NUMBER definition
% is_number/2
is_number(AsciiList, Rest) :-
    parse_float(AsciiList, Num, Rest),
    !.

is_number(AsciiList, Rest) :-
    parse_int(AsciiList, Num, Rest),
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
    ListNum \= [],
    number_codes(Integer, ListNum).

parse_int1([X | Xs], [X | Acc], MoreInput) :-
    is_digit(X),
    !,
    parse_int1(Xs, Acc, MoreInput).

parse_int1(MoreInput, [], MoreInput) :-
    !.

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


