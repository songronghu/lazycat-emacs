;;; magit-extension.el --- Extension for magit

;; Filename: magit-extension.el
;; Description: Extension for magit
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-09-07 03:32:14
;; Version: 0.2
;; Last-Updated: 2018-09-10 21:24:05
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/magit-extension.el
;; Keywords:
;; Compatibility: GNU Emacs 27.0.50
;;
;; Features that might be required by this library:
;;
;; `magit'
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
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
;; Extension for magit
;;

;;; Installation:
;;
;; Put magit-extension.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'magit-extension)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET magit-extension RET
;;

;;; Change log:
;;
;; 2018/09/10
;;      * Fix error of `magit-submodule-remove' that git-modules-submodule-path is not right sometimes.
;;
;; 2018/09/07
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'magit)

;;; Code:

(defun magit-get-submodule-short-name (path)
  "Return short name of submodule path."
  (let* ((submodule-lines (magit-git-lines "config" "--list" "-f" ".gitmodules"))
         (submodule-match-line (car (seq-filter (lambda (l) (string-match (format "submodule.*.path=%s" path) l)) submodule-lines)))
         submodule-url-title
         submodule-url-string)
    (when submodule-match-line
      (replace-regexp-in-string "submodule." "" (replace-regexp-in-string ".path$" "" (car (split-string submodule-match-line "="))))
      )))

(defun magit-get-submodule-url (path)
  "Return url of submodule path."
  (let* ((submodule-lines (magit-git-lines "config" "--list" "-f" ".gitmodules"))
         (submodule-match-line (car (seq-filter (lambda (l) (string-match (format "submodule.*.path=%s" path) l)) submodule-lines)))
         submodule-url-title
         submodule-url-string)
    (when submodule-match-line
      (let* ((submodule-url-title (replace-regexp-in-string ".path$" ".url" (car (split-string submodule-match-line "="))))
             (submodule-url-string (car (seq-filter (lambda (l) (string-match (format "%s=*" submodule-url-title) l)) submodule-lines))))
        (when submodule-url-string
          (replace-regexp-in-string "submodule.*url=" "" submodule-url-string))))))

(defun magit-submodule-remove (&optional module-name)
  (interactive)
  (save-excursion
    (let* (
           ;; Get current directory for restore after remove submodule.
           (current-directory default-directory)
           (submodule-name (progn
                             ;; Cd magit toplevel directory make sure `magit-list-module-paths' can work.
                             (cd (magit-toplevel))
                             (or module-name (completing-read "Remove submodule: " (magit-list-module-paths)))))
           (submodule-path (concat (magit-toplevel) submodule-name))
           (gitmodules-file-path (concat (magit-toplevel) ".gitmodules"))
           (git-config-file-path (concat (magit-toplevel) ".git/" "config"))
           (git-modules-submodule-path (magit-get-submodule-name submodule-name))
           (submodule-url (magit-get-submodule-url submodule-name))
           (submodule-short-name (magit-get-submodule-short-name submodule-name))

           kill-start
           kill-end
           )

      ;; Delete submodule directory first.
      (when (file-exists-p submodule-path)
        (delete-directory submodule-path t))

      ;; Delete submodule from .gitmodules file.
      (magit-kill-buffer-match-file gitmodules-file-path)
      (with-current-buffer (find-file gitmodules-file-path)
        (goto-char (point-min))
        (when (search-forward-regexp (format "[submodule \"%s\"]" submodule-short-name) nil t)
          (previous-line)
          (beginning-of-line)
          (kill-line 3)
          (save-buffer)))

      ;; Delete submodule from .git/config file.
      (magit-kill-buffer-match-file git-config-file-path)
      (with-current-buffer (find-file git-config-file-path)
        (goto-char (point-min))
        (when (search-forward-regexp (format "url\\s-=\\s-%s" submodule-url) nil t)
          (previous-line)
          (beginning-of-line)
          (kill-line 3)
          (save-buffer)))

      ;; Delete submodule under .git/modules/ directory.
      (when (file-exists-p git-modules-submodule-path)
        (delete-directory git-modules-submodule-path t))

      ;; Kill temp buffer.
      (magit-kill-buffer-match-file gitmodules-file-path)
      (magit-kill-buffer-match-file git-config-file-path)

      ;; Restore current directory.
      (cd current-directory)
      )
    ))

(defun magit-kill-buffer-match-file (filepath)
  (catch 'find-match
    (dolist (buffer (buffer-list))
      (when (string-equal (buffer-file-name buffer) filepath)
        (kill-buffer buffer)
        (throw 'find-match buffer)))
    nil))

(provide 'magit-extension)

;;; magit-extension.el ends here
