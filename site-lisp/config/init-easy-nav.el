;;; init-easy-nav.el --- Plugin for view source code.   -*- lexical-binding: t; -*-

;; Filename: init-easy-nav.el
;; Description: Plugin for view source code.
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2023, Andy Stewart, all rights reserved.
;; Created: 2023-06-12 22:45:23
;; Version: 0.1
;; Last-Updated: 2023-06-12 22:45:23
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-easy-nav
;; Keywords:
;; Compatibility: GNU Emacs 30.0.50
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
;; Plugin for view source code.
;;

;;; Installation:
;;
;; Put init-easy-nav.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-easy-nav)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-easy-nav RET
;;

;;; Change log:
;;
;; 2023/06/12
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
(require 'popweb)
(require 'init-lsp-bridge)
(require 'color-rg)
(require 'init-thing-edit)

;;; Code:

(defvar easy-nav-map nil
  "Keymap used when popup is shown.")

(setq easy-nav-map
      (let ((map (make-sparse-keymap)))
        (define-key map (kbd "j") #'next-line)
        (define-key map (kbd "k") #'previous-line)
        (define-key map (kbd "J") #'scroll-up-one-line)
        (define-key map (kbd "K") #'scroll-down-one-line)
        (define-key map (kbd "g") #'beginning-of-buffer)
        (define-key map (kbd "G") #'end-of-buffer)
        (define-key map (kbd "h") #'backward-char)
        (define-key map (kbd "l") #'forward-char)
        (define-key map (kbd "H") #'backward-word)
        (define-key map (kbd "L") #'forward-word)
        (define-key map (kbd "c") #'one-key-menu-thing-edit)
        (define-key map (kbd "e") #'scroll-down)
        (define-key map (kbd "SPC") #'scroll-up)
        (define-key map (kbd "s") #'color-rg-search-symbol)
        (define-key map (kbd "i") #'color-rg-search-input)
        (define-key map (kbd ",") #'color-rg-search-symbol-in-current-file)
        (define-key map (kbd ".") #'color-rg-search-input-in-current-file)
        (define-key map (kbd "<") #'remember-init)
        (define-key map (kbd ">") #'remember-jump)
        (define-key map (kbd "7") #'lsp-bridge-find-def-return)
        (define-key map (kbd "8") #'easy-nav-jump)
        (define-key map (kbd "9") #'lsp-bridge-popup-documentation)
        (define-key map (kbd ";") #'popweb-dict-bing-input)
        (define-key map (kbd "y") #'popweb-dict-bing-pointer)
        (define-key map (kbd "q") #'easy-nav-exist)
        map))

(define-minor-mode easy-nav-mode
  "Easy navigator."
  :keymap easy-nav-map
  :init-value nil)

(defun easy-nav-enter ()
  (interactive)
  (read-only-mode 1)
  (easy-nav-mode 1)
  (message "Enter easy navigator."))

(defun easy-nav-exist ()
  (interactive)
  (read-only-mode -1)
  (easy-nav-mode -1)
  (message "Exit easy navigator."))

(defun easy-nav-jump ()
  (interactive)
  (lsp-bridge-find-def)
  (easy-nav-enter))

(provide 'init-easy-nav)

;;; init-easy-nav.el ends here
