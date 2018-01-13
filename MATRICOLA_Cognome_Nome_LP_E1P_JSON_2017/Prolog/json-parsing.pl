%%%% -*- Mode: Prolog -*-
%%%% json-parsing.pl

%%%% Members: 
%%%% Sorrentino Alessandro 815999
%%%% Rota Claudio 816050
%%%% Mottadelli Simone Paolo 820786

%%%% "Premature optimization is the root of all evil"

% JSON parse definition:
% json_parse/2

% Case in which JSONAtom is given as an atom
json_parse(JSONAtom, Object) :-
    atom(JSONAtom),
    !,
    atom_codes(JSONAtom, AtomCodes),
    is_JSON(AtomCodes, Rest, Object),
    skip_space(Rest, []).

% Case in which JSONString is given as a string
json_parse(JSONString, Object) :-
    string(JSONString),
    !,
    atom_string(JSONAtom, JSONString),
    json_parse(JSONAtom, Object).
    

% Case in which JSONAscii is given as a list of ascii codes
json_parse(JSONAscii, Object) :-
    is_list(JSONAscii),
    !,
    is_JSON(JSONAscii, Rest, Object),
    skip_space(Rest, []).




% JSON get definition:
% json_get/3

% Case in which is given the empty list
json_get(X, [], X) :-
    !.

% Case in which a json_array is found and there might be
% more than an index
json_get(json_array(Elements), [Index | Rest], Result) :-
    number(Index),
    !,
    get_value1([Index | Rest], Elements, Result).

% Case in which a json_obj is found and there might be more
% than an attribute in Fields
json_get(json_obj(Members), [Attribute | Rest], Result) :-
    string(Attribute),
    !,
    get_value([Attribute | Rest], Members, Result).

% Case in which there is a json_obj and only an attribute
% is found
json_get(json_obj(Members), Attribute, Result) :-
    string(Attribute),
    !,
    json_get(json_obj(Members), [Attribute], Result).



% JSON object definition:
% is_JSON/3

% Case in which json is an object
is_JSON(AsciiList, Rest1, JSON_Obj) :-
    skip_space(AsciiList, AsciiList1),
    is_object(AsciiList1, Rest, JSON_Obj),
    skip_space(Rest, Rest1),
    !.

% Case in which json is an array
is_JSON(AsciiList, Rest1, JSON_Array) :-
    skip_space(AsciiList, AsciiList1),
    is_array(AsciiList1, Rest, JSON_Array),
    skip_space(Rest, Rest1),
    !.



% OBJECT definition:
% is_object/3

% Base case -> json_obj is empty
is_object([0'{| Xs], Rest, json_obj([])) :-
    skip_space(Xs, [0'} | Rest]),
    !.

% Recursive case -> json_obj is not empty
is_object([0'{ | AsciiList], Rest1, json_obj(Members)) :-
    skip_space(AsciiList, AsciiList1),
    is_members(AsciiList1, [0'} | Rest], Members),
    skip_space(Rest, Rest1),
    !.



% ARRAY definition:
% is_array/3

% Base case -> json_array is empty
is_array([0'[| Xs], Rest, json_array([])) :-
    skip_space(Xs, [0'] | Rest]),
    !.

% Recursive case -> json_array isn't empty
is_array([0'[ | AsciiList], Rest1, json_array(Elements)) :-
    skip_space(AsciiList, AsciiList1),
    is_elements(AsciiList1, [0'] | Rest], Elements),
    skip_space(Rest, Rest1),
    !.


% ELEMENTS definition:
% is_elements/3

% Recursive case -> there are more elements
is_elements(AsciiList, Rest3, [Value | MoreElements]) :-
    skip_space(AsciiList, AsciiList1),
    is_value(AsciiList1, [0', | Rest], Value),
    !,
    skip_space(Rest, Rest1),
    is_elements(Rest1, Rest2, MoreElements),
    skip_space(Rest2, Rest3).

% Base case -> there is just an element
is_elements(AsciiList, Rest1, [Value]) :-
    skip_space(AsciiList, AsciiList1),
    is_value(AsciiList1, Rest, Value),
    skip_space(Rest, Rest1),
    !.


% MEMBERS definition:
% is_members/3

% Recursive case -> there is more than a pair
is_members(AsciiList, Rest3, [Pair | MoreMembers]) :-
    skip_space(AsciiList, AsciiList1),
    is_pair(AsciiList1, [0', | Rest], Pair),
    !,
    skip_space(Rest, Rest1),
    is_members(Rest1, Rest2, MoreMembers),
    skip_space(Rest2, Rest3).

% Base case -> there is only a pair
is_members(AsciiList, Rest1, [Pair]) :-
    skip_space(AsciiList, AsciiList1),
    is_pair(AsciiList1, Rest, Pair),
    !,
    skip_space(Rest, Rest1).


% PAIR definition:
% is_pair/3

% Case in which there is a couple <attribute : value>
is_pair(AsciiList, Rest3, (Attribute, Value)) :-
    skip_space(AsciiList, AsciiList1),
    is_string(AsciiList1, [0': | Rest], Attribute),
    skip_space(Rest, Rest1),
    is_value(Rest1, Rest2, Value),
    skip_space(Rest2, Rest3).


% STRING definition:
% is_string/3

% Case in which the string starts and ends with
% double quotes
is_string([0'" | AsciiList], Rest1, String) :-
    skip_chars(AsciiList, Rest, StringCodes),
    !,
    string_codes(String, StringCodes),
    skip_space(Rest, Rest1).

% Case in which the string starts and ends with
% single quotes
is_string([0'' | AsciiList], Rest1, String) :-
    skip_chars1(AsciiList, Rest, StringCodes),
    !,
    string_codes(String, StringCodes),
    skip_space(Rest, Rest1).



% VALUE definition:
% is_value/3

% Case in which there is a string
is_value(AsciiList, Rest1, String) :-
    skip_space(AsciiList, AsciiList1),
    is_string(AsciiList1, Rest, String),
    !,
    skip_space(Rest, Rest1).

% Case in which there is a number
is_value(AsciiList, Rest1, Number) :-
    is_number(AsciiList, Rest, Number),
    skip_space(Rest, Rest1),
    !.

% Case in which there is a json value
is_value(AsciiList, Rest1, JSON_Obj) :-
    is_JSON(AsciiList, Rest, JSON_Obj),
    !,
    skip_space(Rest, Rest1).


% NUMBER definition:
% is_number/3

% Case in which there is a float number
is_number(AsciiList, Rest, Number) :-
    parse_float(AsciiList, Number, Rest),
    !.

% Case in which there is an integer number
is_number(AsciiList, Rest, Number) :-
    parse_int(AsciiList, Number, Rest),
    !.






%%% INPUT / OUTPUT FUNCTIONS DEFINITIONS:

% JSON load from file definition:
% json_load/2

json_load(FileName, JSON) :-
    atom(FileName),
    exists_file(FileName),
    read_file_to_string(FileName, JSON_obj, []),
    json_parse(JSON_obj, JSON).

% JSON write on file definition:
% json_write/2

json_write(JSON, FileName) :-
    atom(FileName),
    open(FileName, write, Out),
    write_JSON(JSON, Out),
    close(Out).



% Write json in a file definition:
% write_json/2

% Case in which there is a json_obj
write_JSON(json_obj(Members), Out) :-
    !,
    write(Out, '{'),
    write_members(Members, Out),
    write(Out, '}').

% Case in which there is a json_array
write_JSON(json_array(Elements), Out) :-
    !,
    write(Out, '['),
    write_elements(Elements, Out),
    write(Out, ']').



% Write members definition:
% write_members/2

% Base case -> empty JSON
write_members([], _Out) :-
    !.

% Base case -> string : string
write_members([(Chiave, Valore)], Out) :-
    string(Chiave),
    string(Valore),
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    writeq(Out, Valore).

% Base case -> string : number
write_members([(Chiave, Valore)], Out) :-
    string(Chiave),
    number(Valore),
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    writeq(Out, Valore).

% Base case -> string : json_Obj
write_members([(Chiave, json_obj(Members))], Out) :-
    string(Chiave),
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    write_JSON(json_obj(Members), Out).

% Recursive case -> string : json_Obj
write_members([(Chiave, json_obj(Members)) | Members1], Out) :-
    string(Chiave),
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    write_JSON(json_obj(Members), Out),
    write(Out, ', '),
    write_members(Members1, Out).

% Base case -> string : json_Array
write_members([(Chiave, json_array(Elements))], Out) :-
    string(Chiave),
    !,
    writeq(Out, Chiave),
    write(Out, " : "),
    write_JSON(json_array(Elements), Out).

% Recursive case -> more than just a member
write_members([(Chiave, Valore) | Members], Out) :-
    !,
    write_members([(Chiave, Valore)], Out),
    write(Out, ", "),
    write_members(Members, Out).



% Write Elements definition:
% write_elements/2

% Base case: empty array
write_elements([], _Out) :-
    !.
% Base case: element is a string
write_elements([Element], Out) :-
    string(Element),
    !,
    writeq(Out, Element).

% Base case: element is a number
write_elements([Element], Out) :-
    number(Element),
    !,
    writeq(Out, Element).

% Base case: element is a json_obj
write_elements([json_obj(Members)], Out) :-
    !,
    write_JSON(json_obj(Members), Out).

% Base case: element is a json_array
write_elements([json_array(Elements)], Out) :-
    !,
    write_JSON(json_array(Elements), Out).

% Recursive case: more than just an element
write_elements([Element | Elements], Out) :-
    !,
    write_elements([Element], Out),
    write(Out, ", "),
    write_elements(Elements, Out).







%%% HELPER FUNCTIONS DEFINITIONS:

% skip_chars/3
% skip_chars1/3
% This predicate skips every char up to the
% next double quote sign

% Recursive case -> backslash and double quotes are consecutive
skip_chars([0'\\, 0'" | Xs], Ris, [0'" | Rest]) :-
    !,
    skip_chars(Xs, Ris, Rest).

% Recursive case -> string started with double quotes
skip_chars([X | Xs], Ris, [X | Rest]) :-
    X \= 0'",
    !,
    skip_chars(Xs, Ris, Rest).

% Base case -> double quote found
skip_chars([X | Xs], Xs, []) :-
    X = 0'",
    !.

% Recursive case -> backslash and single quote are consecutive
skip_chars1([0'\\, 0'' | Xs], Ris, [0'' | Rest]) :-
    !,
    skip_chars1(Xs, Ris, Rest).

% Recursive case -> string started with single quote
skip_chars1([X | Xs], Ris, [X | Rest]) :-
    X \= 0'',
    !,
    skip_chars1(Xs, Ris, Rest).

% Base case -> single quote found
skip_chars1([X | Xs], Xs, []) :-
    X = 0'',
    !.

% Skip White Spaces definition:
% skip_space/2
% This predicate recives a list, skips every space
% up to the first encountered char and returns the modified list

% Recursive case -> it skips every character that's not equal to
% a whitespace
skip_space([X | List], List1) :-
    char_type(X, space),
    !,
    skip_space(List, List1).

% Base case -> now List doesn't start with whitespaces
skip_space(List, List).

% Parse_int - float definition:
% parse_int-float/3
% parse_int1/3
% This predicate parses the integer and "returns"
% everything that is not a number in Moreinput

% Main parse_int which calls parse_int1:

% Case in which number has a positive sign
parse_int(List, Integer, MoreInput) :-
    skip_space(List, [0'+ | Rest]),
    !,
    parse_int1(Rest, ListNum, MoreInput),
    ListNum \= [], % it means that we haven't found a number
    number_codes(Integer, ListNum).

% Case in which number has a negative sign
parse_int(List, Integer, MoreInput) :-
    skip_space(List, [0'- | Rest]),
    !,
    parse_int1(Rest, ListNum, MoreInput),
    ListNum \= [], % it means that we haven't found a number
    number_codes(Integer1, ListNum),
    Integer is Integer1 * (-1).
   
% Case in which number is positive but whithout plus sign
parse_int(List, Integer, MoreInput) :-
    skip_space(List, List1),
    !,
    parse_int1(List1, ListNum, MoreInput),
    ListNum \= [], % it means that we haven't found a number
    number_codes(Integer, ListNum).
    
% Recursive case -> everytime if X is a digit, it is
% collected in a Temp list and we proceede recursively
% until X isn't a digit anymore
parse_int1([X | Xs], [X | Acc], MoreInput) :-
    is_digit(X),
    !,
    parse_int1(Xs, Acc, MoreInput).

% Base case -> no more digits found
parse_int1(MoreInput, [], MoreInput) :-
    !.

% Main parse_float which calls 2 parse_int1
% Case in which the number has a positive sign
parse_float(List, Float, MoreInput) :-
    skip_space(List, [0'+ | Rest]),
    !,
    parse_int1(Rest, IntegerCodes, [0'. | Rest1]),
    parse_int1(Rest1, DecimalCodes, MoreInput),
    IntegerCodes \= [],
    DecimalCodes \= [],
    append(IntegerCodes, [0'.], FirstPart),
    append(FirstPart, DecimalCodes, FloatCodes),
    number_codes(Float, FloatCodes).

% Case in which the number has a negative sign
parse_float(List, Float, MoreInput) :-
    skip_space(List, [0'- | Rest]),
    !,
    parse_int1(Rest, IntegerCodes, [0'. | Rest1]),
    parse_int1(Rest1, DecimalCodes, MoreInput),
    IntegerCodes \= [],
    DecimalCodes \= [],
    append(IntegerCodes, [0'.], FirstPart),
    append(FirstPart, DecimalCodes, FloatCodes),
    number_codes(Float1, FloatCodes),
    Float is Float1 * (-1).
 
% Case in which the number is positive, but without 
% plus sign
parse_float(List, Float, MoreInput) :-
    skip_space(List, List1),
    !,
    parse_int1(List1, IntegerCodes, [0'. | Rest]),
    parse_int1(Rest, DecimalCodes, MoreInput),
    IntegerCodes \= [],
    DecimalCodes \= [],
    append(IntegerCodes, [0'.], FirstPart),
    append(FirstPart, DecimalCodes, FloatCodes),
    number_codes(Float, FloatCodes).    

% Get_value - Get_value1 definition:
% Get_value/3
% Get_value1/3
% This predicate gets an attribute as parameter
% and "returns" the associated value

% Array cases:

% Base case -> it returns the index'ed element
get_value1([Index], Elements, Value) :-
    number(Index),
    !,
    nth0(Index, Elements, Value).

% Recursive case
get_value1([Index | Rest], Elements, Value) :-
    number(Index),
    nth0(Index, Elements, json_array(Elements1)),
    !,
    get_value1(Rest, Elements1, Value).

% Recursive case
get_value1([Index | Rest], Elements, Value) :-
    number(Index),
    nth0(Index, Elements, json_obj(Members)),
    !,
    json_get(json_obj(Members), Rest, Value).


% Object cases:

% Base case -> it returns the Value of Attribute
get_value([Attribute], [(Attribute, Value)| _], Value) :-
    !.

% Base case -> it returns the index'ed element in the
% json_array
get_value([Attr, Index], [(Attr, json_array(Elements)) | _], Val) :-
    number(Index),
    !,
    nth0(Index, Elements, Val).

% Case in which Attribute has been found and its value is a
% json_array
get_value([Attr | Rest], [(Attr, json_array(Elements)) | _], Val) :-
    !,
    json_get(json_array(Elements), Rest, Val).

% Case in which Attribute has been found and its value is a json_obj
get_value([Attr | Rest], [(Attr, json_obj(Members)) | _], Val) :-
   !,
   json_get(json_obj(Members), Rest, Val).

% Recursive case -> Attribute hasn't been found yet
get_value([Attr | Rest], [(X, _) | Members], Val) :-
    X \= Attr,
    !,
    get_value([Attr | Rest], Members, Val).

%%%% END - OF - FILE - json-parsing.pl







