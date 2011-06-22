;;; slashorg.el --- interface for reading the frontpage of slashdot.org as a buffer mode

;; Copyright (C) 2010, 2011  Rolando Pereira

;; Author: Rolando Pereira <finalyugi@sapo.pt>
;; Keywords: slashdot org-mode w3m

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.


;;; Commentary:
;; 
;; Note: This is basically the contents of the README file

;; Slashorg is a program that let's you read the contents of the
;; frontpage of Slashdot.org inside a org buffer.

;; Prerequisites
;; You need to have w3m installed before you can use slashorg.

;; On a Ubuntu machine you can use the following command:
;; sudo apt-get install w3m

;; You also need to have org-mode installed.  Most recent versions of
;; Emacs already have it installed, but if yours doesn't, you will
;; need to install it.

;; You can also install org-mode using your package manager.  For
;; example, on a Ubuntu machine you can use the following command:
;; sudo apt-get install org-mode

;; Instalation

;; Download the slashorg.el file and put it somewhere in your
;; load-path.

;; Add the following to your .emacs file:
;; (autoload 'slashorg "slashorg" "Read the front page of Slashdot.org as a `org-mode' buffer." t)

;; To use it, type M-x slashorg


;;; Code:

(defun slashorg-get-frontpage-as-list ()
  "Return the contents of the frontpage of Slashdot as a list.

The list is the parsed output (ie. it doesn't contain any HTML
tags) created by the w3m executable where every `car' contains a
single line of that output."
  (split-string
    (shell-command-to-string "w3m -dump -cols 20000 slashdot.org") "\n"))

(defun slashorg-extract-headline (headline)
  "Remove the number at the end of the headline represented by HEADLINE.

Each headline contains a number at the end indicating how many
people have responded to that news.

This function removes that number.

Example:
  Foo to release Emacs 42.0 by the end of 2038 192

Output:
  Foo to release Emacs 42.0 by the end of 2038"
  (car
    (split-string headline " [[:digit:]]*$")))

(defun slashorg-beginning-of-news-p (list)
  "Check if (`car' LIST) is the beginning of a new news item.

A news item has, in the output of w3m, the following syntax:

<title of news>
<empty-line>
Posted by <username> on <date>
from the <string> dept.
<summary>
Read the <number> comments

Which in the format returned by `slashorg-get-frontpage-as-list'
corresponds to:

'(\"<title of news>\"
  \"\"
  \"Posted by <username> on <date>\"
  \"from the <string dept.\"
  \"<summary>\"
  \"Read the <number> comments\")

This function checks if (`car' LIST) is currently on the line <title of news>"
  (when (and list (nth 2 list))
    (string-match "Posted by " (nth 2 list))))

;; TODO: Convert this function to remove the recursion so that it is
;; no longer necessary to mess around with `max-lisp-eval-depth' and
;; `max-specpdl-size' in the function
;; `slashorg-insert-content-into-buffer'
(defun slashorg-get-info (list)
  "Return a string (in `org-mode' format) with the news contained in LIST.

Each news is represented in this format:

* <Title of the News>
  <summary>"
  (cond ((null list)
          '())
    ((slashorg-beginning-of-news-p list)
      (let ((headline (slashorg-extract-headline (car list)))
             (summary (nth 4 list)))
        (concat "* " headline "\n"
          "  " summary "\n"
          (slashorg-get-info
            (cdr (cdr (cdr (cdr (cdr (cdr list))))))) ; Jump over the summary
          "\n")))
    (t
      (concat "" (slashorg-get-info (cdr list))))))

(defun slashorg-insert-content-into-buffer ()
  "Insert the content of the frontpage of Slashdot in the current buffer."
  (let ((max-lisp-eval-depth 2000000)
         (max-specpdl-size 20000))
    (insert (slashorg-get-info (slashorg-get-frontpage-as-list)))
    (fill-region (point-min) (point-max))))

;;;###autoload
(defun slashorg ()
  "Read the front page of Slashdot.org as a `org-mode' buffer."
  (interactive)
  (switch-to-buffer "*Slashorg*")
  (org-mode)
  (erase-buffer)
  (slashorg-insert-content-into-buffer)
  (org-cycle-internal-global) ;; Change the visibility to OVERVIEW
  (goto-char (point-min)))

(provide 'slashorg)

;;; slashorg.el ends here
