;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; "42 is the only solution."

;;; json-parse definition:
(defun json-parse (json-string)
  (if (not (stringp json-string)) 
    (error "ERROR: syntax error")
    (let ((list-result (is-json (string-to-asciilist json-string))))
      (if (null (skip-whitespaces (first list-result))) 
        (second list-result)
        (error "ERROR: syntax error"))))))


;;; is-JSON definition:
(defun is-JSON (ascii-list)
	(cond 
    ((equal (first ascii-list) [) (is-array (rest ascii-list)))
    ((equal (first ascii-list) {) (is-object (rest ascii-list)))
    (T (error "ERROR: syntax error"))))

;;; is-array definition:
(defun is-array (ascii-list)
  )

;;; is-object definition:
(defun is-object (ascii-list)
  )


  
;;; is-string definition:
(defun is-string (ascii-list)
  (if (equal (first list) double-quote)) 
  	(skip-chars (rest ascii-list))
  	(error "Sono is-string: non ho trovato il doppio apice")))

;;; defun skip-chars definition:
(defun skip-chars (ascii-list)
  (cond 
    ((equal (first ascii-list) double-quote) (list double-quote (rest ascii-list)))
  	(T (list (append (list (first ascii-list)) (first (skip-chars (rest ascii-list)))) (second (skip-chars (rest ascii-list)))))))


;;; HELPER FUNCTION



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







(defun is-string (AsciiList)
  (list (append (list 34) (skip-char-string AsciiList)) (skip-char-rest AsciiList)))

(defun skip-char-string (AsciiList)
  (if (eq (first AsciiList) 34)
      (list 34)
      (append (list (first AsciiList)) (skip-char-string (rest AsciiList)))))

(defun skip-char-rest (AsciiList)
  (if (eq (first AsciiList) 34) 
      (rest AsciiList)
      (skip-char-rest (rest AsciiList))))

