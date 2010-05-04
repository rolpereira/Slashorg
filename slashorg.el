;; This buffer is for notes you don't want to save, and for Lisp evaluation.
;; If you want to create a file, visit that file with C-x C-f,
;; then enter the text in that file's own buffer.



(defun get-content-file-as-list ()
  (org-split-string
    (org-file-contents "./html.txt") "\n"))

(defun get-content-file-as-list2 ()
  (org-split-string
    (shell-command-to-string "w3m -dump -cols 20000 slashdot.org") "\n"))


(defun get-info (list)
  ;(debug)
  (cond ((null list)
          '())
    ((string-match "Comments: " (car list))
      
      (let ((headline (car list))
             (summary (car (cdr (cddddr list))))) ; Current line + 5
      (concat "* " headline "\n"
        "  " summary "\n"
        (get-info (cdr (cdr (cddddr list)))) "\n"))) ; Only pass the list after the summary
    (t
      (concat "" (get-info (cdr list))))))

(setq max-lisp-eval-depth 2000000)
(get-info (get-content-file-as-list))

(defun teste ()
  (interactive)
  (let ((max-lisp-eval-depth 2000000))
    (insert (get-info (get-content-file-as-list)))
    (fill-region (point-min) (point-max))))

(defun teste2 ()
  (interactive)
  (let ((max-lisp-eval-depth 2000000) 
         (max-specpdl-size 20000))
    (insert (get-info (get-content-file-as-list2)))
    (fill-region (point-min) (point-max))))
