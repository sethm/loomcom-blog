;;; loomcom-blog.el --- Blogging system for Loom Communications, LLC

;; Copyright (C) 2022 Seth Morabito
;;
;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <https://www.gnu.org/licenses/>.

;; Author: Seth Morabito <web@loomcom.com>
;; Version: 1.0
;; Package-Requires ((emacs "27.1"))

;;; Commentary:

;; Basically a single function that opens a new buffer with a blank,
;; correctly-numbered blog entry in it.

;;; Code:

(defgroup loomcom-blog nil
  "Loom Communications blogging system")

(defcustom loomcom-blog-org-dir "~/Projects/loomcom/org/blog/"
  "Path to blog org-mode directory"
  :type 'directory
  :group 'loomcom-blog)

(defcustom loomcom-blog-pattern "^\\([0-9]\\{4\\}\\)"
  "Blog filename prefix"
  :type 'string
  :group 'loomcom-blog)

(defun loomcom--blog-entry-p (fname)
  "Return true if `fname' is a blog entry"
  (string-match loomcom-blog-pattern fname))

(defun loomcom--make-file-name (number title)
  (let ((stub
         (replace-regexp-in-string "[^a-z]+" "_" (downcase title) nil 'literal)))
    (format
     "%s_%s.org"
     number
     (replace-regexp-in-string "^_\\|_$" "" stub nil 'literal))))

(defun loomcom-blog-new (human-title)
  "Create a new blog entry."
  (interactive "sNew Entry Title: ")
  (if (file-exists-p loomcom-blog-org-dir)
      (progn
        (org-mode)
        (let* ((blog-files (sort
                            (seq-filter 'loomcom--blog-entry-p
                                        (directory-files loomcom-blog-org-dir)) 'string>))
               (match (string-match loomcom-blog-pattern (car blog-files)))
               (last-num (match-string 1 (car blog-files)))
               (next-num (format "%04d" (+ 1 (string-to-number last-num))))
               (new-file (loomcom--make-file-name next-num human-title))
               (snippet (cl-find "New Blog File" (yas--all-templates
                                                  (yas--get-snippet-tables 'org-mode))
                                 :key #'yas--template-name :test #'string=)))
          (find-file (concat loomcom-blog-org-dir new-file))
          (yas-expand-snippet snippet)
          (insert human-title)
          (yas-next-field)
          (yas-next-field)
          (yas-next-field)))
    (error "Blog directory does not exist.")))

(provide 'loomcom-blog)

;;; loomcom-blog.el ends here
