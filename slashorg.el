(defun slashorg-get-frontpage-as-list ()
  (org-split-string
    (shell-command-to-string "w3m -dump -cols 20000 slashdot.org") "\n"))

(defun slashorg-extract-headline (str)
  "Removes the \"Comments: <number> + -\" part of a headline.
Exemple:
If str is \"Comments: 60 + -    News: Lorem Ipsum on Tuesday May 04, @10:55AM\"
it should return News: Lorem Ipsum"
                                        ;(cadr (org-split-string str "+ -[[:space:]]*")))
  (car (org-split-string
         (cadr (org-split-string str "+ -[[:space:]]*"))
         ;; This regexp removes the end of the headline (the part with the day
         ;; of the week, name of the month, day of the month (in numerical
         ;; format), and the hour the news was posted
         " on [[:ascii:]]+ [[:ascii:]]+ [0-3][0-9], @[[:digit:]]*:[[:digit:]]*[AP]M$")))


(defun slashorg-get-info (list)
  (cond ((null list)
          '())
    ((string-match "Comments: " (car list))
      (let ((headline (slashorg-extract-headline (car list)))
             (summary (car (cdr (cddddr list))))) ; Current line + 5
        (concat "* " headline "\n"
          "  " summary "\n"
          (slashorg-get-info (cdr (cdr (cddddr list)))) "\n"))) ; Only pass the list after the summary
    (t
      (concat "" (slashorg-get-info (cdr list))))))

(defun slashorg-insert-content-into-buffer ()
  (interactive)
  (let ((max-lisp-eval-depth 2000000) 
         (max-specpdl-size 20000))
    (insert (slashorg-get-info (slashorg-get-frontpage-as-list)))
    (fill-region (point-min) (point-max))))

(defun slashorg ()
  (interactive)
  (switch-to-buffer "*Slashorg*")
  (org-mode)
  (erase-buffer)
  (slashorg-insert-content-into-buffer)
  (org-cycle-internal-global) ;; Change the visibility to OVERVIEW
  (goto-char (point-min)))
