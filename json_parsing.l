;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; "42 is the only solution."

;;; json-parse definition:
(defun json-parse (json-string)
  (if (not (stringp json-string)) 
    (error "ERROR: non sono una stringa")
    (let ((list-result (is-JSON (skip-whitespaces (string-to-asciilist json-string)))))
    	(if (null (more-input list-result)) 
          (parsed-obj list-result)
          (error "Error: Non ho la stringa vuota alla fine - Ciuccio a rotelle")))))

(defun is-JSON (ascii-list)
	(cond 
    ((equal [ (first ascii-list)) (is-array (skip-whitespaces (rest ascii-list))))
    ((equal { (first ascii-list)) (is-object (skip-whitespaces (rest ascii-list))))
    (T (error "ERROR: Non ho trovato né una quadra né una graffa"))))

;;; is-array definition:

;;; is-object definition:
(defun is-object (ascii-list)
  (cond 
    ((equal } (first ascii-list)) (list (skip-whitespaces (rest ascii-list)) (list 'json-obj)))
    (T (let ((is-member-result (is-member ascii-list)))
      (if (equal } (first (more-input is-member-result)))
    	    (list (rest (more-input is-member-result)) (list 'json-obj (parsed-obj is-member-result)))
  				(error "l'oggetto non ha la parentesi }"))))))

;;; is-member definition:
(defun is-member (ascii-list)
  (let ((is-pair-result (is-pair ascii-list)))
       (cond 
        	((equal comma (first (more-input is-pair-result))) (is-member (skip-whitespaces (rest (more-input is-pair-result)))))
          (T (list (more-input is-pair-result) (parsed-obj is-pair-result))))))

;;; is-pair definition:
(defun is-pair (ascii-list)
  (let ((is-string-result (is-string (skip-whitespaces ascii-list))))
       (cond
         ((equal colon (first (more-input is-string-result))) ; se ci sono i ':' allora chiamo la is-value
            (let ((is-value-result (is-value (skip-whitespaces (rest (more-input is-string-result))))))
                (list (more-input is-value-result) (list (parsed-obj is-string-result) (parsed-obj is-value-result)))))
        (T (error "non ho trovato il :")))))

;;; is-value definition:
(defun is-value (ascii-list)
  (is-string (skip-whitespaces ascii-list)))
  
;;; is-string riceve in ingresso una stringa che inizia con doppio apice
;;; is-string ritorna una lista (more-input, parsed-string)
;;; nota: more-input restituito da is-string è gia stato white-skippato
(defun is-string (AsciiList)
  (list (skip-whitespaces (skip-char-rest (rest AsciiList))) (asciilist-to-string (skip-char-string (rest AsciiList)))))

(defun skip-char-string (AsciiList)
  (if (= (first AsciiList) 34)
      NIL
      (cons (first AsciiList) (skip-char-string (rest AsciiList)))))

(defun skip-char-rest (AsciiList)
  (if (= (first AsciiList) 34) 
      (rest AsciiList)
      (skip-char-rest (rest AsciiList))))


;;; HELPER FUNCTION

(defun more-input (list)
  (first list))

(defun parsed-obj (list)
  (second list))

(defun skip-whitespaces (string-ascii)
  (string-to-asciilist 
   	(string-left-trim spazio 
                      (asciilist-to-string string-ascii))))

(defun string-to-asciilist (string)
  (map 'list #'char-code string))

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




;;;; "42 is the only solution."
;;; json-parse definition:
;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; "42 is the only solution."

;;; json-parse definition:
(defun json-parse (json-string)
  (if (not (stringp json-string)) 
    (error "ERROR: non sono una stringa")
    (let ((list-result (is-JSON (skip-whitespaces (string-to-asciilist json-string)))))
    	(if (null (more-input list-result)) 
          (parsed-obj list-result)
          (error "Error: Non ho la stringa vuota alla fine - Ciuccio a rotelle")))))

(defun is-JSON (ascii-list)
	(cond 
    ((equal [ (first ascii-list)) (is-array (skip-whitespaces (rest ascii-list))))
    ((equal { (first ascii-list)) (is-object (skip-whitespaces (rest ascii-list))))
    (T (error "ERROR: Non ho trovato né una quadra né una graffa"))))

;;; is-array definition:

;;; is-object definition:
(defun is-object (ascii-list)
  (cond 
    ((equal } (first ascii-list)) (list (skip-whitespaces (rest ascii-list)) (list 'json-obj)))
    (T (let ((is-member-result (is-member ascii-list)))
      (if (equal } (first (more-input is-member-result)))
    	    (list (rest (more-input is-member-result)) (list 'json-obj (parsed-obj is-member-result)))
  				(error "l'oggetto non ha la parentesi }"))))))

;;; is-member definition:
(defun is-member (ascii-list)
  (let ((is-pair-result (is-pair ascii-list)))
       (cond 
        	((equal comma (first (more-input is-pair-result))) (is-member (skip-whitespaces (rest (more-input is-pair-result)))))
          (T (list (more-input is-pair-result) (parsed-obj is-pair-result))))))

(defun is-pair (ascii-list)
  (let ((is-string-result (is-string (skip-whitespaces ascii-list))))
       (cond
         ((equal colon (first (more-input is-string-result))) )
          
       )
  )
  
;;; is-string riceve in ingresso una stringa che inizia con doppio apice
;;; is-string ritorna una lista (more-input, parsed-string)
;;; nota: more-input restituito da is-string è gia stato white-skippato
(defun is-string (AsciiList)
  (list (skip-whitespaces (skip-char-rest (rest AsciiList))) (cons 34 (skip-char-string (rest AsciiList)))))

(defun skip-char-string (AsciiList)
  (if (= (first AsciiList) 34)
      (list 34)
      (cons (first AsciiList) (skip-char-string (rest AsciiList)))))

(defun skip-char-rest (AsciiList)
  (if (= (first AsciiList) 34) 
      (rest AsciiList)
      (skip-char-rest (rest AsciiList))))


;;; HELPER FUNCTION

(defun more-input (list)
  (first list))

(defun parsed-obj (list)
  (second list))

(defun skip-whitespaces (string-ascii)
  (string-to-asciilist 
   	(string-left-trim spazio 
                      (asciilist-to-string string-ascii))))

(defun string-to-asciilist (string)
  (map 'list #'char-code string))

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




(defun is-JSON (ascii-list)
	(cond 
    ((equal [ (first ascii-list)) (is-array (skip-whitespaces (rest ascii-list))))
    ((equal { (first ascii-list)) (is-object (skip-whitespaces (rest ascii-list))))
    (T (error "ERROR: Non ho trovato né una quadra né una graffa"))))

;;; is-array definition:

;;; is-object definition:
(defun is-object (ascii-list)
  (cond 
    ((equal } (first ascii-list)) (list (skip-whitespaces (rest ascii-list)) (list 'json-obj)))
    (T (let ((is-member-result (is-member ascii-list)))
      (if (equal } (first (more-input is-member-result)))
    	    (list (rest (more-input is-member-result)) (list 'json-obj (parsed-obj is-member-result)))
  				(error "l'oggetto non ha la parentesi }"))))))

;;; is-member definition:
(defun is-member (ascii-list)
  (let ((is-pair-result (is-pair ascii-list)))
       (cond 
        	((equal comma (first (more-input is-pair-result))) (is-member (skip-whitespaces (rest (more-input is-pair-result)))))
          (T (list (more-input is-pair-result) (parsed-obj is-pair-result))))))

(defun is-pair (ascii-list)
  
  )
;;; is-string riceve in ingresso una stringa che inizia con doppio apice
;;; is-string ritorna una lista (more-input, parsed-string)
;;; nota: more-input restituito da is-string è gia stato white-skippato
(defun is-string (AsciiList)
  (list (skip-whitespaces (skip-char-rest (rest AsciiList))) (cons 34 (skip-char-string (rest AsciiList)))))

(defun skip-char-string (AsciiList)
  (if (= (first AsciiList) 34)
      (list 34)
      (cons (first AsciiList) (skip-char-string (rest AsciiList)))))

(defun skip-char-rest (AsciiList)
  (if (= (first AsciiList) 34) 
      (rest AsciiList)
      (skip-char-rest (rest AsciiList))))


;;; HELPER FUNCTION

(defun more-input (list)
  (first list))

(defun parsed-obj (list)
  (second list))

(defun skip-whitespaces (string-ascii)
  (string-to-asciilist 
   	(string-left-trim spazio 
                      (asciilist-to-string string-ascii))))

(defun string-to-asciilist (string)
  (map 'list #'char-code string))

(defun asciilist-to-string (ascii-list)
	(coerce (mapcar 'code-char ascii-list) 'string))

;;; PARAMETERS DEFINITION
(defparameter spazio '(#\Space #\Tab #\Newline))
(defparameter [ (char-code #\[))
(defparameter ] (char-code #\]))
(defparameter { (char-code #\{))
(defparameter } (char-code #\}))
(defparameter comma (char-code #\,))
(defparameter double-quote (char-code #\"))

;;;; END OF FILE - json-parsing.lisp



;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; "42 is the only solution."

;;; json-parse definition:
(defun json-parse (json-string)
  (if (not (stringp json-string)) 
    (error "ERROR: non sono una stringa")
    (let ((list-result (is-JSON (skip-whitespaces (string-to-asciilist json-string)))))
    	(if (null (more-input list-result)) 
          (parsed-obj list-result)
          (error "Error: Non ho la stringa vuota")))))

;;; is-JSON definition:
(defun is-JSON (ascii-list)
	(cond 
    ((equal (first ascii-list) [) (is-array (skip-whitespaces (rest ascii-list))))
    ((equal (first ascii-list) {) (is-object (skip-whitespaces (rest ascii-list))))
    (T (error "ERROR: Non ho trovato né una quadra né una graffa"))))

;;; is-array definition:

;;; is-object definition:
(defun is-object (ascii-list)
  (cond 
    ((eq } (first ascii-list)) (list (skip-whitespaces (rest ascii-list)) (list 'json-obj)))
    (T (let ((is-member-result (is-member ascii-list))) 
      (list (more-input is-member-result) (list 'json-obj (parsed-obj is-member-result)))))))

(defun is-member (ascii-list)
  (list NIL '("nome" "claudio")))


;;; is-string riceve in ingresso una stringa che inizia con doppio apice
;;; is-string ritorna una lista (more-input, parsed-string)
;;; nota: more-input restituito da is-string è gia stato white-skippato
(defun is-string (AsciiList)
  (list (skip-whitespaces (skip-char-rest (rest AsciiList))) (cons 34 (skip-char-string (rest AsciiList)))))

(defun skip-char-string (AsciiList)
  (if (= (first AsciiList) 34)
      (list 34)
      (cons (first AsciiList) (skip-char-string (rest AsciiList)))))

(defun skip-char-rest (AsciiList)
  (if (= (first AsciiList) 34) 
      (rest AsciiList)
      (skip-char-rest (rest AsciiList))))


;;; HELPER FUNCTION

(defun more-input (list)
  (first list))

(defun parsed-obj (list)
  (second list))

(defun skip-whitespaces (string-ascii)
  (string-to-asciilist 
   	(string-left-trim spazio 
                      (asciilist-to-string string-ascii))))

(defun string-to-asciilist (string)
  (map 'list #'char-code string))

(defun asciilist-to-string (ascii-list)
	(coerce (mapcar 'code-char ascii-list) 'string))

;;; PARAMETERS DEFINITION
(defparameter spazio '(#\Space #\Tab #\Newline))
(defparameter [ (char-code #\[))
(defparameter ] (char-code #\]))
(defparameter { (char-code #\{))
(defparameter } (char-code #\}))
(defparameter double-quote (char-code #\"))

;;;; END OF FILE - json-parsing.lisp



