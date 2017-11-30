;;;; json-parsing.lisp
;;;; Creators: Sorrentino, Rota, Mottadelli
;;;; "Premature optimization is the root of all evil"
;;;; "42 is the only solution."

;;; json-parse definition:
(defun json-parse (json-string)
  (if (not (stringp json-string))
      error "ERROR: syntax error" 
      (is-JSON (string-to-asciilist json-string))))
  
;;; is-JSON definition:
(defun is-JSON (AsciiList)
  if ())




;;; HELPER FUNCTION

(defparameter spazio '(#\Space #\Tab #\Newline))

(defun skip-whitespaces (StringAscii)
  (string-to-asciilist 
   	(string-left-trim spazio 
                      (asciilist-to-string StringAscii))))

(defun string-to-asciilist (string)
  (map 'list #'char-code string))

(defun asciilist-to-string (AsciiList)
	(coerce (mapcar 'code-char AsciiList) 'string))

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

