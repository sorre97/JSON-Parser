;;;; -*- Mode: Lisp -*-
;;; json-parsing.pl

;;; Members: 
;;; Sorrentino Alessandro 815999
;;; Rota Claudio 816050
;;; Mottadelli Simone Paolo 820786

;;; "Premature optimization is the root of all evil"


;;; PARAMETERS DEFINITION
;;; (defparameter spazio '(#\Space #\Tab #\Newline #\Null))

(defparameter spazio '(#\Space #\Return #\Newline #\Backspace #\Tab))
(defparameter [ (char-code #\[))
(defparameter ] (char-code #\]))
(defparameter { (char-code #\{))
(defparameter } (char-code #\}))
(defparameter dot (char-code #\.))
(defparameter comma (char-code #\,))
(defparameter colon (char-code #\:))
(defparameter double-quote (char-code #\"))
(defparameter plus (char-code #\+))
(defparameter less (char-code #\-))


;;; json-parse definition:
;;; input: una stringa di caratteri
;;; output: l'oggetto parsato
;;; errori: (1) se l'input non è una stringa
;;;         (2) se MORE-INPUT  non è vuoto

(defun json-parse (json-string)
  (if (not (stringp json-string)) 
      (error "syntax error")
    (let ((list-result 
	   (is-JSON (skip-whitespaces (string-to-asciilist json-string)))))
      (if (null (skip-whitespaces (more-input list-result))) 
          (parsed-obj list-result)
        (error "syntax error")))))

;;; json-get definition:
;;; input: OBJ e FIELDS
;;; output: il valore associato alla catena di campi presenti in fields
;;; errori: se OBJ non è né un JSON-OBJ né un JSON-ARRAY

(defun json-get (obj &rest fields)
  (cond ((null (first fields)) obj) 
        ((equal 'json-obj (first obj)) (get-obj (rest obj) fields))
        ((equal 'json-array (first obj)) (get-arr (rest obj) fields))
        (T (error "syntax error"))))


;;; get-obj definition:
;;; input: GET-OBJ prende in ingresso un OBJ senza funtore!!!

(defun get-obj (obj fields) 
  (cond ((null obj) (error "syntax error"))
        ((null fields) (error "syntax error"))
        ((null (rest fields)) (get-assoc obj fields))
        (T (let ((get-assoc-result (get-assoc obj fields)))
             (if (listp get-assoc-result)
                 (cond ((equal 'json-obj (first get-assoc-result))
			(get-obj (rest get-assoc-result) (rest fields)))
                       ((equal 'json-array (first get-assoc-result))
			(get-arr (rest get-assoc-result) (rest fields)))
                       (T (error "syntax error")))
               (error "syntax error"))))))


;;; get-arr definition:

(defun get-arr (array fields)
  (cond ((null array) (error "syntax error"))
        ((null fields) (error "syntax error"))
        ((null (rest fields)) (get-assoc-arr array fields))
        (T (let ((get-assoc-result (get-assoc-arr array fields)))
             (if (listp get-assoc-result)
                 (cond ((equal 'json-obj (first get-assoc-result))
			(get-obj (rest get-assoc-result) (rest fields)))
                       ((equal 'json-array (first get-assoc-result))
			(get-arr (rest get-assoc-result) (rest fields)))
                       (T (error "syntax error")))
               (error "syntax error"))))))


;;; get-assoc-arr definition:

(defun get-assoc-arr (arr fields)
  (if (and (numberp (first fields)) 
	   (< (first fields) (length arr)) 
	   (>= (first fields) 0))
      (nth (first fields) arr)
    (error "syntax error")))


;;; get-assoc definition:

(defun get-assoc (obj fields)
  (cond ((null obj) (error "syntax error"))
        ((equal (first fields) (get-key (first obj))) (get-value (first obj)))
        (T (get-assoc (rest obj) fields))))


;;; is-JSON definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: (1) un JSON-ARRAY, se il primo carattere di ASCII-LIST è [
;;;         (2) un JSON-OBJ, se il primo carattere di ASCII-LIST è {
;;; errori: se non è né un OBJ né un ARRAY

(defun is-JSON (ascii-list)
  (cond ((equal [ (first ascii-list))
	 (is-array (skip-whitespaces (rest ascii-list))))
        ((equal { (first ascii-list))
	 (is-object (skip-whitespaces (rest ascii-list))))
        (T (error "syntax error"))))



;;; is-object definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: un JSON-OBJ, il quale può essere vuoto o avere dei MEMBERS, e il
;;; MORE-INPUT
;;; errori: se non c'è la parentesi } che chiude il JSON-OBJ

(defun is-object (ascii-list)
  (cond ((equal } (first ascii-list))
	 (list (skip-whitespaces (rest ascii-list)) (list 'json-obj)))
        (T (let ((is-member-result (is-member ascii-list)))
             (if (equal } (first (more-input is-member-result)))
                 (list (skip-whitespaces (rest (more-input is-member-result)))
		       (append (list 'json-obj) (parsed-obj is-member-result)))
               (error "syntax error"))))))                   



;;; is-array definition:

(defun is-array (ascii-list) 
  (cond ((equal ] (first ascii-list)) 
	 (list (skip-whitespaces (rest ascii-list)) (list 'json-array))) 
	(T (let ((is-element-result (is-element ascii-list))) 
	     (if (equal ] (first (more-input is-element-result)))
		 (list (skip-whitespaces (rest (more-input is-element-result)))
		       (append (list 'json-array) (parsed-obj is-element-result)))
	       (error "syntax error"))))))


;;; is-element definition

(defun is-element (ascii-list)
  (let ((is-value-result (is-value ascii-list)))
    (cond ((equal comma (first (more-input is-value-result))) 
           (let ((recursive-element-result 
		  (is-element (skip-whitespaces (rest (more-input is-value-result))))))
             (list (more-input recursive-element-result)
		   (append (list (parsed-obj is-value-result))
			   (parsed-obj recursive-element-result)))))
          (T (list (more-input is-value-result) 
		   (list (parsed-obj is-value-result))))))) 


;;; is-member definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: (1) MORE-INPUT + un solo PAIR
;;;         (2) una lista di paia
;;; errori: non vengono lanciati errori...

(defun is-member (ascii-list)
  (let ((is-pair-result (is-pair ascii-list))) 
    (cond ((equal comma (first (more-input is-pair-result)))
           (let ((recursive-member-result 
		  (is-member (skip-whitespaces (rest (more-input is-pair-result)))))) 
             (list (more-input recursive-member-result) 
		   (append (parsed-obj is-pair-result) 
			   (parsed-obj recursive-member-result)))))
          (T (list (more-input is-pair-result) (parsed-obj is-pair-result))))))


;;; is-pair definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: MORE-INPUT + una coppia chiave-valore
;;; errori: (1) se la chiave non è una stringa
;;; errori: (2) se non viene trovato il simbolo ':' tra la chiave e il valore

(defun is-pair (ascii-list)
  (if (not (equal double-quote (first ascii-list))) (error "syntax error")
    (let ((is-string-result (is-string (skip-whitespaces ascii-list)))) 
      (cond ((equal colon (first (more-input is-string-result))) 
             (let ((is-value-result
		    (is-value (skip-whitespaces (rest (more-input is-string-result))))))
               (list (more-input is-value-result)
		     (list (list (parsed-obj is-string-result) 
				 (parsed-obj is-value-result))))))
            (T (error "syntax error"))))))


;;; is-value definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: MORE-INPUT(in modo implicito) + un VALUE, che può essere 
;;; (1) una STRING, (2) un numero e (3) un JSON
;;; errori: se non è né un numero, né una string e neppure un JSON

(defun is-value (ascii-list)
  (cond ((equal double-quote (first ascii-list))
         (is-string ascii-list))
        ((or (equal { (first ascii-list)) (equal [ (first ascii-list)))  
         (is-JSON ascii-list))
        ((and (equal plus (first ascii-list)) 
	      (is-digit (first (rest ascii-list)))) 
	 (parse-number (rest ascii-list)))
        ((and (equal less (first ascii-list)) 
	      (is-digit (first (rest ascii-list))))
         (let ((number-result (parse-number (rest ascii-list))))
           (list (more-input number-result) (- (parsed-obj number-result)))))
        ((is-digit (first ascii-list)) (parse-number ascii-list))
        (T (error "syntax error"))))


;;; is-string definition:
;;; input: una lista di caratteri ascii, cioè ASCII-LIST
;;; output: una lista contenente MORE-INPUT e una STRING
;;; errori: non vengono lanciati errori...

(defun is-string (ascii-list)
  (list (skip-whitespaces (skip-char-rest (rest ascii-list))) 
	(asciilist-to-string (skip-char-string (rest ascii-list)))))


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
;;; output: tutto ciò che c'è dopo un DOUBLE-QUOTE, cioè il MORE-INPUT di
;;; is-string
;;; errori: viene lanciato un errore se ASCII-LIST è la stringa vuota

(defun skip-char-rest (ascii-list)
  (cond ((null ascii-list) (error "syntax error"))
        ((equal (first ascii-list) double-quote) (rest ascii-list))
        (T (skip-char-rest (rest ascii-list)))))


;;; parse-number definition:
;;; input: una lista
;;; output: restituisce la lista con il resto e il numero parsato
;;; error: niente errori lanciati

(defun parse-number (ascii-list)
  (let ((num-result (my-parse-int ascii-list)))
    (cond ((and (equal dot (first (more-input num-result)))
		(is-digit (second (more-input num-result))))
           (let ((decimal-result 
		  (my-parse-int (rest (more-input num-result)) '(46))))
             (list (skip-whitespaces (more-input decimal-result)) 
		   (parse-float (asciilist-to-string (append (parsed-obj num-result)
							     (parsed-obj decimal-result)))))))
          (T (list (skip-whitespaces (more-input num-result)) 
		   (parse-int1 (reverse (parsed-obj num-result))))))))


;;; my-parse-int definition:
;;; input: una lista e una lista opzionale vuolta dove di costruisce il numero
;;; output: restituisce la lista con il resto e il numero parsato
;;; error: niente errori lanciati

(defun my-parse-int (ascii-list &optional (numlist nil))
  (if (and (not (null ascii-list)) (is-digit (first ascii-list)))
      (my-parse-int (rest ascii-list) 
		    (append numlist (list (first ascii-list))))
    (list ascii-list numlist)))


;;; parse-int1 definition:
;;; input: una lista
;;; output: restituisce la lista parsata a numero
;;; errori: niente errori lanciati

(defun parse-int1 (list &optional (acc 1))
  (if (null list) 
      0
    (+ (* (- (first list) 48) acc) (parse-int1 (rest list) (* acc 10)))))


;;; is-digit definition
;;; input: un codice ascii
;;; output: true --> se è un numero
;;; false --> se non è un numero
;;; errori: non vengono lanciati errori

(defun is-digit (ascii-num)
  (if (null ascii-num) 
      (error "syntax error")
    (let ((num (- ascii-num 48)))
      (if (and (>= num 0) (<= num 9))
          T
        NIL))))


;;; json-load definition:
;;; input: name of the file path
;;; output: a JSON_OBJ
;;; errori: (1) se non viene trovato il file
;;;         (2) se non è una stringa in sintassi json

(defun json-load (filename)
  (with-open-file (stream filename
                          :external-format :default
                          :direction :input
                          :if-does-not-exist :error)
    (let ((json-string (make-string (file-length stream))))
      (read-sequence json-string stream)
      (json-parse json-string))))


;;; json-write definition:

(defun json-write (json-obj filename)
  (with-open-file (stream  filename
                           :direction :output
                           :if-exists :supersede
                           :if-does-not-exist :create )
    (format stream (write-json json-obj))))


;;; write-json definition:

(defun write-json (json-obj)
  (if (listp json-obj)
      (cond ((equal 'json-obj (first json-obj))
	     (concatenate 'string "{" (write-obj (rest json-obj))))
            ((equal 'json-array (first json-obj)) 
	     (concatenate 'string "[" (write-arr (rest json-obj))))
            (T (error "syntax error")))
    (error "syntax error")))


;;; write-obj definition:

(defun write-obj (json-obj)
  (cond ((null json-obj) "}")
        (T (concatenate 'string (write-members json-obj) "}"))))


;;; write-arr definition:

(defun write-arr (json-obj)
  (cond ((null json-obj) "]")
        (T (concatenate 'string (write-elements json-obj) "]"))))

;;; write-elements definition:

(defun write-elements (json-obj)
  (cond ((null (rest json-obj)) (write-value (first json-obj)))
        (T (concatenate 'string (write-value (first json-obj)) ", "
			(write-elements (rest json-obj))))))


;;; write-members definition:

(defun write-members (json-obj)
  (cond ((null (rest json-obj)) (write-pair (first json-obj)))
        (T (concatenate 'string (write-pair (first json-obj)) ", "
			(write-members (rest json-obj))))))


;;; write-pair definition:

(defun write-pair (json-obj)
  (concatenate 'string (write-key (first json-obj)) " : " 
	       (write-value (second json-obj))))


;;; write-key definition:

(defun write-key (key)
  (if (stringp key) 
      (concatenate 'string "\"" key "\"")
    (error "syntax error")))     


;;; write-value definition:

(defun write-value (value) 
  (cond ((stringp value) (concatenate 'string "\"" value "\""))
        ((numberp value) (write-to-string value))
        (T (write-json value))))




;;; HELPER FUNCTION

;;; questa funzione restituisce la chiave della coppia
;;; e.g. (chiave valore)

(defun get-key (coppia)
  (first coppia))


;;; questa funzione restituisce il valore della coppia
;;; e.g. (chiave valore)

(defun get-value (coppia)
  (second coppia))


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
  (if (not (stringp string))
      (error "syntax error")
    (map 'list #'char-code string)))


;;; questa funzione effettua una conversione da asciilist a string

(defun asciilist-to-string (ascii-list)
  (coerce (mapcar 'code-char ascii-list) 'string))


;;;; END OF FILE - json-parsing.lisp 
