# JSON-Parser
JSON-Parser in Prolog

Da implementare:
	-is_value in cui il valore è un JSON.
	-skippare gli spazi bianchi prima di chiamare tutte le sottofunzioni
	-un oggetto JSON può essere un array, quindi bisogna implementare is_array
	-dunque implementare is_elements
	-bisogna restituire un oggetto JSON quindi bisogna modificare un po' tutti i metodi per far si che venga
	 restituito tale oggetto. ad esempio: 	
											?- json_parse('{"nome" : "Arthur", "cognome" : "Dent"}', O).
											O = json_obj([(”nome”, ”Arthur”), (”cognome”, ”Dent”)]).
