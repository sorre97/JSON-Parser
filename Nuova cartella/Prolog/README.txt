Claudio Rota 816050
Alessandro Sorrentino 815999
Mottadelli Simone Paolo 820786


Di seguito sono riportate le definizioni delle funzioni principali
della libreria JSON in Prolog:


- JSON-PARSE DEFINIZIONE:

json_parse(atom/string/ascii-list, Object):

Questo predicato ritorna true se riesce a costruire una struttura dati che 
rappresenta un'oggetto JSON a partire dalla sua rappresentazione come stringa, atomo
o lista di ascii, i quali vengono passati in input come argomento del predicato.


- JSON-GET DEFINIZIONE:

json_get(JSON_Object, Campi, Attributo):

Questo predicato ritorna vero se l'attributo recuperato dalla lista Campi in JSON_Object 
è Attributo. Un campo rappresentato da N (con N un numero maggiore o uguale a 0) rappresenta 
un indice di un array JSON.


- JSON-LOAD DEFINIZIONE:

json_load(FileName, JSON_Object):

Questo predicato ritorna vero l'oggetto JSON costruito a partire dalla stringa contenuta nel 
file specificato da Filename è JSON_Object.


- JSON-WRITE DEFINIZIONE:

json_write(JSON_Object, FileName):


Questo predicato ritorna true se è stato possibile scrivere in sintassi JSON
all'interno del file, specificato da Filename, JSON_Object. 
Si assume che JSON_Object sia un oggetto JSON valido e dunque sintatticamente corretto.
























