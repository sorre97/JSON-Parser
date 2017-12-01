;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; "42 is the only solution."


;;; json-parse definition:
;;; input: una stringa di caratteri
;;; output: l'oggetto parsato
;;; errori: (1) se l'input non è una stringa
;;;         (2) se MORE-INPUT  non è vuoto
(defun json-parse (json-string)
  (if (not (stringp json-string)) 
    (error "ERROR: non sono una stringa")
    (let ((list-result (is-JSON (skip-whitespaces (string-to-asciilist json-string)))))
    	(if (null (skip-whitespaces (more-input list-result))) 
          (parsed-obj list-result)
          (error "Error: Non ho la stringa vuota alla fine - Ciuccio a rotelle")))))



;;; is-JSON definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: (1) un JSON-ARRAY, se il primo carattere di ASCII-LIST è [
;;;         (2) un JSON-OBJ, se il primo carattere di ASCII-LIST è {
;;; errori: se non è né un OBJ né un ARRAY
(defun is-JSON (ascii-list)
  (cond 
   ((equal [ (first ascii-list)) (is-array (skip-whitespaces (rest ascii-list))))
   ((equal { (first ascii-list)) (is-object (skip-whitespaces (rest ascii-list))))
   (T (error "ERROR: Non ho trovato né una quadra né una graffa"))))



;;; is-object definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: un JSON-OBJ, il quale può essere vuoto o avere dei MEMBERS, e il MORE-INPUT
;;; errori: se non c'è la parentesi } che chiude il JSON-OBJ
(defun is-object (ascii-list)
  (cond 
   ((equal } (first ascii-list)) (list (skip-whitespaces (rest ascii-list)) (list 'json-obj))) ; questo è il caso oggetto vuoto
   (T (let ((is-member-result (is-member ascii-list))) ; questo è il caso in cui JSON-OBJ non è vuoto
         (if (equal } (first (more-input is-member-result)))
             (list (skip-whitespaces (rest (more-input is-member-result))) (append (list 'json-obj) (parsed-obj is-member-result))) ; questo è il valore di ritorno
           (error "l'oggetto non ha la parentesi }"))))))                                                                           



;;; is-member definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: (1) MORE-INPUT + un solo PAIR
;;;         (2) una lista di paia
;;; errori: non vengono lanciati errori...
(defun is-member (ascii-list)
  (let ((is-pair-result (is-pair ascii-list))) ; IS-PAIR-RESULT contiene un PAIR in PARSED-OBJ, cioè la prima coppia string:value
    (cond 
     ((equal comma (first (more-input is-pair-result))) ;se c'è una COMMA(virgola) allora ci sono più PAIR
      (let ((recursive-member-result (is-member (skip-whitespaces (rest (more-input is-pair-result)))))) 
        (list (more-input recursive-member-result) (append (parsed-obj is-pair-result) (parsed-obj recursive-member-result))))) ; valore di ritorno: MORE-INPUT + una lista di PAIR
     (T (list (more-input is-pair-result) (parsed-obj is-pair-result)))))) ; caso base: c'è un solo PAIR, perchè non è stata trovata la virgola



;;; is-pair definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: MORE-INPUT + una coppia chiave-valore
;;; errori: (1) se la chiave non è una stringa
;;; errori: (2) se non viene trovato il simbolo ':' tra la chiave e il valore
(defun is-pair (ascii-list)
  (if (not (equal double-quote (first ascii-list))) (error "sono is-pair e non ho una stringa nella chiave")
    (let ((is-string-result (is-string (skip-whitespaces ascii-list)))) ; IS-STRING-RESULT contiene il valore della stringa in PARSED-OBJ
      (cond
       ((equal colon (first (more-input is-string-result))) ; se ci sono i ':' allora chiamo la is-value
        (let ((is-value-result (is-value (skip-whitespaces (rest (more-input is-string-result)))))) ; IS-VALUE-RESULT conterrà un VALUE in PARSED-OBJ
          (list (more-input is-value-result) (list (list (parsed-obj is-string-result) (parsed-obj is-value-result)))))) ; questo è il valore di ritorno
       (T (error "non ho trovato il :"))))))



;;; is-value definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: MORE-INPUT(in modo implicito) + un VALUE, che può essere (1) una STRING, (2) un numero e (3) un JSON
;;; errori: se non è né un numero, né una string e neppure un JSON
(defun is-value (ascii-list)
  (cond
   ((equal double-quote (first ascii-list)) ; se è una stringa deve iniziare con DOUBLE-QUOTE
    (is-string ascii-list))
   ((or (equal { (first ascii-list)) (equal [ (first ascii-list)))  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;da implementare il caso in cui c'è [, dunque un array o un numero
    (is-JSON ascii-list))
   (T (error "sono u numero"))))



;;; is-string definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: una lista contenente MORE-INPUT e una STRING
;;; errori: non vengono lanciati errori...
(defun is-string (ascii-list)
  (list (skip-whitespaces (skip-char-rest (rest ascii-list))) (asciilist-to-string (skip-char-string (rest ascii-list)))))


;;; skip-char-string definition
;;; input: una lista di caratteri ascii, ASCII-LIST
;;; output: una STRING
;;; errori: nessun errore viene lanciato...
(defun skip-char-string (ascii-list)
  (if (equal (first ascii-list) double-quote)
      NIL
      (cons (first ascii-list) (skip-char-string (rest ascii-list)))))



;;; skip-char-rest definition:
;;; input: una lista di caratteri ascii, ASCII-LIST
;;; output: tutto ciò che c'è dopo un DOUBLE-QUOTE, cioè il MORE-INPUT di is-string
;;; errori: viene lanciato un errore se ASCII-LIST è la stringa vuota
(defun skip-char-rest (ascii-list)
  (cond
   ((null ascii-list) (error "sono skip-char-rest e ho la lista vuota"))
   ((equal (first ascii-list) double-quote) (rest ascii-list))
   (T (skip-char-rest (rest ascii-list)))))


;;; HELPER FUNCTION

;;; questa funzione ritorna il MORE-INPUT
(defun more-input (list)
  (first list))

;;; questa funzione ritorna l'oggetto parsato PARSED-OBJ
(defun parsed-obj (list)
  (second list))

;;; questa funzione skippa gli spazi bianchi
(defun skip-whitespaces (string-ascii)
  (string-to-asciilist 
   	(string-left-trim spazio 
                      (asciilist-to-string string-ascii))))

;;; questa funzione effettua una conversione da string ad asciilist
(defun string-to-asciilist (string)
  (map 'list #'char-code string))

;;; questa funzione effettua una conversione da asciilist a string
(defun asciilist-to-string (ascii-list)
	(coerce (mapcar 'code-char ascii-list) 'string))

;;; PARAMETERS DEFINITION

(defparameter spazio '(#\Space #\Tab #\Newline))
(defparameter [ (char-code #\[))
(defparameter ] (char-code #\]))
(defparameter { (char-code #\{))
(defparameter } (char-code #\}))
(defparameter comma (char-code #\,))
(defparameter colon (char-code #\:))
(defparameter double-quote (char-code #\"))

;;;; END OF FILE - json-parsing.lisp 