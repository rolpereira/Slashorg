(defun get-frontpage-as-list ()
  (org-split-string
    (shell-command-to-string "w3m -dump -cols 20000 slashdot.org") "\n"))

(defun extract-headline (str)
  "Removes the \"Comments: <number> + -\" part of a headline.
Exemple:
If str is \"Comments: 60 + -    News: Lorem Ipsum on Tuesday May 04, @10:55AM\"
it should return News: Lorem Ipsum"
  ;(cadr (org-split-string str "+ -[[:space:]]*")))
  (car (org-split-string
         (cadr (org-split-string "Comments: 60 + -   Technology: BlackBerry Predicted a Century Ago By Nikola Tesla on Tuesday May 04, @08:53AM" "+ -[[:space:]]*"))
         ;; This regexp removes the end of the headline (the part with the day
         ;; of the week, name of the month, day of the month (in numerical
         ;; format), and the hour the news was posted
         " on [[:ascii:]]+ [[:ascii:]]+ [0-3][0-9], @[[:digit:]]*:[[:digit:]]*[AP]M$")))
  

(defun get-info (list)
  (cond ((null list)
          '())
    ((string-match "Comments: " (car list))
      (let ((headline (extract-headline (car list)))
             (summary (car (cdr (cddddr list))))) ; Current line + 5
      (concat "* " headline "\n"
        "  " summary "\n"
        (get-info (cdr (cdr (cddddr list)))) "\n"))) ; Only pass the list after the summary
    (t
      (concat "" (get-info (cdr list))))))

(defun teste2 ()
  (interactive)
  (let ((max-lisp-eval-depth 2000000) 
         (max-specpdl-size 20000))
    (insert (get-info (get-frontpage-as-list)))
    (fill-region (point-min) (point-max))))

(car (org-split-string
  (cadr (org-split-string "Comments: 60 + -   Technology: BlackBerry Predicted a Century Ago By Nikola Tesla on Tuesday May 04, @08:53AM" "+ -[[:space:]]*"))
  ;; This regexp removes the end of the headline (the part with the day of the
  ;; week, name of the month, day of the month (in numerical format), and the
  ;; hour the news was posted
  " on [[:ascii:]]+ [[:ascii:]]+ [0-3][0-9], @[[:digit:]]*:[[:digit:]]*[AP]M$"))
