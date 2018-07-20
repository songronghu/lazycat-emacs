;;; company-english-helper.el --- English helper with company interface

;; Filename: company-english-helper.el
;; Description: English helper with company interface
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-07-06 23:22:22
;; Version: 0.2
;; Last-Updated: 2018-07-20 13:04:14
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/company-english-helper.el
;; Keywords:
;; Compatibility: GNU Emacs 27.0.50
;;
;; Features that might be required by this library:
;;
;;
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
;; English helper with company interface.
;;
;; This module is base on https://github.com/wushuaibuaa/emacscompanywords
;;
;; I just write new function `toggle-company-english-helper'.
;;

;;; Installation:
;;
;; Put company-english-helper.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'company-english-helper)
;;
;; And bind your key with function `toggle-company-english-helper'.
;;

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET company-english-helper RET
;;

;;; Change log:
;;
;; 2018/07/20
;;      * Use `string-prefix-p' instead fuzz match, too many wrong candidates in completion result.
;;
;; 2018/07/06
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


;;; Code:
(require 'cl-lib)
(require 'company)
(require 'company-english-helper-data)

(defun en-words-annotation (s)
  (let* ((str1 (get-text-property 0 :initials s))
         (str2 (replace-regexp-in-string "\\cc" "" str1))
         (w0 (length s))
         (w1 (length str1))
         (w2 (length str2))
         (n0 (max 0 (- 15 w0)))
         (n1 (max 0 (- company-en-words-candidate-max-width (- w1 w2)))))
    (format "%s" (concat (make-string n0 ?\ )
                         str1
                         (make-string n1 ?\．)))))

(defun company-en-words (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-en-words))
    (prefix (company-grab-word))
    (candidates
     (remove-if-not
      (lambda (c) (string-prefix-p arg c))
      en-words-completions))
    (annotation (en-words-annotation arg))
    (sorted t)
    (ignore-case 'keep-prefix)
    ))

(defvar company-en-words-candidate-max-width 30
  "The max width of candidates.
Default is 30, it will occur candidate is not alignment if this value too small.")

(defvar company-en-words-active-p nil
  "The status of company-en-words plugins.
Default is disable.")

(defun toggle-company-english-helper ()
  "Toggle company english helper."
  (interactive)
  (if company-en-words-active-p
      (progn
        (setq company-backends (remove 'company-en-words company-backends))
        ;; I need remove `company-en-words' with `company-yasnippet',
        ;; it's not enough just remove `company-en-words' from `company-backends'
        (setq company-backends (remove '(company-en-words :with company-yasnippet) company-backends))
        (setq company-en-words-active-p nil)
        (message "English helper has disable."))
    (add-to-list 'company-backends 'company-en-words)
    (setq company-en-words-active-p t)
    (message "English helper has enable.")))

(provide 'company-english-helper)

;;; company-english-helper.el ends here
