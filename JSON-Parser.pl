%%%% -*- Mode: Prolog -*-
%%%% JSON-Parser.pl
%%%% Premature optimization is the root of all evil

% JSON parse definition
% json_parse/2

json_parse(JSONString, Object) :-
    atom(JSONString),
    !,
    atom_codes(JSONString, AtomCodes),
    is_JSON(AtomCodes, Rest, Object),
    skip_space(Rest, []).
    
json_parse(JSONString, Object) :-
    string(JSONString),
    !,
    atom_string(JSONAtom, JSONString),
    json_parse(JSONAtom, Object).

% JSON get definition
% json_get/3

json_get(json_array(Elements), [Index | Rest], Result) :-
    number(Index),
    !,
    get_value1([Index | Rest], Elements, Result).

json_get(json_obj(Members), [Attribute | Rest], Result) :-
    string(Attribute),
    !,
    get_value([Attribute | Rest], Members, Result).

json_get(json_obj(Members), Attribute, Result) :-
    string(Attribute),
    !,
    json_get(json_obj(Members), [Attribute], Result).

% JSON object definition
% is_JSON/3

is_JSON(AsciiList, Rest1, JSON_Obj) :-
    skip_space(AsciiList, AsciiList1),
    is_object(AsciiList1, Rest, JSON_Obj),
    skip_space(Rest, Rest1),
    !.

is_JSON(AsciiList, Rest1, JSON_Array) :- 
    skip_space(AsciiList, AsciiList1),
    is_array(AsciiList1, Rest, JSON_Array),
    skip_space(Rest, Rest1),
    !.


% OBJECT definition
% is_object/3

is_object([0'{| Xs], Rest, json_obj([])) :-
    skip_space(Xs, [0'} | Rest]),
    !.

is_object([0'{ | AsciiList], Rest1, json_obj(Members)) :-   % Caso di più object o ultimo
    skip_space(AsciiList, AsciiList1),
    is_members(AsciiList1, [0'} | Rest], Members),
    skip_space(Rest, Rest1),
    !.

% ARRAY definition
% is_array/3

is_array([0'[| Xs], Rest, json_array([])) :-
    skip_space(Xs, [0'] | Rest]),
    !.

is_array([0'[ | AsciiList], Rest1, json_array(Elements)) :-   % Caso di più array o ultimo
    skip_space(AsciiList, AsciiList1),
    is_elements(AsciiList1, [0'] | Rest], Elements),
    skip_space(Rest, Rest1),
    !.

% ELEMENTS definition
% is_elements/3
is_elements(AsciiList, Rest3, [Value | MoreElements]) :-
    skip_space(AsciiList, AsciiList1),
    is_value(AsciiList1, [0', | Rest], Value),
    !,
    skip_space(Rest, Rest1),
    is_elements(Rest1, Rest2, MoreElements),
    skip_space(Rest2, Rest3).

is_elements(AsciiList, Rest1, [Value]) :-
    skip_space(AsciiList, AsciiList1),
    is_value(AsciiList1, Rest, Value),
    skip_space(Rest, Rest1),
    !.

% MEMBERS definition
% is_members/3
is_members(AsciiList, Rest3, [Pair | MoreMembers]) :-
    skip_space(AsciiList, AsciiList1),
    is_pair(AsciiList1, [0', | Rest], Pair),
    !,
    skip_space(Rest, Rest1),
    is_members(Rest1, Rest2, MoreMembers),
    skip_space(Rest2, Rest3).

is_members(AsciiList, Rest1, [Pair]) :-
    skip_space(AsciiList, AsciiList1),
    is_pair(AsciiList1, Rest, Pair),
    !,
    skip_space(Rest, Rest1).

% PAIR definition
% is_pair/3
is_pair(AsciiList, Rest3, (Attribute, Value)) :-
    skip_space(AsciiList, AsciiList1),
    is_string(AsciiList1, [0': | Rest], Attribute),
    skip_space(Rest, Rest1),
    is_value(Rest1, Rest2, Value),
    skip_space(Rest2, Rest3).

% STRING definition
% is_string/3
is_string([0'" | AsciiList], Rest1, String) :-
    skip_chars(AsciiList, Rest, StringCodes),
    !,
    string_codes(String, StringCodes),
    skip_space(Rest, Rest1).

is_string([0'' | AsciiList], Rest1, String) :-
    skip_chars1(AsciiList, Rest, StringCodes),
    !,
    string_codes(String, StringCodes),
    skip_space(Rest, Rest1).

% VALUE definition
% is_value/3
is_value(AsciiList, Rest1, String) :-
    skip_space(AsciiList, AsciiList1),
    is_string(AsciiList1, Rest, String),
    !,
    skip_space(Rest, Rest1).

is_value(AsciiList, Rest1, Number) :-
    is_number(AsciiList, Rest, Number),
    skip_space(Rest, Rest1),
    !.

is_value(AsciiList, Rest1, JSON_Obj) :-
    is_JSON(AsciiList, Rest, JSON_Obj),
    !,
    skip_space(Rest, Rest1).

% NUMBER definition
% is_number/3
is_number(AsciiList, Rest, Number) :-
    parse_float(AsciiList, Number, Rest),
    !.

is_number(AsciiList, Rest, Number) :-
    parse_int(AsciiList, Number, Rest),
    !.

%%%% I/O
json_load(FileName, JSON) :-
    atom(FileName),
    exists_file(FileName),
    read_file_to_string(FileName, JSON_obj, []),
    json_parse(JSON_obj, JSON).

json_write(JSON, FileName) :-
    atom(FileName),
    open(FileName, write, Out),
    write_JSON(JSON, Out),
    close(Out).
    
write_JSON(json_obj(Members), Out) :-
    !,
    write(Out, '{'),
    write_members(Members, Out),
    write(Out, '}').
    
write_JSON(json_array(Elements), Out) :-
    !,
    write(Out, '['),
    write_elements(Elements, Out),
    write(Out, ']').

%%% Write members
% Empty JSON
write_members([], _Out) :-
    !.

% string : string
write_members([(Chiave, Valore)], Out) :-
    string(Chiave),
    string(Valore), 
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    writeq(Out, Valore).

% string : number
write_members([(Chiave, Valore)], Out) :-
    string(Chiave),
    number(Valore), 
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    writeq(Out, Valore).
    
% string : JSON_Obj
write_members([(Chiave, json_obj(Members))], Out) :-
    string(Chiave), 
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    write_JSON(json_obj(Members), Out).
    
% string : JSON_Obj + more members  
write_members([(Chiave, json_obj(Members)) | Members1], Out) :-
    string(Chiave),
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    write_JSON(json_obj(Members), Out),
    write(Out, ', '),
    write_members(Members1, Out).
    
% string : JSON_Array
write_members([(Chiave, json_array(Elements))], Out) :-
    string(Chiave), 
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    write_JSON(json_array(Elements), Out).
    
% string : string
write_members([(Chiave, Valore) | Members], Out) :-
    !,
    write_members([(Chiave, Valore)], Out),
    write(Out, ", "),
    write_members(Members, Out).
    
%%% Write Elements
% Empty ARRAY
write_elements([], _Out) :-
    !.
   
write_elements([Element], Out) :-
    string(Element),
    !,
    writeq(Out, Element).
    
write_elements([Element], Out) :-
    number(Element),
    !,
    writeq(Out, Element).
    
write_elements([json_obj(Members)], Out) :-
    !,
    write_JSON(json_obj(Members), Out).

write_elements([json_array(Elements)], Out) :-
    !,
    write_JSON(json_array(Elements), Out).
    
write_elements([Element | Elements], Out) :-
    !,
    write_elements([Element], Out),
    write(Out, ", "),
    write_elements(Elements, Out).
    
%%%% Helper Functions Definitions

% SKIP CHARS
% skip_chars/3
/*  This predicate skips every char up to the next double quote sign */

skip_chars([0'\\, 0'" | Xs], Ris, [0'" | Rest]) :-
    !,
    skip_chars(Xs, Ris, Rest).

skip_chars([X | Xs], Ris, [X | Rest]) :-
    X \= 0'",
    !,
    skip_chars(Xs, Ris, Rest).  
    
skip_chars([X | Xs], Xs, []) :-
    X = 0'",
    !.

skip_chars1([0'\\, 0'' | Xs], Ris, [0'' | Rest]) :-
    !,
    skip_chars1(Xs, Ris, Rest). 
    
skip_chars1([X | Xs], Ris, [X | Rest]) :-
    X \= 0'',
    !,
    skip_chars1(Xs, Ris, Rest).

skip_chars1([X | Xs], Xs, []) :-
    X = 0'',
    !.

% Skip White Spaces definition
% skip_space/2
/*  This predicate recives a list, skips every space
    up to the first encountered char and returns the modified list*/

skip_space([X | List], List1) :-
    char_type(X, space),
    !,
    skip_space(List, List1).

skip_space(List, List).

% Parse_int - float definition
% parse_int-float/3
% parse_int1/3
/*  This predicate parses the integer and "returns" everything
    that is not a number in Moreinput */

parse_int(List, Integer, MoreInput) :-
    skip_space(List, List1),
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
    skip_space(List, List1),
    parse_int1(List1, IntegerCodes, [0'. | Rest]),
    parse_int1(Rest, DecimalCodes, MoreInput),
    IntegerCodes \= [],
    DecimalCodes \= [],
    append(IntegerCodes, [0'.], FirstPart),
    append(FirstPart, DecimalCodes, FloatCodes),
    number_codes(Float, FloatCodes).
    
% Get_value - Get_value1 definition
% Get_value/3
% Get_value1/3
/* This predicate gets the attribute as parameter and "returns" the associated value */

%caso array

get_value1([Index], Elements, Value) :-
    number(Index),
    !,
    nth0(Index, Elements, Value).

get_value1([Index | Rest], Elements, Value) :-
    number(Index),
    nth0(Index, Elements, json_array(Elements1)),
    !,
    get_value1(Rest, Elements1, Value).
   
get_value1([Index | Rest], Elements, Value) :-
    number(Index),
    nth0(Index, Elements, json_obj(Members)),
    !,
    json_get(json_obj(Members), Rest, Value).


% caso object

get_value([Attribute], [(Attribute, Value)| _], Value) :-
    !.

get_value([Attribute, Index], [(Attribute, json_array(Elements)) | _], Value) :- 
    number(Index),
    !,
    nth0(Index, Elements, Value).
    
get_value([Attribute | Rest], [(Attribute, json_array(Elements)) | _], Value) :-
    !,
    json_get(json_array(Elements), Rest, Value). 
    
get_value([Attribute | Rest], [(Attribute, json_obj(Members)) | _], Value) :-
   !,
   json_get(json_obj(Members), Rest, Value).

get_value([Attribute | Rest], [(X, _) | Members], Value) :-
    X \= Attribute,
    !,
    get_value([Attribute | Rest], Members, Value).
    
%%%% End of file - JSON-Parser.pl






