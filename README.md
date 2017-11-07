# JSON-Parser
JSON-Parser in Prolog

Da implementare:
	-is_value in cui il valore è un JSON.
	-is_string che accetta stringhe con apici singoli, ad esempio:  'sono una stringa'.
	-conseguentemente risolvere il problema in cui ci possono essere apici doppi o singoli nella stringa in input
	-skippare gli spazi bianchi prima di chiamare tutte le sottofunzioni
	-un oggetto JSON può essere un array, quindi bisogna implementare is_array
	-dunque implementare is_elements
	-bisogna restituire un oggetto JSON quindi bisogna modificare un po' tutti i metodi per far si che venga
	 restituito tale oggetto. ad esempio: 	
											?- json_parse('{"nome" : "Arthur", "cognome" : "Dent"}', O).
											O = json_obj([(”nome”, ”Arthur”), (”cognome”, ”Dent”)]).
