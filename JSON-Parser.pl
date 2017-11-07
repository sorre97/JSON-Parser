%%%% -*- Mode: Prolog -*-
%%%% JSON-Parser.pl
%%%% Premature optimization is root of all evil

% JSON parse definition
% json_parse/2
json_parse(String, _JSONString) :-  % ***************** RIMUOVERE UNDERSCORE *****************
    string_codes(String, StringCodes),
    is_JSON(StringCodes).
    
% JSON object definition
% is_JSON/1
is_JSON(X) :-
    is_object(X),
    !.

/*
is_JSON(X) :-
    is_array(X),
    !.
*/

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
    is_members(Rest).
    
is_members(AsciiList) :-
    is_pair(AsciiList, []),
    !. % to check
    
% PAIR definition
% is_pair/2 
is_pair(AsciiList, Rest) :-
    is_string(AsciiList, [0': | Rest2]),
    is_value(Rest2, Rest).
    

% STRING definition
% is_string/2
is_string([0'" | AsciiList], Rest) :-
        skip_chars(AsciiList, Rest).
        

% VALUE definition
% is_value/2
is_value(AsciiList, Rest) :-
        is_string(AsciiList, Rest),
    !.
    
is_value(AsciiList, Rest) :-
        is_number(AsciiList, Rest).
    
/*
is_value(AsciiList, Rest) :-
        is_JSON(AsciiList, Rest),
    !.
*/
   
% NUMBER definition
% is_number/2

is_number(AsciiList, Rest) :-
        parse_int(AsciiList, Num, MoreInput),
    !.
    
is_number(AsciiList, Rest) :-
        parse_float(AsciiList, Num, MoreInput),
    !.

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

/*  This predicate skips every char up to the next double quote sign */
    
skip_chars([X | Xs], Ris) :-
    X \= 0'",
    !,
    skip_chars(Xs, Ris).
    
skip_chars([X | Xs], Xs) :-
    X = 0'",
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
        
    
% Parse Int definition
% parse_int/3
% parse_int/5
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


