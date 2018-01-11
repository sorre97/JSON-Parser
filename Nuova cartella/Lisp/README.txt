Claudio Rota 816050
Alessandro Sorrentino 815999
Mottadelli Simone Paolo 820786


Di seguito sono riportate le definizioni delle funzioni principali
della libreria JSON in Lisp:


- JSON-PARSE DEFINIZIONE:

json-parse : Lisp String -> JSON Object

*json-parse* costruisce una struttura dati che rappresenta un'oggetto
JSON a partire dalla sua rappresentazione come una stringa Lisp, 
la quale viene passata in input come argomento alla funzione.
Se la stringa non rispetta gli standard JSON viene segnalato un errore.


- JSON-GET DEFINIZIONE:

json-get : JSON Object x fields -> Attribute

*json-get* accetta un oggetto JSON e una serie di "campi" in input e recupera 
l'oggetto corrispondente seguendo tale catena di "campi".
Un campo rappresentato da N (con N un numero maggiore o uguale a 0) rappresenta 
un indice di un array JSON.
Se fields è vuoto o se l'indice dell'array json è out of bound o se non è
stato possibile risalire all'oggetto richiesto, allora viene segnalato un'errore.


- JSON-LOAD DEFINIZIONE:

json-load : Filepath -> JSON Object

*json-load* riceve in input il file specificato dal percorso Filepath e restituisce
un oggetto JSON a partire dalla stringa contenuta all'interno del file, se questo 
esiste, altrimenti viene segnalato un errore.


- JSON-WRITE DEFINIZIONE:

json-write : JSON Object x Filepath -> NIL


*json-write* scrive l'oggetto JSON (JSON Object) in sintassi JSON nel file 
specificato da Filepath. Si assume che l'oggetto JSON sia valido e dunque
sintatticamente corretto. Possono essere segnalati degli errori di I/O.