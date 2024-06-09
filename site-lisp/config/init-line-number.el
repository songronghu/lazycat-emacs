;;; init-line-number.el --- Configuration for display line number

;; Filename: init-line-number.el
;; Description: Configuration for display line number
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-08-26 02:03:32
;; Version: 0.1
;; Last-Updated: 2018-08-26 02:03:32
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-line-number.el
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
;; Configuration for display line number
;;

;;; Installation:
;;
;; Put init-line-number.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-line-number)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-line-number RET
;;

;;; Change log:
;;
;; 2018/08/26
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

;; Line numbers are not displayed when large files are used.
(setq line-number-display-limit large-file-warning-threshold)
(setq line-number-display-limit-width 1000)

(dolist (hook (list
               'asm-mode-hook
               'bash-ts-mode-hook
               'c++-ts-mode-hook
               'c-mode-common-hook
               'c-mode-hook
               'c-ts-mode-hook
               'clojure-mode-hook
               'cmake-mode-hook
               'cmake-ts-mode-hook
               'coffee-mode-hook
               'coffee-mode-hook
               'conf-toml-mode-hook
               'css-mode-hook
               'css-ts-mode-hook
               'dart-mode-hook
               'elixir-mode-hook
               'emacs-lisp-mode-hook
               'erc-mode-hook
               'go-mode-hook
               'haskell-mode-hook
               'html-mode-hook
               'jade-mode-hook
               'java-mode-hook
               'java-ts-mode-hook
               'js-mode-hook
               'js-ts-mode-hook
               'json-ts-mode-hook
               'kotlin-mode-hook
               'lisp-interaction-mode-hook
               'lisp-mode-hook
               'llvm-mode-hook
               'lua-mode-hook
               'makefile-gmake-mode-hook
               'markdown-mode-hook
               'mojo-mode-hook
               'nim-mode-hook
               'nxml-mode-hook
               'package-menu-mode-hook
               'php-mode-hook
               'python-mode-hook
               'python-ts-mode-hook
               'qmake-mode-hook
               'qml-mode-hook
               'rcirc-mode-hook
               'ruby-mode-hook
               'rust-mode-hook
               'rust-ts-mode-hook
               'sh-mode-hook
               'slime-repl-mode-hook
               'swift-mode-hook
               'sws-mode-hook
               'toml-ts-mode-hook
               'tuareg-mode-hook
               'typescript-mode-hook
               'typescript-ts-mode-hook
               'vala-mode-hook
               'web-mode-hook
               'zig-mode-hook
               'fsharp-mode-hook
               ))
  (add-hook hook (lambda () (display-line-numbers-mode))))

(provide 'init-line-number)

;;; init-line-number.el ends here
